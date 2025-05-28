import json
import numpy as np
import pandas as pd
import streamlit as st
import os
from pathlib import Path
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# --- JSON generation logic from uploaded file ---

coin_list = [
    'BTC','ETH','XRP','BNB','SOL','DOGE','ADA','TRX','SUI','LINK','AVAX','XLM','SHIB','BCH','HBAR','TON','DOT','LTC','UNI','TRUMP','PEPE','NEAR','OM','ALGO','TAO','FET','FIL','ARB','ENA','BONK','ICP','APT','MATIC','WLD','ETC','IMX','VET','INJ','QNT','MKR','RUNE','LDO','TWT','GRT','AAVE','FLOW','AXS','SAND','THETA','EGLD','FTM','DYDX','ZEC','NEO','CHZ','KLAY','CRV','BAT','1INCH','ENJ','CELO','SNX','COMP','YFI','ZIL','IOST','OMG','NANO','SC','BTT','ZEN','ONT','DGB','ICX','WAVES','STORJ','KNC','ANKR','CVC','REQ','LRC','NMR','BAL','OCEAN','BNT','REN','SXP','SKL','CKB','RSR','ELF','COTI','CTSI','PUNDIX','STMX','ARDR','STRAX' 


]

def fetch_klines(symbol):
    url = 'https://api.binance.com/api/v3/klines'
    params = {
        'symbol': f'{symbol}USDT',
        'interval': '1m',
        'limit': 1440
    }
    headers = {
        "User-Agent": "Mozilla/5.0",
        "X-MBX-APIKEY": os.getenv('BINANCE_API_KEY')
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
    failed_coins = []
    
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
            # Track failed coins
            error_count += 1
            failed_coins.append(coin)
            pass
        
        # Update progress bar
        progress_bar.progress(current_progress / total_coins)
    
    # Final status update
    status_text.text(f"{total_coins} / {total_coins}     {success_count} success  {error_count} error - Complete!")
    
    # Display failed coins if any
    if failed_coins:
        st.warning(f"Failed to fetch data for {len(failed_coins)} coins: {', '.join(failed_coins)}")
    else:
        st.success("All coins fetched successfully!")
    
    with open(filepath, "w") as f:
        json.dump(data, f)
    return filepath

#--- Trend Ball based on change percent ---
def get_trend_ball(change_percent):
    if change_percent > 2:
        return '🟢'
    elif change_percent > 0.5:
        return '🟢'
    elif change_percent > -0.5:
        return '⚪'
    elif change_percent > -2:
        return '🔴'
    else:
        return '🔴'


# --- Grid Trading Simulation ---
def get_trend_arrow(change_percent):
    """Return colored arrow based on price trend"""
    if change_percent > 2:
        return f"+{change_percent:.1f}%&nbsp;⬆️"  # Strong up
    elif change_percent > 0.5:
        return f"+{change_percent:.1f}%&nbsp;↗️"   # Up
    elif change_percent > -0.5:
        return f"{change_percent:.1f}%&nbsp;➡️"   # Sideways
    elif change_percent > -2:
        return f"{change_percent:.1f}%&nbsp;↘️"   # Down
    else:
        return f"{change_percent:.1f}%&nbsp;⬇️"  # Strong down

def simulate_grid_trading(prices, grid_spacing_percent=0.1, coin_rank=None):
    prices = np.array(prices)
    min_price = prices.min()
    max_price = prices.max()
    avg_price = prices.mean()
    
    # Calculate trend
    start_price = prices[0]
    end_price = prices[-1]
    change_percent = ((end_price - start_price) / start_price) * 100

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
        "rank": coin_rank,
        "change_percent": change_percent,
        "trades": trades,
        "min": float(min_price),
        "max": float(max_price),
        "avg": float(avg_price),
        "grid_density": num_lines + 1
    }


