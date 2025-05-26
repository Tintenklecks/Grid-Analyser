top_20_coins = [
    'BTC', 'ETH', 'BNB', 'XRP', 'ADA', 'SOL', 'DOGE', 'DOT', 'SHIB', 'LTC',
    'LINK', 'AVAX', 'UNI', 'XLM', 'VET', 'TRX', 'XMR', 'EOS', 'XTZ', 'FIL', 'WLD'
]


import requests
import json
from tqdm import tqdm

def fetch_klines(symbol):
    url = 'https://api.binance.com/api/v3/klines'
    params = {
        'symbol': f'{symbol}USDT',
        'interval': '1m',
        'limit': 1440
    }
    response = requests.get(url, params=params)
    response.raise_for_status()
    klines_data = response.json()
    
    # Extract average price for each minute (average of high and low)
    average_prices = []
    for kline in klines_data:
        high_price = float(kline[2])  # High price
        low_price = float(kline[3])   # Low price
        average_price = (high_price + low_price) / 2
        average_prices.append(average_price)
    
    return average_prices

data = {}
for coin in tqdm(top_20_coins, desc="Fetching data"):
    try:
        klines = fetch_klines(coin)
        data[coin] = klines
    except Exception as e:
        print(f"Error fetching data for {coin}: {e}")

import zipfile

# Save to JSON
with open('./top_20_klines.json', 'w') as f:
    json.dump(data, f)

# Compress into ZIP
# with zipfile.ZipFile('top_20_klines.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
#     zipf.write('top_20_klines.json')


