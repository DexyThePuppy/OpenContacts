@echo off
cls
echo *Excited bark* Deep cleaning everything...

echo Removing build directory...
rd /s /q build

echo Removing .dart_tool...
rd /s /q .dart_tool

echo Removing windows/flutter/ephemeral...
rd /s /q windows\flutter\ephemeral

echo Cleaning pub cache...
flutter pub cache repair

echo Getting packages...
flutter pub get

echo Clean complete! *tail wag*
pause 