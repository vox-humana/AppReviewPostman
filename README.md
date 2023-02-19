![Build](https://github.com/vox-humana/AppReviewPostman/workflows/Build/badge.svg)
[![Swift 5.7](https://img.shields.io/badge/Swift-5.7-yellow.svg)](https://developer.apple.com/swift)
![Platforms](https://img.shields.io/badge/platforms-Linux%2C%20macOS-lightgrey.svg)

# App Store Reviews Postman

Swift script that checks new app store reviews in every App Store country, formats them right and sends into your favourite messenger via HTTP POST hook.

In this example postman sends two latest [Github iOS app](https://apps.apple.com/app/github/id1477376905) reviews from 🇸🇪Sweden and 🇦🇺Australian App Store to a [Telegram](https://telegram.org) channel:  
```
postman 1477376905 --countries=au,se  
--post-url=https://api.telegram.org/bot${TOKEN}/sendMessage  
--template='{"chat_id": "'${CHAT_ID}'", "text": "{{stars}}\n{{message}}\n{{country_flag}} {{author}}"}'  
```
> ★★★★★  
> GitHub is by far the best, not only because it’s the only one out there to offer a great mobile app (where you can even browse the source code) but also because its UI is sooo gooood!!!!!  
> 🇦🇺 ph7enry

The same use case but posting in [TamTam](https://tamtam.chat) channel instead:
```
postman 1477376905 --countries=au,se  
--post-url="https://botapi.tamtam.chat/messages?access_token=${TOKEN}&chat_id=${CHAT_ID}"  
--template='{"text": "{{stars}}\n{{message}}\n{{country_flag}} {{author}}"}'
```

### Full usage
```
USAGE: postman <app-id> [--countries <countries>] --template <template> --post-url <post-url> [--storage-file <storage-file>] [--translator <translator>]

ARGUMENTS:
  <app-id>                App identifier

OPTIONS:
  --countries <countries> Comma-separated list of two-letter country codes according to 'ISO 3166-1 alpha-2'

                          (default: all countries)
  --template <template>   Mustache template for formatting reviews. 
                          Supported keys: author, country, country_flag, message, translated_message, stars
  --post-url <post-url>   Callback url for sending formatted messages
  --storage-file <storage-file>
                          Last sent reviews file path
  --translator <translator>
                          IBM Language Translator url and apikey in {url},{apikey} format
  -h, --help              Show help information.
```
