from __future__ import annotations

import json
import os
import time
from datetime import datetime
from pathlib import Path
from typing import List, Set

from flask import Flask, render_template, request, redirect, url_for, flash

from services.persistence_service import PersistenceService
from services.coin_repository import CoinRepository, RepositoryError
from models.settings import Settings
from models.presentation import CoinPresentationModel
from models.persisted import PersistedCoinData, PersistedDataContainer
from services.analyzer import GridTradingAnalyzer


# App factory
app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "dev")

BASE_DIR = Path(__file__).parent.resolve()
persistence_service = PersistenceService(base_dir=BASE_DIR)
repository = CoinRepository(persistence_service=persistence_service)
settings = Settings.load(persistence_service.settings_file_path)


# Jinja filters
@app.template_filter("datetime_short")
def datetime_short(value: datetime | None) -> str:
	if not value:
		return ""
	return value.strftime("%Y-%m-%d %H:%M")


# Helpers

def build_presentation_models(container: PersistedDataContainer | None,
								 selected_symbols: Set[str], current_settings: Settings) -> List[CoinPresentationModel]:
	if container is None:
		return []

	needs_recalc = abs(container.gridSpacing - current_settings.grid_delta) > 0.01
	analyzer = GridTradingAnalyzer(grid_spacing=current_settings.grid_delta)

	presentation_models: List[CoinPresentationModel] = []
	for persisted in container.coins[: current_settings.display_top_coins]:
		coin = persisted.to_coin()
		if needs_recalc:
			analysis = analyzer.analyze(coin)
			successful_trades = analysis.successful_trades
			grid_density = analysis.grid_density
		else:
			successful_trades = persisted.successfulTrades
			grid_density = persisted.gridDensity

		is_selected = coin.symbol in selected_symbols
		presentation_models.append(
			CoinPresentationModel(
				id=coin.symbol,
				symbol=coin.symbol,
				prices=coin.prices,
				minPrice=coin.min_price,
				maxPrice=coin.max_price,
				avgPrice=coin.avg_price,
				changePercent=coin.change_percent,
				successfulTrades=successful_trades,
				gridDensity=grid_density,
				isSelected=is_selected,
				critz=int(current_settings.critz),
			)
		)

	# Sort by successfulTrades desc
	presentation_models.sort(key=lambda m: m.successfulTrades, reverse=True)
	return presentation_models


# Routes
@app.get("/")
def index():
	container = repository.load_persisted_data()
	selected_symbols = repository.load_selections()
	models = build_presentation_models(container, selected_symbols, settings)
	last_update = container.lastUpdateTime if container else None

	available_symbols = repository.load_available_coins()
	return render_template(
		"index.html",
		coins=models,
		selected_symbols=sorted(list(selected_symbols)),
		last_update=last_update,
		settings=settings,
		available_count=len(available_symbols),
	)


@app.post("/refresh")
def refresh():
	available_symbols = repository.load_available_coins()
	symbols_to_load = available_symbols[: settings.display_top_coins]
	start = time.time()
	try:
		container = repository.fetch_and_save_data(
			symbols=symbols_to_load,
			grid_spacing=settings.grid_delta,
			progress=lambda title, detail: None,
		)
		flash(f"Fetched {len(container.coins)} coins in {time.time()-start:.1f}s", "success")
	except RepositoryError as e:
		flash(str(e), "danger")
	except Exception as e:
		flash(f"Unexpected error: {e}", "danger")
	return redirect(url_for("index"))


@app.post("/toggle-selection")
def toggle_selection():
	symbol = request.form.get("symbol", "").strip().upper()
	if not symbol:
		return redirect(request.referrer or url_for("index"))

	selections = repository.load_selections()
	if symbol in selections:
		selections.remove(symbol)
	else:
		selections.add(symbol)
	repository.save_selections(selections)
	return redirect(request.referrer or url_for("index"))


@app.get("/coin/<symbol>")
def coin_detail(symbol: str):
	symbol = symbol.upper()
	container = repository.load_persisted_data()
	if not container:
		flash("No data available. Please refresh first.", "info")
		return redirect(url_for("index"))

	# Find coin
	persisted: PersistedCoinData | None = next((c for c in container.coins if c.symbol == symbol), None)
	if not persisted:
		flash(f"Coin {symbol} not found.", "warning")
		return redirect(url_for("index"))

	# Recalculate if grid spacing changed
	needs_recalc = abs(container.gridSpacing - settings.grid_delta) > 0.01
	coin = persisted.to_coin()
	if needs_recalc:
		analyzer = GridTradingAnalyzer(grid_spacing=settings.grid_delta)
		analysis = analyzer.analyze(coin)
		successful_trades = analysis.successful_trades
		grid_density = analysis.grid_density
	else:
		successful_trades = persisted.successfulTrades
		grid_density = persisted.gridDensity

	selected_symbols = repository.load_selections()
	model = CoinPresentationModel(
		id=coin.symbol,
		symbol=coin.symbol,
		prices=coin.prices,
		minPrice=coin.min_price,
		maxPrice=coin.max_price,
		avgPrice=coin.avg_price,
		changePercent=coin.change_percent,
		successfulTrades=successful_trades,
		gridDensity=grid_density,
		isSelected=(symbol in selected_symbols),
		critz=int(settings.critz),
	)

	# Precompute tendencies for ranges
	def data_points_for(range_key: str, total: int) -> int:
		mapping = {
			"24h": total,
			"12h": max(1, total // 2),
			"6h": max(1, total // 4),
			"3h": max(1, total // 8),
			"1h": max(1, total // 24),
			"15m": max(1, total // 96),
		}
		return mapping.get(range_key, total)

	def calc_change(prices: List[float]) -> float:
		if not prices or len(prices) < 2:
			return 0.0
		first, last = prices[0], prices[-1]
		if first == 0:
			return 0.0
		return ((last - first) / first) * 100.0

	total = len(model.prices)
	ranges = ["24h", "12h", "6h", "3h", "1h", "15m"]
	tendencies = []
	for key in ranges:
		count = data_points_for(key, total)
		selected = model.prices[-count:]
		chg = calc_change(selected)
		# Clamp between -10 and 10 for visualization
		clamped = max(min(chg, 10.0), -10.0)
		tendencies.append({
			"range": key,
			"tendency": clamped,
			"changeText": f"{chg:+.2f}%",
		})

	return render_template(
		"detail.html",
		coin=model,
		prices=model.prices,
		settings=settings,
		tendencies=tendencies,
	)


@app.get("/settings")
@app.post("/settings")
def settings_view():
	if request.method == "POST":
		try:
			grid_delta = float(request.form.get("grid_delta", settings.grid_delta))
			display_top = int(request.form.get("display_top_coins", settings.display_top_coins))
			critz = float(request.form.get("critz", settings.critz))
			settings.grid_delta = max(0.1, min(2.0, grid_delta))
			settings.display_top_coins = max(5, min(1000, display_top))
			settings.critz = max(0.5, min(5.0, critz))
			settings.save(persistence_service.settings_file_path)
			flash("Settings saved", "success")
			return redirect(url_for("index"))
		except Exception as e:
			flash(f"Failed to save settings: {e}", "danger")

	return render_template("settings.html", settings=settings)


if __name__ == "__main__":
	app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)), debug=True)