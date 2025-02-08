# Twitch Menubar Application

## Main Goals
- Notify you when any of your followed Twitch channels go live.
- Display a compact window listing all followed channels and their live status—no need to open Twitch.
- Lightweight—minimal battery usage and limited background activity.
- Smooth onboarding process (this might be a challenge).

## Disclaimer
I know nothing about macOS application development, and my Swift knowledge is limited. It's a strange language, and the documentation isn't great. Beyond using LLMs to figure things out, there's not much hope. I also have no clue how to make pretty UIs in Swift—probably a skill issue. 

There might be weird practices in this code. Sorry. But it works!

## Roadmap
Unfortunately, Apple requires a $100 developer subscription to enable useful features (like sending notifications). Because of this, the app might not evolve much further. This was primarily a project to see how quickly I could ship a semi-decent working app. Honestly, it does almost everything I need it to right now.

## Screenshots & Functionality
Since it's difficult to run the app, here are some screenshots.

### 1. User signs in using their Twitch account
<img src="images/oauth.png?raw=true" alt="OAuth" width="100%">

### 2. User opens the menu bar application
<img src="https://github.com/boopdotpng/twitch-menubar/blob/master/images/menu.png" alt="Menu" width="400">

### 3. User searches for a channel
<img src="https://github.com/boopdotpng/twitch-menubar/blob/master/images/search.png" alt="Search" width="400">

### 4. User can press enter to open the first search result in their browser

### Additional Features
- Sends notifications when a followed streamer goes live (disabled due to lack of a developer account).
- Automatically updates every two minutes to keep the live channel list fresh.

