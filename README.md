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
Unfortunately, Apple requires a $100 developer subscription to enable useful features (like sending notifications). Because of this, the app might not evolve much further. This was primarily a project to see how quickly I could ship a semi-decent working app.

## Screenshots & Functionality
Since no one else can run the app, here are screenshots demonstrating its functionality:

### 1. User signs in using their Twitch account
![OAuth](images/oauth.png?raw=true)

### 2. User opens the menu bar application
![Menu](images/menu.png?raw=true)

### 3. User searches for a channel
![Search](images/search.png?raw=true)

### 4. User can press enter to open the first search result in their browser

### Additional Features
- Sends notifications when a followed streamer goes live (disabled due to lack of a developer account).
- Automatically updates every two minutes to keep the live channel list fresh.

This was a fun experiment, and despite Swift's quirks, the app works surprisingly well. If I ever decide to get an Apple Developer account, maybe I'll polish it further!

