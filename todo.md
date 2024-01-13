# TODOs    
## 1.0 Release
### Next up

- Improve Level completed dialog
  - Use different congratualations (Siuu, Nicee, Tadaaaa, )
- Daily levels
  - extra daily completion dialog? (with option to continue classic mode)
- Also store attemptsCounter progress during games
- Sound
  - Create/play sounds
  - Mute button
  - Vibrate after level/word-completion
  - Easter eggs (Apfelsaft, Orangensaft)
- Spinning wheel after completion / noAttemptsLeft?

### Later
- Check whether animations are still laggy in non-debug build (-> maybe remove add/remove component animation)
- Progress bar?
- Optimize database loading speed (it is currently only loaded when generating the first level)
- Ads? (replace placeholder ads)
- Guide on first launch? (or at least take directly to Level1 and skip homepage)
- Fix overflows

### UI Design
- App icon
- App name

# Bugs
- App is blackscreen when restarting it on phone (just a long loading time?)


### Misc
- Remark by Felix: do not hide components. Instead make pool scrollable
- Gameplay idea: When starting a new level, a first modifier is already selected.
- English compounds?
- Feature idea: Catalogues of collected words (for easy/medium/hard)
- Feature idea: instead of simple level progress, divide into sections. Each section could reward
  eg a trophy (emoji) 
  - Maybe spinning wheel for which trophy to get?
  - Or for collecting 100 words one can spin to get a trophy


## After 1.0 Release
- Further Report functionality:
  - Add second csv file with manually added compounds that were not in the dataset
  - Make compound graph case insensitive? (reduce number of reports?)
  - Database: Allow multiple compounds with the same compound text (use UUID), to allow multiple 
    valid combinations for a compound.
- More game modes
- UI Improvements:
  - Indicate compound completion in the combination area (eg flash big textbuttons)
  - Keep common UI components on screen, and only change children during navigation
    - BottomTabBar
    - AppBar
    - FlyStarAnimation
  - Animate component move in pool: maybe have to create Wrap widget as stack
- Tablet compatibility

