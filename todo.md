# TODOs    
## 1.0 Release
### Next up

- Animations:
  - Animate component move in pool
  - Animate remove/add in pool
  - Icon button click (also use 3dcontainer)
- How to deal with Large Texts in the Chips/Animation?
  - Also check Report dialog
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
- Make the graph case insensitive? Would maybe result in less reported conflicts
- English compounds?

# Bugs
- Possible bug: Shown=[Baum, Haus, Tür], generated hint is "Baum + Haus" but user removes "Haus + Tür",
  then "Baum" remains with a hint, but if the other "Haus" component is still in the hidden components,
  generating a new hint will produce probably an error.
- App is blackscreen when restarting it on phone (just a long loading time?)

# After 1.0 Release
- Report functionality:
  - Add second csv file with manually added compounds that were not in the dataset
  - Make compound graph case insensitive? (reduce number of reports?)
  - Database: Allow multiple compounds with the same compound text (use UUID), to allow multiple 
    valid combinations for a compound.
