from __future__ import annotations

from dataclasses import dataclass
from math import floor

from models.coin import Coin


@dataclass
class Analysis:
	coin: Coin
	successful_trades: int
	grid_density: int


class GridTradingAnalyzer:
	def __init__(self, grid_spacing: float) -> None:
		self.grid_spacing = grid_spacing

	def analyze(self, coin: Coin) -> Analysis:
		trades = self._simulate_grid_trading(coin)
		density = self._calculate_grid_density(coin)
		return Analysis(coin=coin, successful_trades=trades, grid_density=density)

	def _simulate_grid_trading(self, coin: Coin) -> int:
		grid_spacing_decimal = self.grid_spacing / 100.0
		if coin.min_price == 0:
			return 0
		num_lines = int(floor((coin.max_price - coin.min_price) / (coin.min_price * grid_spacing_decimal)))
		grid_lines = [coin.min_price * (1 + grid_spacing_decimal * i) for i in range(num_lines + 1)]

		trades = 0
		active_orders: dict[float, float] = {}

		for price in coin.prices:
			for i in range(len(grid_lines) - 1, 0, -1):
				buy_line = grid_lines[i - 1]
				sell_line = buy_line * (1 + grid_spacing_decimal)
				if price < buy_line and buy_line not in active_orders:
					active_orders[buy_line] = sell_line
					break

			hit_sell_lines = [bl for bl, sl in active_orders.items() if price > sl]
			for bl in hit_sell_lines:
				trades += 1
				del active_orders[bl]

		return trades

	def _calculate_grid_density(self, coin: Coin) -> int:
		grid_spacing_decimal = self.grid_spacing / 100.0
		if coin.min_price == 0:
			return 0
		return int(floor((coin.max_price - coin.min_price) / (coin.min_price * grid_spacing_decimal))) + 1