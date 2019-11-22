# Fragebogengenerator

## Android Studio Projekt verwenden

Ihr müsst das Android Studio Projekt neu öffnen, da sich die Ordnerstruktur verändert hat. Öffnet dazu in Android Studio das Projekt bzw. den Ordner "android-app", _nicht das Projekt "app"!_. 

## CI/CD verwenden

Nach jedem Commit auf den master-Branch wird ein Build von der WebApp erstellt und auf 
  [users.informatik.uni-halle.de/~anfvg](http://users.informatik.uni-halle.de/~anfvg) 
hochgeladen.

## Electron-App bauen

* Elm [installieren](https://guide.elm-lang.org/install.html)

* Node.js [installieren](https://nodejs.org/en/download/) 

* In das Verzeichnis electron-app wechseln

* Die Kommandozeile (cmd.exe) öffnen, nicht die PowerShell!

* Beim ersten Build `install_electron.bat` ausführen

* In der Kommandozeile `build.bat` ausführen, um einen Build zu erstellen

* In dem Verzeichnis `electron-app` finden sich die fertigen Builds

## Web-App bauen

* Elm [installieren](https://guide.elm-lang.org/install.html)

* Im Verzeichnis `web-app` folgenden Befehl ausführen:
```
elm make src\Main.elm --output src\elm.js
```

## Link zur Elm-Referenz
* [package.elm-lang.org](https://package.elm-lang.org/)

## Link zum CSS-Framework Bulma:
* [bulma.io](https://bulma.io)