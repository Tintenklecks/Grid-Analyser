import json
import numpy as np
import pandas as pd
import streamlit as st
import os
from pathlib import Path
import requests

# --- JSON generation logic from uploaded file ---

coin_list = [
    'BTC','ETH','XRP','BNB','SOL','DOGE','ADA','TRX','HYPE','SUI','LINK','AVAX','XLM','SHIB','BCH','LEO','HBAR','TON','DOT','LTC','BGB','UNI','TRUMP','PEPE','NEAR','MNT','OM','ALGO','OKB','KAS','TAO','FET','FIL','ARB','ENA','BONK','ICP','APT','MATIC','WTRX','WLD','ETC','XMR','IMX','VET','INJ','RNDR','QNT','MKR','RUNE','LDO','TWT','GRT','AAVE','FLOW','AXS','SAND','THETA','EGLD','FTM','DYDX','ZEC','NEO','CHZ','KLAY','CRV','BAT','1INCH','ENJ','CELO','SNX','COMP','YFI','ZIL','IOST','OMG','NANO','SC','BTT','ZEN','ONT','DGB','ICX','WAVES','STORJ','KNC','ANKR','CVC','REQ','LRC','NMR','BAL','OCEAN','BNT','REN','SXP','SKL','CKB','RSR','ELF','COTI','CTSI','PUNDIX','STMX','ARDR','STRAX' 


    # 'BTC', 'ETH', 'XRP', 'BNB', 'SOL', 'DOGE', 'ADA', 'TRX',
    # 'SUI', 'LINK', 'AVAX', 'XLM', 'DOT', 'MATIC', 'WBTC', 'LTC', 'BCH',
    # 'UNI', 'ATOM', 'ETC', 'ICP', 'FIL', 'HBAR', 'APT', 'IMX',  'NEAR',
    # 'ARB', 'OP', 'QNT', 'VET', 'ALGO', 'GRT', 'FTM', 'MKR', 'EGLD', 'AAVE',
    # 'INJ', 'STX', 'XTZ', 'THETA', 'SAND', 'WLD'
]
# coin_list = [
#     'BTC', 'ETH', 'BNB', 'XRP', 'ADA', 'SOL', 'DOGE', 'DOT', 'SHIB', 'LTC',
#     'LINK', 'AVAX', 'UNI', 'XLM', 'VET', 'TRX', 'XMR', 'EOS', 'XTZ', 'FIL', 'WLD'
# ]

def fetch_klines(symbol):
    url = 'https://api.binance.com/api/v3/klines'
    params = {
        'symbol': f'{symbol}USDT',
        'interval': '1m',
        'limit': 1440
    }
    headers = {
        "User-Agent": "Mozilla/5.0",
        "X-MBX-APIKEY": "8ItH7L1AJXTkWGOkKHiXYd8AyROt42kHkCIMhXVePi8l1jiDGNco0Wjq8ntEubRB"
    }

    response = requests.get(url, params=params, headers=headers)
    response.raise_for_status()
    klines_data = response.json()
    average_prices = [(float(k[2]) + float(k[3])) / 2 for k in klines_data]  # avg(high, low)
    return average_prices

def generate_json(filepath):
    data = {}
    total_coins = len(coin_list)
    success_count = 0
    error_count = 0
    
    # Create progress bar and status text
    progress_bar = st.progress(0)
    status_text = st.empty()
    
    for i, coin in enumerate(coin_list):
        current_progress = i + 1
        
        # Update status text
        status_text.text(f"{current_progress} / {total_coins}     {success_count} success  {error_count} error")
        
        try:
            data[coin] = fetch_klines(coin)
            success_count += 1
        except Exception as e:
            # Silently ignore failed requests
            error_count += 1
            pass
        
        # Update progress bar
        progress_bar.progress(current_progress / total_coins)
    
    # Final status update
    status_text.text(f"{total_coins} / {total_coins}     {success_count} success  {error_count} error - Complete!")
    
    with open(filepath, "w") as f:
        json.dump(data, f)
    return filepath

# --- Grid Trading Simulation ---
def get_trend_arrow(start_price, end_price):
    """Return colored arrow based on price trend"""
    change_percent = ((end_price - start_price) / start_price) * 100
    
    if change_percent > 2:
        return "🟢 ↗️"  # Strong up (45° up right)
    elif change_percent > 0.5:
        return "🟢 ↑"   # Up
    elif change_percent > -0.5:
        return "⚪ →"   # Sideways (gray)
    elif change_percent > -2:
        return "🔴 ↓"   # Down
    else:
        return "🔴 ↘️"  # Strong down (45° down right)

def simulate_grid_trading(prices, grid_spacing_percent=0.1):
    prices = np.array(prices)
    min_price = prices.min()
    max_price = prices.max()
    avg_price = prices.mean()
    
    # Calculate trend
    start_price = prices[0]
    end_price = prices[-1]
    trend_arrow = get_trend_arrow(start_price, end_price)

    grid_spacing = grid_spacing_percent / 100.0
    num_lines = int(np.floor((max_price - min_price) / (min_price * grid_spacing)))
    grid_lines = min_price * (1 + grid_spacing * np.arange(num_lines + 1))

    trades = 0
    active_orders = {}

    for price in prices:
        for i in range(len(grid_lines) - 1, -1, -1):
            buy_line = grid_lines[i]
            sell_line = buy_line * (1 + grid_spacing)
            if price < buy_line and buy_line not in active_orders:
                active_orders[buy_line] = sell_line
                break

        hit_sell_lines = [bl for bl, sl in active_orders.items() if price > sl]
        for bl in hit_sell_lines:
            trades += 1
            del active_orders[bl]

    return {
        "trend": trend_arrow,
        "trades": trades,
        "min": float(min_price),
        "max": float(max_price),
        "avg": float(avg_price),
        "grid_density": num_lines + 1
    }


def load_and_simulate(file, grid_spacing_percent=0.1):
    data = json.load(file)
    results = {coin: simulate_grid_trading(prices, grid_spacing_percent) for coin, prices in data.items()}
    sorted_results = dict(sorted(results.items(), key=lambda item: item[1]['trades'], reverse=True))
    df = pd.DataFrame.from_dict(sorted_results, orient='index')
    df.index.name = 'Coin'
    return df


# --- Streamlit UI ---
st.title("Grid Trading Analyzer")

# Add grid spacing slider
grid_spacing = st.slider(
    "Grid Delta (%)", 
    min_value=0.1, 
    max_value=2.0, 
    value=0.1, 
    step=0.1,
    help="Select the grid spacing percentage (0.1% to 2.0%)"
)

json_path = Path("top_20_klines.json")

if not json_path.exists():
    st.info("JSON file not found. Generating data...")
    generate_json(json_path)
    st.success("JSON file created.")

if st.button("(Re)Generate JSON Data from Binance"):
    generate_json(json_path)
    st.success("JSON file updated.")

if json_path.exists():
    with open(json_path, "r") as f:
        df = load_and_simulate(f, grid_spacing)
        st.dataframe(df)