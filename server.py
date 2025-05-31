from flask import Flask, jsonify, request
from flask_cors import CORS
import requests
from bs4 import BeautifulSoup
import json
import socket
import sys
from datetime import datetime

app = Flask(__name__)
CORS(app)  # 啟用 CORS 以允許 Flutter 應用訪問

# 緩存新聞數據
news_cache = {
    'data': [],
    'last_update': None
}

def is_port_in_use(port):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def fetch_news_from_website():
    try:
        url = 'https://www.nuu.edu.tw/p/406-1000-77,r6.php'
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'zh-TW,zh;q=0.9,en-US;q=0.8,en;q=0.7',
        }
        
        response = requests.get(url, headers=headers)
        response.encoding = 'utf-8'
        
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            news_list = []
            
            # 找到所有新聞項目
            news_items = soup.select('.list-wrapper .h5')
            dates = soup.select('.list-wrapper .date')
            
            for i in range(len(news_items)):
                try:
                    title_element = news_items[i]
                    date_element = dates[i]
                    link_element = title_element.parent
                    
                    title = title_element.text.strip()
                    date = date_element.text.strip()
                    href = link_element.get('href', '')
                    
                    if href and not href.startswith('http'):
                        href = 'https://www.nuu.edu.tw' + href
                    
                    news_list.append({
                        'title': title,
                        'date': date,
                        'link': href,
                        'category': '聯大新聞',
                        'description': title,
                        'content': '新聞內容載入中...\n\n詳細內容請點擊連結查看'
                    })
                except Exception as e:
                    print(f'處理新聞項目時發生錯誤: {e}')
                    continue
            
            return news_list
        else:
            print(f'HTTP錯誤: {response.status_code}')
            return []
            
    except Exception as e:
        print(f'爬取新聞時發生錯誤: {e}')
        return []

@app.route('/api/news')
def get_news():
    try:
        # 檢查緩存是否過期（30分鐘）
        if (news_cache['last_update'] is None or 
            (datetime.now() - news_cache['last_update']).total_seconds() > 1800):
            print('更新新聞緩存...')
            news_cache['data'] = fetch_news_from_website()
            news_cache['last_update'] = datetime.now()
        
        return jsonify(news_cache['data'])
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/health')
def health_check():
    return jsonify({'status': 'ok', 'timestamp': datetime.now().isoformat()})

if __name__ == '__main__':
    port = 5000
    if is_port_in_use(port):
        print(f'錯誤：端口 {port} 已被占用')
        print('請關閉占用該端口的程序後重試')
        sys.exit(1)
    
    print(f'啟動新聞爬蟲服務器於 http://localhost:{port}')
    print('按 Ctrl+C 停止服務器')
    app.run(host='0.0.0.0', port=port) 