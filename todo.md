# TODOs    
## 1.0 Release
### Next up


- There are two words in the datat where "werk" is in lower case -> correct this
- Level complete dialog
- Animations:
  - Show/hide dialogs
  - Expand components in combination area
  - Animate component appear/move/remove in pool
  - hiddenComponent counter fade out / count down
  - Icon button click
  - Button: decide for border or 3d -> then animation
  - Background as in figma
- Sound
  - Create/play sounds
  - Mute button
- Home screen
- Daily levels

### Later
- Ads?
- Optimize database loading speed
- Progress bar?

### UI Design
- Implement design in flutter
- App icon
- App name
- How to deal with Large Texts in the Chips/Animation?
- Sound Design

### Daily levels
- Prepare backend
- New home screen
- Calendar

### Misc
- Remark by Felix: do not hide components. Instead make pool scrollable
- Gameplay idea: When starting a new level, a first modifier is already selected.
- Make the graph case insensitive? Would maybe result in less reported conflicts
- English compounds?

# Bugs
- Possible bug: Shown=[Baum, Haus, Tür], generated hint is "Baum + Haus" but user removes "Haus + Tür",
  then "Baum" remains with a hint, but if the other "Haus" component is still in the hidden components,
  generating a new hint will produce probably an error.
- App is blackscreen when restarting it on phone (just a long loading time?)
- When restarting the app the lastNCompounds of the Pool generator are not remembered
  -> The levels are now different too, because the input compounds are different depending on 
      whether the lastNCompounds is empty or not.

# After 1.0 Release
- Report functionality:
  - Add second csv file with manually added compounds that were not in the dataset
  - Make compound graph case insensitive? (reduce number of reports?)
  - Database: Allow multiple compounds with the same compound text (use UUID), to allow multiple 
    valid combinations for a compound.
