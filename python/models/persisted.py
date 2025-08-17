from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from typing import List, Dict, Any

from .coin import Coin


@dataclass
class PersistedCoinData:
	symbol: str
	prices: List[float]
	minPrice: float
	maxPrice: float
	avgPrice: float
	changePercent: float
	successfulTrades: int
	gridDensity: int
	gridSpacing: float
	timestamp: datetime

	@staticmethod
	def from_coin(coin: Coin, successful_trades: int, grid_density: int, grid_spacing: float) -> "PersistedCoinData":
		return PersistedCoinData(
			symbol=coin.symbol,
			prices=list(coin.prices),
			minPrice=coin.min_price,
			maxPrice=coin.max_price,
			avgPrice=coin.avg_price,
			changePercent=coin.change_percent,
			successfulTrades=successful_trades,
			gridDensity=grid_density,
			gridSpacing=grid_spacing,
			timestamp=datetime.utcnow(),
		)

	def to_coin(self) -> Coin:
		return Coin(symbol=self.symbol, prices=self.prices)

	def to_dict(self) -> Dict[str, Any]:
		return {
			"symbol": self.symbol,
			"prices": self.prices,
			"minPrice": self.minPrice,
			"maxPrice": self.maxPrice,
			"avgPrice": self.avgPrice,
			"changePercent": self.changePercent,
			"successfulTrades": self.successfulTrades,
			"gridDensity": self.gridDensity,
			"gridSpacing": self.gridSpacing,
			"timestamp": self.timestamp.isoformat(),
		}

	@staticmethod
	def from_dict(data: Dict[str, Any]) -> "PersistedCoinData":
		return PersistedCoinData(
			symbol=data["symbol"],
			prices=list(map(float, data.get("prices", []))),
			minPrice=float(data.get("minPrice", 0)),
			maxPrice=float(data.get("maxPrice", 0)),
			avgPrice=float(data.get("avgPrice", 0)),
			changePercent=float(data.get("changePercent", 0)),
			successfulTrades=int(data.get("successfulTrades", 0)),
			gridDensity=int(data.get("gridDensity", 0)),
			gridSpacing=float(data.get("gridSpacing", 0)),
			timestamp=datetime.fromisoformat(data.get("timestamp")),
		)


@dataclass
class PersistedDataContainer:
	coins: List[PersistedCoinData]
	lastUpdateTime: datetime
	gridSpacing: float

	def to_dict(self) -> Dict[str, Any]:
		return {
			"coins": [c.to_dict() for c in self.coins],
			"lastUpdateTime": self.lastUpdateTime.isoformat(),
			"gridSpacing": self.gridSpacing,
		}

	@staticmethod
	def from_dict(data: Dict[str, Any]) -> "PersistedDataContainer":
		return PersistedDataContainer(
			coins=[PersistedCoinData.from_dict(c) for c in data.get("coins", [])],
			lastUpdateTime=datetime.fromisoformat(data.get("lastUpdateTime")),
			gridSpacing=float(data.get("gridSpacing", 0)),
		)