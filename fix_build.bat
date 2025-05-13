@echo off
echo Cleaning project...
flutter clean

echo Getting dependencies...
flutter pub get

echo Generating code...
flutter pub run build_runner build --delete-conflicting-outputs

echo Done! Please reopen your project.
pause 