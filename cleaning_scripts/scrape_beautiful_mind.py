import requests
from bs4 import BeautifulSoup

url = 'https://transcripts.foreverdreaming.org/viewtopic.php?t=41855'

response = requests.get(url)

soup = BeautifulSoup(response.content, 'html.parser')

content_divs = soup.find_all('div', class_='content')

with open('beautiful_mind.txt', 'w', encoding='utf-8') as f:
    for content in content_divs:
        f.write(content.get_text(strip=True) + '\n\n')

print("Content saved to beautiful_mind.txt")