import requests 
import json
import urllib
import os


project_api = os.environ["poeditor_api"]
project_id = os.environ["poeditor_id"]

print("Getting languages list")
r_langs = requests.post('https://api.poeditor.com/v2/languages/list', dict(api_token=project_api, id=project_id))

json_langs = json.loads(r_langs.text)
for lang in json_langs['result']['languages']:
      print("Downloading PO file:",lang['code'])
      r_lang = requests.post('https://api.poeditor.com/v2/projects/export', dict(api_token=project_api, id=project_id, language=lang['code'], type="po"))
      json_lang = json.loads(r_lang.text)
      url = json_lang['result']['url']
      filename = './' + lang['code'] + '.po'
      urllib.request.urlretrieve(url, filename)