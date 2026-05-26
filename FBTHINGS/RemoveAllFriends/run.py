# RemoveAllFriends - run.py
#-------------------------------------------------------------------------------------------
# What it does it runs trough your friends list and remove one by one if not in allowed.txt
#-------------------------------------------------------------------------------------------
#

import time
from datetime import datetime
import getopt, sys, signal
import os.path
import json
from threading import Thread
import requests
#
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys
import selenium.webdriver.support.ui as ui

#--
# FUNCTIONS
#--
#
def my_login(driver):
    global options, jsCheckLogin, jsLogin
    print("my_login() Title: {}".format(driver.title))
    while True:
        tmp = driver.execute_script(jsCheckLogin)
        if tmp=="0":
            print("my_login() Logging in...")
            driver.execute_script( jsLogin )
        else:
            print("my_login() Logged in. Continuing...")
            break
        time.sleep(5)

#--
#webdriver.ChromeOptions()
options = Options()
#options.binary_location = "/Applications/Google Chrome.app"
#options.add_argument("--headless")
#options.add_argument("--window-size=1280x1024")
options.add_argument("--no-sandbox=true")
options.add_argument("--disable-dev-shm-usage")
options.add_argument("--disable-extensions")
options.add_argument("--disable-gpu")
options.add_argument("--disable-notifications")
options.add_argument("--remote-debugging-port=9222")
#options.add_argument("/Users/t3ch/Projects/DrDave/scrap/profile")
options.add_argument("--user-data-dir=/home/t3ch/snap/chromium/common/chromium")
#options.binary_location = "/usr/bin/chromium-browser"
#options.binary_location = "/snap/bin/brave"
options.add_experimental_option("prefs", { 
    "profile.default_content_setting_values.notifications": 2 
})


# continue
drv = webdriver.Chrome(options=options)
drv.get("https://www.facebook.com")
print("run_background() Title: {}".format(drv.title))

#--
# login
my_login(drv)

#--
# quit
drv.close()
