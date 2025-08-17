from __future__ import annotations

import os
from typing import List

import requests


class BinanceError(Exception):
	pass


class BinanceService:
	BASE_URL = "https://api.binance.com/api/v3"

	def __init__(self, session: requests.Session | None = None) -> None:
		self.session = session or requests.Session()
		self.session.headers.update({
			"User-Agent": "Mozilla/5.0",
			"X-MBX-APIKEY": os.environ.get("BINANCE_API_KEY", ""),
		})

	def fetch_klines(self, symbol: str) -> List[float]:
		params = {
			"symbol": f"{symbol}USDT",
			"interval": "1m",
			"limit": 1440,
		}
		url = f"{self.BASE_URL}/klines"
		resp = self.session.get(url, params=params, timeout=30)
		if not resp.ok:
			try:
				msg = resp.json().get("msg", "Invalid response from server")
			except Exception:
				msg = "Invalid response from server"
			raise BinanceError(msg)
		try:
			klines = resp.json()
			prices: List[float] = []
			for item in klines:
				# [openTime, open, high, low, close, ...]
				high = float(item[2])
				low = float(item[3])
				prices.append((high + low) / 2.0)
			return prices
		except Exception as e:
			raise BinanceError(f"Invalid data: {e}")