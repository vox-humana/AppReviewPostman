![Build](https://github.com/vox-humana/AppReviewPostman/workflows/Build/badge.svg)
# App Store Reviews Postman

Swift script that checks new app store reviews in every App Store country, formats them right and sends into your favourite messenger via HTTP POST hook.

In this example postman sends two latest [Github iOS app](https://apps.apple.com/app/github/id1477376905) reviews from 🇸🇪Sweden and 🇦🇺Australian App Store to a [Telegram](https://telegram.org) channel:  
```
./Postman --countries=au,se --post-url=https://api.telegram.org/bot${TOKEN}/sendMessage  
--template='{"chat_id": "'${CHAT_ID}'", "text": "{{stars}}\n{{message}}\n{{contry_flag}} {{author}}"}' 1477376905
```
> ★★★★★  
> GitHub is by far the best, not only because it’s the only one out there to offer a great mobile app (where you can even browse the source code) but also because its UI is sooo gooood!!!!!  
> 🇦🇺 ph7enry

The same use case but posting in [TamTam](https://tamtam.chat) channel instead:
```
./Postman --countries=au,se --post-url="https://botapi.tamtam.chat/messages?access_token=${TOKEN}&chat_id=${CHAT_ID}"  
--template='{"text": "{{stars}}\n{{message}}\n{{contry_flag}} {{author}}"}' 1477376905
```

### Full usage
```
USAGE: get-feed <app-id> [--countries <countries>] --template <template> --post-url <post-url> [--storage-file <storage-file>]

ARGUMENTS:
  <app-id>                App identifier to get feed for 

OPTIONS:
  --countries <countries> Comma-separated list of country codes 
  --template <template>   Mustache template for formatting reviews 
  --post-url <post-url>   Callback URL where a review will be posted to 
  --storage-file <storage-file>
                          Last sent review file path 
```
