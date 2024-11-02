@echo off
call cls
echo *Happy tail wags* Starting Windows build process...

echo Cleaning previous build...
call flutter clean

echo Getting dependencies...
call flutter pub get

echo Building Windows app...
call flutter run -d windows -v

echo Build process complete! *excited bark*
pause 