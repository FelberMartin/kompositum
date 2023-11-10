# TODOs    
## 1.0 Release
### Next up

- Save blocked components to key Value store and load them at app start
- How to deal with "Maschinenbau" <-> "Baumaschinen" ?
- Add attempts counter 
- Add second csv file with manually added compounds that were not in the dataset
- Make the graph case insensitive?
- Collect stars with each word + level

### Later
- Optimize database loading speed

### UI Design
- Decide for a color scheme
- Design pages in figma
- Implement design in flutter
- App icon
- App name
- Large Texts in the Chips/Animation

### Daily levels
- Prepare backend
- New home screen
- Calendar

### Misc
- Make the shuffling of the components in the UI dependent on seed?
    + Different experience from user to user
    - When exiting the app and doing the same level again, other components are shown
- Feature idea: when selecting a compound that is not recognized, option to send report
  - eg via firebase take request and store unknown compounds
  - UI: "an + Sicht should result in which compound? _____ Submit"
- English compounds?

# Bugs
- App is blackscreen when restarting it on phone (just a long loading time?)
- When restarting the app the lastNCompounds of the Pool generator are not remembered
  -> The levels are now different too, because the input compounds are different depending on 
      whether the lastNCompounds is empty or not.
