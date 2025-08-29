# Geometric 2D Platformer

### Description

#### Jump, squish, and conquer in the ultimate 2D platformer adventure!

Take control of the adorable Green Squario as you bounce through beautifully crafted levels filled with challenging obstacles and squishy orange blob enemies. With precise controls and satisfying gameplay, every jump counts in this delightfully addictive platformer.

#### Features:

-   Classic Platforming Action - Master the art of jumping and timing to navigate through increasingly challenging levels
-   Enemy Squishing Fun - Defeat orange blob enemies by jumping on them for maximum satisfaction
-   Coin Collection - Gather coins throughout your adventure to unlock new abilities and customizations
-   Multiple Character Skins - Customize your square hero with blue, pink, and other colorful variants from the in-game shop
-   Smooth Controls - Responsive touch controls designed specifically for mobile gaming
-   Beautiful Art Style - Clean, vibrant graphics that pop on any device
-   Progressive Difficulty - Easy to learn, challenging to master gameplay that keeps you coming back
-   Level Selection - Choose your favorite levels to replay and perfect your runs

### Developer Notes

-   Godot version: 4.2.2

#### AdMob

Looking like I need to do all this ad stuff each time I export since I can't get Active Development to work, which frankly sucks. See [godot-admob-plugin documentation](https://poingstudios.github.io/godot-admob-plugin/#__tabbed_2_2) (starting at step 6).

##### NEXT TIME I NEED TO USE COCOAPODS:

This note is specifically for working from my personal mac mini. If you need to do anything with CocoaPods, first disable rbenv by running `rbenv shell system`. Very long story. May as well uninstall rbenv but that looks like a cluster, and I need to move on.

#### Deploying to Apple App Store

**Upload Process**
1. Archive Your App in Xcode:
    - Set your build target to "Any iOS Device" (not simulator)
    - Go to Product → Archive
    - Wait for the archive to complete

2. Upload via Xcode Organizer:
    - The Organizer window should open automatically after archiving
    - Select your archive and click "Distribute App"
    - Choose "App Store Connect" as the distribution method
    - Select "Upload" (not "Export")
    - Choose your team and provisioning profile
    - Review and upload

**After Upload**

- Your build will appear in App Store Connect within 10-90 minutes
- You can then create your app listing, add metadata, screenshots, etc.
- Submit for review once everything is configured
