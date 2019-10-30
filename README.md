# Fragebogengenerator

## Android Studio Projekt verwenden

Ihr müsst das Android Studio Projekt neu öffnen, da sich die Ordnerstruktur verändert hat. Öffnet dazu in Android Studio das Projekt bzw. den Ordner "android-app", _nicht das Projekt "app"!_. 

## CI/CD verwenden

Nach jedem Commit auf den master-Branch wird ein Build von der WebApp erstellt und auf 
  [users.informatik.uni-halle.de/~anfvg](http://users.informatik.uni-halle.de/~anfvg) 
hochgeladen.

## Elm installieren:

* [guide.elm-lang.org/install.html](https://guide.elm-lang.org/install.html)

* ggf. Editor einrichten

* eigenen Branch anlegen

* zum Kompilieren in den Ordner fragebogengenerator/web-app/src/ 
wechseln und elm make ausführen:
```
  cd web-app/src
  elm make Main.elm --output Main.js
```
* um eine Vorschau zu sehen, elm reactor starten 
```
  elm reactor
```
* [localhost:8000/index.html](localhost:8000/index.html) aufrufen

* regelmäßig git commit und git push ausführen

----------------------------------------------------------------

## Link zur Referenz für Elm-Sprache:
	https://package.elm-lang.org/

## Link zu Bulma:
	bulma.io