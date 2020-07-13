# App Store Reviews Postman

Swift script that checks new app store reviews in every AppStore country, formats it right and sends it to your favourite messenger via HTTP POST hook.

In this example postman sends two latest reviews from Sweden and Australian AppStores on Github iOS app to a Telegram channel:  
```
Postman --countries=au,se --post-url=https://api.telegram.org/[BOT_KEY]/sendMessage --template='{"chat_id": "[CHAT_ID]", "text": "{{stars}}\n{{message}}\n{{contry_flag}} {{author}}"}' 1477376905
```
