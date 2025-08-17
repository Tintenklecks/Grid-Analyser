from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Callable, Iterable, List, Set

from .persistence_service import PersistenceService
from .binance_service import BinanceService, BinanceError
from .analyzer import GridTradingAnalyzer
from models.coin import Coin
from models.persisted import PersistedCoinData, PersistedDataContainer


class RepositoryError(Exception):
	pass


@dataclass
class CoinRepository:
	persistence_service: PersistenceService

	def load_persisted_data(self) -> PersistedDataContainer | None:
		return self.persistence_service.load()

	def save_selections(self, selections: Set[str]) -> None:
		self.persistence_service.save_selections(selections)

	def load_selections(self) -> Set[str]:
		return self.persistence_service.load_selections() or set()

	def load_available_coins(self) -> List[str]:
		try:
			return self.persistence_service.load_available_coins()
		except Exception:
			return ["BTC", "ETH", "BNB", "SOL", "XRP"]

	def fetch_and_save_data(
		self,
		symbols: Iterable[str],
		grid_spacing: float,
		progress: Callable[[str, str], None] | None = None,
	) -> PersistedDataContainer:
		persisted: List[PersistedCoinData] = []
		errors: list[tuple[str, str]] = []
		analyzer = GridTradingAnalyzer(grid_spacing=grid_spacing)
		service = BinanceService()

		for idx, symbol in enumerate(symbols):
			if progress:
				progress(f"Loading {symbol}", f"({idx+1}/{len(list(symbols))})")
			try:
				prices = service.fetch_klines(symbol)
				if not prices:
					errors.append((symbol, "No price data available"))
					continue
				coin = Coin(symbol=symbol, prices=prices)
				analysis = analyzer.analyze(coin)
				persisted.append(
					PersistedCoinData.from_coin(
						coin,
						successful_trades=analysis.successful_trades,
						grid_density=analysis.grid_density,
						grid_spacing=grid_spacing,
					)
				)
			except BinanceError as e:
				errors.append((symbol, str(e)))
			except Exception as e:
				errors.append((symbol, str(e)))

		if not persisted:
			raise RepositoryError("Failed to fetch any coin data")

		container = PersistedDataContainer(
			coins=persisted,
			lastUpdateTime=datetime.utcnow(),
			gridSpacing=grid_spacing,
		)
		self.persistence_service.save(container)

		if errors:
			joined = "\n".join(f"{s}: {m}" for s, m in errors)
			raise RepositoryError(f"Partial failure:\n{joined}")

		return container