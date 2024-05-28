# TODOs    
## 1.0 Release
### Next up
- Locking?
  - Dailies at lvl 30
  - Daily Goals at lvl 50
  
- Real ads inside the app
 
- Level generation:
  - Probabilistically add compounds before the minSolvableCompoundsInPool are reached
  - Make levels easier?
    - Variables: PoolSize, FrequencyClass, WordCount, GuaranteedCompoundCount
  - Add zigzag level generation? (a few easy ones, then getting harder, and then again dropping to easy and few compounds)



### Later
- Ads for the app
- Store adjustments:
  - Images on google play: remove debug label (just use gimp?)
  - A/B testing with v0 app icon
  - Create ad video


# Bugs
- B15 When pressing back shortly before the finished dialog opens, the continue button throws an error
  -> not reproducable
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


## Maybe backlog
- Redesign?
  - Remove oval borders -> rounded corner rectangle
  - Light / Dark mode
- UI Improvements:
  - Keep common UI components on screen, and only change children during navigation
    - BottomTabBar
    - AppBar
    - FlyStarAnimation
  - Animate component move in pool: maybe have to create Wrap widget as stack
- Tablet compatibility

