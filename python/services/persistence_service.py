from __future__ import annotations

import json
from dataclasses import asdict
from pathlib import Path
from typing import List, Set

from models.persisted import PersistedDataContainer, PersistedCoinData


class PersistenceService:
	def __init__(self, base_dir: Path) -> None:
		self.base_dir = base_dir
		self.data_dir = self.base_dir / "data"
		self.data_dir.mkdir(parents=True, exist_ok=True)
		self.file_path = self.data_dir / "coin_data.json"
		self.selections_file_path = self.data_dir / "selected_coins.json"
		self.coins_file_path = self.data_dir / "coins.json"
		self.settings_file_path = self.data_dir / "settings.json"

		# Ensure coins.json exists
		self._ensure_coins_file_exists()

	def save(self, container: PersistedDataContainer) -> None:
		data = container.to_dict()
		with self.file_path.open("w") as f:
			json.dump(data, f, indent=2)

	def load(self) -> PersistedDataContainer | None:
		if not self.file_path.exists():
			return None
		with self.file_path.open("r") as f:
			data = json.load(f)
		return PersistedDataContainer.from_dict(data)

	def delete(self) -> None:
		if self.file_path.exists():
			self.file_path.unlink()

	def save_selections(self, selections: Set[str]) -> None:
		with self.selections_file_path.open("w") as f:
			json.dump(sorted(list(selections)), f, indent=2)

	def load_selections(self) -> Set[str] | None:
		if not self.selections_file_path.exists():
			return None
		with self.selections_file_path.open("r") as f:
			arr = json.load(f)
		return set(arr)

	def _ensure_coins_file_exists(self) -> None:
		if self.coins_file_path.exists():
			return
		# Default list, can be expanded or copied from a template
		default = ["BTC", "ETH", "XRP", "BNB", "SOL", "DOGE", "ADA", "TRX", "SUI", "LINK", "AVAX"]
		with self.coins_file_path.open("w") as f:
			json.dump(default, f, indent=2)

	def load_available_coins(self) -> List[str]:
		with self.coins_file_path.open("r") as f:
			return list(json.load(f))