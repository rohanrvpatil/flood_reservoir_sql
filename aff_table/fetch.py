import os
import requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from time import sleep

from dotenv import load_dotenv

load_dotenv()

aff_username=os.getenv("AFF_USERNAME")
aff_password=os.getenv("AFF_PASSWORD")


def get_session_cookie():
    driver = webdriver.Chrome()
    driver.get("https://aff.india-water.gov.in/")

    username_input = driver.find_element(By.NAME, "username")
    password_input = driver.find_element(By.NAME, "password")

    username_input.send_keys(aff_username)
    password_input.send_keys(aff_password)
    password_input.send_keys(Keys.RETURN)

    sleep(6)

    session_cookie = driver.get_cookie("PHPSESSID")

    driver.quit()

    if session_cookie:
        return session_cookie['value']
    else:
        raise Exception("Session cookie not found")

import requests

def access_protected_page(session_cookie):
    cookies = {
        'PHPSESSID': session_cookie
    }

    headers = {
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.6',
        'Cache-Control': 'max-age=0',
        'Connection': 'keep-alive',
        'Referer': 'https://aff.india-water.gov.in/home.php',
        'Sec-Fetch-Dest': 'document',
        'Sec-Fetch-Mode': 'navigate',
        'Sec-Fetch-Site': 'same-origin',
        'Sec-Fetch-User': '?1',
        'Sec-GPC': '1',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36',
        'sec-ch-ua': '"Chromium";v="130", "Brave";v="130", "Not?A_Brand";v="99"',
        'sec-ch-ua-mobile': '?0',
        'sec-ch-ua-platform': '"Windows"',
    }

    response = requests.get("https://aff.india-water.gov.in/table.php", headers=headers, cookies=cookies)

    if response.status_code == 200:
        print("Page accessed successfully!")
        with open("response.html", "w", encoding="utf-8") as file:
            file.write(response.text)
    else:
        print(f"Failed to access page: {response.status_code}")


try:
    session_cookie_value = get_session_cookie()
    access_protected_page(session_cookie_value)
except Exception as e:
    print(f"Error: {e}")
