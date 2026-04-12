# How to build and distribute the app

### Update the Version

In `pubspec.yaml`

## How to create a new app release file to upload

### Android

- In Android Studio, go to "Build">"Flutter">"Build App Bundle".
- Then drag the created .aab file into the Google Play Dashboard (Create new internal release).

### iOS

- In the terminal, run `flutter build ipa` (takes ages)
- Open the `build/ios/archive/MyApp.archive` with XCode
- First "Validate App", then "Distribute App" to send it to testflight
- In the AppStoreConnect, in tab "TestFlight", wait for the version to become "Ready to submit"
- In tab "Distribution", create new release (+ button on the top left) and add the build version