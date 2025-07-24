IMPORTANT: APP ICON SETUP INSTRUCTIONS

You have an SVG icon file (app_icon.svg) that needs to be converted to PNG format.

STEP-BY-STEP GUIDE:

1. CONVERT SVG TO PNG (Choose one method):

   Method A - Online Converter (EASIEST):
   • Go to: https://convertio.co/svg-png/
   • Upload: app_icon.svg (from this folder)
   • Set output size: 1024x1024 pixels
   • Download the result as: app_icon.png
   • Save it in this same folder (assets/icons/)

   Method B - Using GIMP (Free software):
   • Download GIMP from: https://www.gimp.org/downloads/
   • Open GIMP → File → Import → select app_icon.svg
   • Set import size to 1024x1024 pixels
   • File → Export As → app_icon.png
   • Save in this folder

2. GENERATE APP ICONS:
   After you have app_icon.png in this folder, run these commands:

   flutter pub get
   flutter pub run flutter_launcher_icons:main

3. REBUILD THE APP:
   flutter clean
   flutter build apk --debug

The new icon will be a blue shield with "RAKSHA" text and a security lock symbol, 
perfect for your banking/security app!

Current folder contents should include:
- app_icon.svg (✓ created)
- app_icon.png (you need to create this)
- This instruction file
