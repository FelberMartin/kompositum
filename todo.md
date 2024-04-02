# TODOs    
## 1.0 Release
### Next up
- Store whether audio is muted


### Later
- LevelFinishedDialog: diamonds for used attempts confusing (remove diamonds for attempts, or
  write "2/3", 
- Images on google play: remove debug label (just use gimp?)


# Bugs
- B09 
- B08 Noerl: When quickly taping words after a right word pair is combined to a compound, one loses one attempt.
- B07 When closing the app when the NoAttemptsLeftDialog is shown and then reopening one can get to -1/5 attempts.
- B02 Sounds are not always played consistently


### Misc
- Hint idea: reshuffle components in pool / hidden components
- Feature idea: watch ad to double level finished rewards
- Spinning wheel after completion / noAttemptsLeft?
- Feature idea: Catalogues of collected words (for easy/medium/hard)
- Feature idea: instead of simple level progress, divide into sections. Each section could reward
  eg a trophy (emoji) 
  - Maybe spinning wheel for which trophy to get?
  - Or for collecting 100 words one can spin to get a trophy
- Level completion dialog title depending on performance
- Gameplay idea: When starting a new level, a first modifier is already selected.
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

