# paycool

## Flutter launcher icons
flutter pub get
flutter pub run flutter_launcher_icons:main

### IOS Issue: GeneratedPluginRegistrant.h:8:9: 'Flutter/Flutter.h' file not found
### Solution: 
1. rm -rf ios
2. flutter create -i swift .
3. flutter clean

flutter pub upgrade --major-versions

dart pub get
dart analyze
dart migrate --apply-changes

dart fix --dry-run
dart fix --apply

flutter pub cache repair

## Java version issues
Error: Execution failed for task ':app:processReleaseMainManifest'.


Check your project's java version using 
flutter doctor --verbose
then take the value from
Java version OpenJDK Runtime Environment (build 17.0.6+0-17.0.6b802.4-9586694)
https://docs.gradle.org/current/userguide/compatibility.html#java
then update     classpath 'com.android.tools.build:gradle:7.0.4' in android/buid.gradle
https://developer.android.com/build/releases/gradle-plugin#updating-plugin
then use above links for comaptible gradle version to update in graddle-wrapper.properties