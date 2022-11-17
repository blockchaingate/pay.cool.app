# paycool

## Flutter launcher icons
flutter pub get
flutter pub run flutter_launcher_icons
or
flutter pub add flutter_launcher_icons
flutter pub run flutter_launcher_icons:main

### IOS Issue: GeneratedPluginRegistrant.h:8:9: 'Flutter/Flutter.h' file not found
### Solution: 
1. rm -rf ios
2. flutter create -i swift .
3. flutter clean
            