from __future__ import annotations

from dataclasses import dataclass


@dataclass
class CoinPresentationModel:
	id: str
	symbol: str
	prices: list[float]
	minPrice: float
	maxPrice: float
	avgPrice: float
	changePercent: float
	successfulTrades: int
	gridDensity: int
	isSelected: bool
	critz: int

	@property
	def formattedMinPrice(self) -> str:
		return self._format_price(self.minPrice)

	@property
	def formattedMaxPrice(self) -> str:
		return self._format_price(self.maxPrice)

	@property
	def formattedAvgPrice(self) -> str:
		return self._format_price(self.avgPrice)

	@property
	def formattedChangePercent(self) -> str:
		return f"{self.changePercent:+.1f}%"

	@property
	def changeArrowName(self) -> str:
		if self.changePercent > 0:
			return "↑"
		elif self.changePercent < 0:
			return "↓"
		return "→"

	@property
	def changeColorClass(self) -> str:
		if self.changePercent > 0:
			return "text-success"
		elif self.changePercent < 0:
			return "text-danger"
		return "text-body"

	@property
	def tradesTextColorClass(self) -> str:
		if self.successfulTrades >= self.critz:
			return "text-success"
		elif self.successfulTrades > 0:
			return "text-warning"
		return "text-danger"

	def _format_price(self, price: float) -> str:
		if price < 1:
			return f"{price:.4f}"
		elif price < 100:
			return f"{price:.2f}"
		return f"{price:.0f}"