def load_and_simulate(file, grid_spacing_percent=0.1):
    data = json.load(file)
    results = {}
    for coin, prices in data.items():
        if coin in coin_list:
            rank = coin_list.index(coin) + 1  # 1-based ranking
            results[coin] = simulate_grid_trading(prices, grid_spacing_percent, rank)
        else:
            results[coin] = simulate_grid_trading(prices, grid_spacing_percent, None)
    
    sorted_results = dict(sorted(results.items(), key=lambda item: item[1]['trades'], reverse=True))
    df = pd.DataFrame.from_dict(sorted_results, orient='index')
    df.index.name = 'Coin'
    
    # Add trend arrow and ball based on change_percent
    df['trend'] = df['change_percent'].apply(get_trend_arrow)
    df['Ball'] = df['change_percent'].apply(get_trend_ball)
    
    # Create clickable links for coin symbols
    def make_clickable_link(coin_symbol):
        url = f"https://www.tradingview.com/symbols/{coin_symbol}USD/"
        return f'<a href="{url}" target="_blank">{coin_symbol}</a>'
    
    # Apply the clickable links to the index (coin symbols)
    df.index = [make_clickable_link(coin) for coin in df.index]
    
    # Drop change_percent column and reorder columns
    df = df.drop('change_percent', axis=1)
    columns_order = ['Ball', 'rank', 'trend', 'trades', 'min', 'max', 'avg', 'grid_density']
    df = df[columns_order]
    
    return df


# --- Streamlit UI ---
st.title("Grid Trading Analyzer")

# Add a multi-select widget for selecting coins
selected_coins_file = Path('data/selected_coins.json')

# Load selected coins from file if it exists
if selected_coins_file.exists():
    with open(selected_coins_file, 'r') as f:
        st.session_state['selected_coins'] = json.load(f)
else:
    st.session_state['selected_coins'] = []

# Initialize the multi-select widget with the loaded coins
selected_coins = st.multiselect(
    'Select Coins',
    sorted(coin_list),  # Display coins in alphabetical order
    default=st.session_state['selected_coins'],
    help='Select coins to display as tags under My Coins'
)

# Update session state and save to file if selection changes
if selected_coins != st.session_state['selected_coins']:
    st.session_state['selected_coins'] = selected_coins
    with open(selected_coins_file, 'w') as f:
        json.dump(st.session_state['selected_coins'], f)

# Display selected coins as tags under the headline
st.subheader('My Coins')
if st.session_state['selected_coins']:
    st.write(', '.join(st.session_state['selected_coins']))
else:
    st.write('No coins selected.')

# Add grid spacing slider
grid_spacing = st.slider(
    "Grid Delta (%)", 
    min_value=0.1, 
    max_value=2.0, 
    value=0.1, 
    step=0.1,
    help="Select the grid spacing percentage (0.1% to 2.0%)"
)

# Add coin limit slider
max_coins_to_show = st.slider(
    "Display only top x coins by market cap",
    min_value=5,
    max_value=len(coin_list),
    value=50,
    step=5,
    help=f"Select how many coins to display (max: {len(coin_list)})"
)

json_path = Path("klines.json")

if not json_path.exists():
    st.info("JSON file not found. Generating data...")
    generate_json(json_path)
    st.success("JSON file created.")

if st.button("(Re)Generate JSON Data from Binance"):
    generate_json(json_path)
    st.success("JSON file updated.")

# Function to apply conditional formatting

def highlight_rows(row):
    coin_symbol = row.name.split('>')[1].split('<')[0]  # Extract coin symbol from the HTML link
    if coin_symbol in st.session_state['selected_coins']:
        # Extract percentage from trend string (e.g., "+1.5% ⬆️" -> 1.5)
        trend_str = row['trend'].split('%')[0]  # Get the part before the %
        try:
            trend_value = float(trend_str.replace('+', ''))  # Remove + sign if present
        except ValueError:
            trend_value = 0  # Default to 0 if parsing fails
        
        # Create a list of styles for each column
        styles = []
        for col in row.index:
            if col in ['Ball', 'rank']:
                styles.append('')  # No background color for Ball and rank columns
            else:
                if trend_value < -2:
                    styles.append('background-color: darkred; color: white')
                elif trend_value < -0.5:
                    styles.append('background-color: lightcoral; color: white')
                elif trend_value > 2:
                    styles.append('background-color: darkgreen; color: white')
                elif trend_value > 0.5:
                    styles.append('background-color: mediumseagreen; color: white')
                else:
                    styles.append('background-color: whitesmoke; color: black')
        return styles
    else:
        return [''] * len(row)  # No color for coins not in the selected list

if json_path.exists():
    with open(json_path, "r") as f:
        df = load_and_simulate(f, grid_spacing)
        # Filter by original rank (market cap ranking) - show only coins with rank 1 to max_coins_to_show
        df_filtered = df[df['rank'] <= max_coins_to_show]
        
        # Apply conditional formatting
        df_styled = df_filtered.style.apply(highlight_rows, axis=1)
        
        # Display dataframe with HTML links enabled
        st.write(df_styled.to_html(escape=False), unsafe_allow_html=True)