# TODOs    
## 1.0 Release
### Next up

- Increase tip costs by attempts
- Daily levels
  - Animate day state changes (selected / completed)
  - How to play past dailies?
    - Show cost with start button (eg. 100 stars / ad)
    - Show dialog similar to outOfAttempts
  - Special reward after completing month?
  - extra daily completion dialog? (with option to continue classic mode)
  - In overview page, automatically focus the next playable daily
- Sound
  - Create/play sounds
  - Mute button
  - Vibrate after level/word-completion
  - Easter eggs (Apfelsaft, Orangensaft)
- Improve Level completed dialog
- Spinning wheel after completion / noAttemptsLeft?
- Alternative color pallet? -> figma (yellow blue)

### Later
- Check whether animations are still laggy in non-debug build (-> maybe remove add/remove component animation)
- Progress bar?
- Optimize database loading speed
- Ads?

### UI Design
- App icon
- App name
- Sound Design

# Bugs
- The progress within one level is not stored, so one can "cheat" stars, by replaying the same level,
  but stopping before level completion, the stars collected so far will consist.
- Possible bug: Shown=[Baum, Haus, Tür], generated hint is "Baum + Haus" but user removes "Haus + Tür",
  then "Baum" remains with a hint, but if the other "Haus" component is still in the hidden components,
  generating a new hint will produce probably an error.
- App is blackscreen when restarting it on phone (just a long loading time?)
- 


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

