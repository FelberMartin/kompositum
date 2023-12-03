# TODOs    
## 1.0 Release
### Next up

- Add tests for game_page
- Re-adjust level generation: more words for "easy" do not add more words for "hard"
- Add second csv file with manually added compounds that were not in the dataset
- Collect stars with each word + level

### Later
- Optimize database loading speed

### UI Design
- Decide for a color scheme
- Design pages in figma
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
- Gameplay idea: When starting a new level, a first modifier is already selected.
- Make the graph case insensitive? Would maybe result in less reported conflicts
- Feature idea: when selecting a compound that is not recognized, option to send report
  - eg via firebase take request and store unknown compounds
  - UI: "an + Sicht should result in which compound? _____ Submit"
- English compounds?

# Bugs
- Hint generation: When compound consists of the same two components (e.g Kind + Kind = Kindeskind)
  and only one component in shown in the pool, a hint can get generated for "Kind". Could also cause 
  the generation to believe that there is a finishable compound in the pool even the is none.
- Possible bug: Shown=[Baum, Haus, Tür], generated hint is "Baum + Haus" but user removes "Haus + Tür",
  then "Baum" remains with a hint, but if the other "Haus" component is still in the hidden components,
  generating a new hint will produce probably an error.
- App is blackscreen when restarting it on phone (just a long loading time?)
- When restarting the app the lastNCompounds of the Pool generator are not remembered
  -> The levels are now different too, because the input compounds are different depending on 
      whether the lastNCompounds is empty or not.
