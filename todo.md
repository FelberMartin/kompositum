# TODOs    
## 1.0 Release
### Ad hoc

- Remove unused generators
- Add tips feature
- Remove compounds with no frequency data (NaN) 
  - maybe also remove eg >= 25
- Make the shuffling of the components in the UI dependent on seed?
  + Different experience from user to user
  - When exiting the app and doing the same level again, other components are shown
- Store level progress on device
- Advanced LevelProvider (use different difficulties)
- Optimize database loading speed

### UI Design
- Decide for a color scheme
- Design pages in figma
- Implement design in flutter
- App icon
- App name

### Daily levels
- Prepare backend
- New home screen
- Calendar


# Bugs
- App is blackscreen when restarting it on phone (just a long loading time?)
- When restarting the app the lastNCompounds of the Pool generator are not remembered
  -> The levels are now different too, because the input compounds are different depending on 
      whether the lastNCompounds is empty or not.
