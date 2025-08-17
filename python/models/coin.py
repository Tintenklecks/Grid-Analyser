from __future__ import annotations

from dataclasses import dataclass, field
from typing import List


@dataclass
class Coin:
	symbol: str
	prices: List[float]
	min_price: float = field(init=False)
	max_price: float = field(init=False)
	avg_price: float = field(init=False)
	change_percent: float = field(init=False)

	def __post_init__(self) -> None:
		self.min_price = min(self.prices) if self.prices else 0.0
		self.max_price = max(self.prices) if self.prices else 0.0
		self.avg_price = sum(self.prices) / len(self.prices) if self.prices else 0.0
		if self.prices and self.prices[0] != 0:
			self.change_percent = ((self.prices[-1] - self.prices[0]) / self.prices[0]) * 100.0
		else:
			self.change_percent = 0.0