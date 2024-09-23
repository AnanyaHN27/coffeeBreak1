import requests
from bs4 import BeautifulSoup

url = 'https://stockq.org/moviescript/T/the-imitation-game.php'

response = requests.get(url)

soup = BeautifulSoup(response.content, 'html.parser')

content_divs = soup.find_all('div', class_='scrolling-script-container')

with open('../data/imitation_game.txt', 'w', encoding='utf-8') as f:
    for content in content_divs:
        f.write(content.get_text(strip=True) + '\n\n')

print("Content saved to imitation_game.txt")