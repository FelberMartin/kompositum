# TODOs    
## Next up
   
- Make continue button available faster after level completion
- Level generation:
  - Probabilistically add compounds before the minSolvableCompoundsInPool are reached
  - Make levels easier?
    - Variables: PoolSize, FrequencyClass, WordCount, GuaranteedCompoundCount
  - Add zigzag level generation? (a few easy ones, then getting harder, and then again dropping to easy and few compounds)

- Check out AppRadar
- Notification icon hardly visible in light mode


## Later
- Ads for the app
- Store adjustments:
  - Images on google play: remove debug label (just use gimp?)
  - A/B testing with v0 app icon
  - Create ad video


# Bugs
- B16 

## Not Reproducible
- B15 When pressing back shortly before the finished dialog opens, the continue button throws an error
- B09 App going to blackscreen after pressing "back to overview" button after completing daily from homescreen


# Misc
## Ideas
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
- Streak for daily Goals? (May be confusing with daily levels)


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

