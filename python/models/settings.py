from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path


@dataclass
class Settings:
	grid_delta: float = 0.1
	display_top_coins: int = 20
	critz: float = 2.0

	@staticmethod
	def load(path: Path) -> "Settings":
		if path.exists():
			with path.open("r") as f:
				data = json.load(f)
			return Settings(
				grid_delta=float(data.get("grid_delta", 0.1)),
				display_top_coins=int(data.get("display_top_coins", 20)),
				critz=float(data.get("critz", 2.0)),
			)
		return Settings()

	def save(self, path: Path) -> None:
		path.parent.mkdir(parents=True, exist_ok=True)
		with path.open("w") as f:
			json.dump(
				{
					"grid_delta": self.grid_delta,
					"display_top_coins": self.display_top_coins,
					"critz": self.critz,
				},
				f,
			)