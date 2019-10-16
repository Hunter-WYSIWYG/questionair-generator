# Fragebogengenerator

## Android Studio Projekt verwenden

Ihr müsst das Android Studio Projekt neu öffnen, da sich die Ordnerstruktur verändert hat. Öffnet dazu in Android Studio das Projekt bzw. den Ordner "android-app", _nicht das Projekt "app"!_. 

## CI/CD verwenden

Nach jedem Commit auf den master-Branch wird ein Build von der WebApp erstellt und auf der Seite users.informatik.uni-halle.de/~anfvg hochgeladen.

## Elm installieren:
	https://guide.elm-lang.org/install.html

* Ggf. Editor einrichten

* Eigenen Branch anlegen

* Zum Kompilieren in den Ordner fragebogengenerator/web-app/src/ 
wechseln und elm make ausführen:
```
  cd web-app/src
  elm make Main.elm --output Main.js
```
* Um eine Vorschau zu sehen: 
```
  elm reactor
```
Dann auf localhost:8000/index.html aufrufen.

* Regelmäßig git commit und git push ausführen

----------------------------------------------------------------

## Link zur Referenz für Elm-Sprache:
	https://package.elm-lang.org/

## Link zu Bulma:
	bulma.io