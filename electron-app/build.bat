cd ..\web-app
elm make src\Main.elm --output ..\electron-app\elm.js
cd ..
xcopy web-app\src\*.js electron-app\ /Y
xcopy web-app\src\*.css electron-app\ /Y
xcopy web-app\src\index.html electron-app\ /Y
cd electron-app
electron-packager . Fragebogengenerator --platform=win32 --arch=all --overwrite