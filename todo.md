# TODOs    
## 1.0 Release
### Next up
- Push new version with share button + new reports
- Test file restructuring: move mocks to mock folder

### Later
- Show combined words longer (or show history, or show longer if it took longer to find)
- LevelFinishedDialog: diamonds for used attempts confusing (remove diamonds for attempts, or
  write "2/3", 
- Images on google play: remove debug label (just use gimp?)
- Make dailies easier (or more variance) ?


# Bugs
- B04 After restarting a level with ads, the new words are different than before
- B05 Mama: used 15 attempts (shown in completed dialog), but no AllAttemptsUsed dialog is shown (level 109)
- B01 Andreas: 3 components were removed from pool, apparently by tapping twice quickly on two 
  different components, and there was a correct compound within them 
  -> Non reproducible, version 1.0.0 
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
  - Indicate compound completion in the combination area (eg flash big textbuttons, or the plus sign)
  - Keep common UI components on screen, and only change children during navigation
    - BottomTabBar
    - AppBar
    - FlyStarAnimation
  - Animate component move in pool: maybe have to create Wrap widget as stack
- Tablet compatibility
- Advanced guide on first launch?

