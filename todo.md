# TODOs    
## 1.0 Release
### Next up

- Add basics for word collection?

### Later
- Keep Gradients on 3d_containers?
- Progress bar?


# Bugs
- App is blackscreen when restarting it on phone (just a long loading time?)


### Misc
- Spinning wheel after completion / noAttemptsLeft?
- Remark by Felix: do not hide components. Instead make pool scrollable
- Gameplay idea: When starting a new level, a first modifier is already selected.
- English compounds?
- Feature idea: Catalogues of collected words (for easy/medium/hard)
- Feature idea: instead of simple level progress, divide into sections. Each section could reward
  eg a trophy (emoji) 
  - Maybe spinning wheel for which trophy to get?
  - Or for collecting 100 words one can spin to get a trophy
- Feature idea: watch ad to double level finished rewards


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
- Advanced guide on first launch?

