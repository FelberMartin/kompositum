# TODOs    
## 1.0 Release
### Next up

- Daily levels
  - How to play past dailies?
    - Show cost with start button (eg. 100 stars / ad)
  - Special reward after completing month?
  - extra daily completion dialog?
- Animate star increase
- Sound
  - Create/play sounds
  - Mute button
- Improve Level completed dialog

### Later
- Check whether animations are still laggy in non-debug build (-> maybe remove add/remove component animation)
- Animate component move in pool: maybe have to create Wrap widget as stack
- Progress bar?
- Optimize database loading speed
- Ads?

### UI Design
- App icon
- App name
- Sound Design

### Daily levels
- Prepare backend
- New home screen
- Calendar

### Misc
- Remark by Felix: do not hide components. Instead make pool scrollable
- Gameplay idea: When starting a new level, a first modifier is already selected.
- English compounds?
- Feature idea: Catalogues of collected words (for easy/medium/hard)
- Feature idea: instead of simple level progress, divide into sections. Each section could reward
  eg a trophy (emoji) 
  - Maybe spinning wheel for which trophy to get?
  - Or for collecting 100 words one can spin to get a trophy

# Bugs
- The progress within one level is not stored, so one can "cheat" stars, by replaying the same level,
  but stopping before level completion, the stars collected so far will consist.
- Possible bug: Shown=[Baum, Haus, Tür], generated hint is "Baum + Haus" but user removes "Haus + Tür",
  then "Baum" remains with a hint, but if the other "Haus" component is still in the hidden components,
  generating a new hint will produce probably an error.
- App is blackscreen when restarting it on phone (just a long loading time?)

# After 1.0 Release
- Further Report functionality:
  - Add second csv file with manually added compounds that were not in the dataset
  - Make compound graph case insensitive? (reduce number of reports?)
  - Database: Allow multiple compounds with the same compound text (use UUID), to allow multiple 
    valid combinations for a compound.
- More game modes
