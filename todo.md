# TODOs    
## 1.0 Release
### Next up
- Daily goals:
  - Dont show on homeScreen? 
    - -> if still, then adapt title color 
    - test whether goal on home screen are updated correctly
  - Remove reset button in settings
  - Look for todos in code
  - Chain Level: title show chain level (only use medium or custom compactFrequencyClass)
    - Add lock indicator to current modifier
- Locking?
  - Dailies at lvl 30
  - Daily Goals at lvl 50
- Level generation:
  - Probabilistically add compounds before the minSolvableCompoundsInPool are reached
  - Make levels easier?
    - Variables: PoolSize, FrequencyClass, WordCount, GuaranteedCompoundCount
  - Add zigzag level generation? (a few easy ones, then getting harder, and then again dropping to easy and few compounds)
- Redesign?
  - Remove oval borders -> rounded corner rectangle
  - Light / Dark mode
- Ads
  - Real ads inside the app
  - Ads for the app

### Later
- LevelFinishedDialog: diamonds for used attempts confusing (remove diamonds for attempts, or
  write "2/3", 
- Store adjustments:
  - Images on google play: remove debug label (just use gimp?)
  - A/B testing with v0 app icon
  - Create ad video


# Bugs
- B15 When pressing back shortly before the finished dialog opens, the continue button throws an error
- B09 App going to blackscreen after pressing "back to overview" button after completing daily from homescreen
  -> not reproducable 


### Misc
- Look for alternative frequency dataset (not from news)
- Hint idea: reshuffle components in pool / hidden components
- Feature idea: watch ad to double level finished rewards
- Spinning wheel after completion / noAttemptsLeft?
- Feature idea: Catalogues of collected words (for easy/medium/hard)
- Feature idea: instead of simple level progress, divide into sections. Each section could reward
  eg a trophy (emoji) 
  - Maybe spinning wheel for which trophy to get?
  - Or for collecting 100 words one can spin to get a trophy
- Level completion dialog title depending on performance
- English compounds?


## After 1.0 Release
- More game modes
  - See notion page
  - Redesign home page
- UI Improvements:
  - Keep common UI components on screen, and only change children during navigation
    - BottomTabBar
    - AppBar
    - FlyStarAnimation
  - Animate component move in pool: maybe have to create Wrap widget as stack
- Tablet compatibility
- Advanced guide on first launch?

