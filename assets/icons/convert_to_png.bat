@echo off
echo.
echo ========================================
echo    RAKSHA APP ICON CONVERSION GUIDE
echo ========================================
echo.
echo You need to convert the app_icon.svg to app_icon.png
echo.
echo METHOD 1 - Online Converter (Easiest):
echo 1. Go to https://convertio.co/svg-png/
echo 2. Upload app_icon.svg from this folder
echo 3. Set size to 1024x1024 pixels
echo 4. Download as app_icon.png
echo 5. Place the PNG file in this same folder
echo.
echo METHOD 2 - Free Software:
echo 1. Download GIMP (free): https://www.gimp.org/downloads/
echo 2. Open GIMP
echo 3. File ^> Import ^> select app_icon.svg
echo 4. Set import size to 1024x1024
echo 5. File ^> Export As ^> app_icon.png
echo.
echo After creating app_icon.png, run these commands:
echo   flutter pub get
echo   flutter pub run flutter_launcher_icons:main
echo.
echo This will generate all the required icon sizes for your app.
echo.
pause
