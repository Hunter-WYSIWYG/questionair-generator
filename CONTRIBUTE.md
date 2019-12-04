# How to contribute

Our tools are build with Elm, JavaScript, HTML, CSS and Java. The following guide will help you to understand how to build each component of our toolset.

## The questionnaire generator 

This tool is a web app written in Elm and used for generating questionnaires. 

First of all, [download the compiler](https://guide.elm-lang.org/install.html).
We use a variety of community packages. You can get some information about them [here](https://package.elm-lang.org/). 

If this is your first time programming with Elm, you can get more information in the offical [documentation](https://guide.elm-lang.org/).

We also use the JavaScript-/CSS-Frameworks [Bulma](https://bulma.io), [Bootstrap](https://getbootstrap.com/docs/4.3/getting-started/introduction/) and [Flatpickr](https://flatpickr.js.org/).

After you installed the Elm compiler, you can either build the standalone web app, or you can use our electron app. 
To build just the web app, change the directory to `web-app` and run 
```
elm make src/Main.elm --output src/elm.js
```

You may now open the file `index.html` and use the generator.

### The electron app

If you want to use our electron app, install the Elm compiler and [Node.js](https://nodejs.org/en/download/). 

Change the directory to `electron-app`. 

The first time building the electron app open the command line (cmd.exe) and run the script `install_electron.bat`.

After running `build.bat` you can find the binarys inside the directory `electron-app`.

## The Android app

This app is build with [Java](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html) and [Android Studio (3.5.2)](https://developer.android.com/studio).

After installing this requirements, open the project inside Android Studio by opening the directory `android-app`. 

*Do NOT open the directory `app`!*

You can now build the .apk-file with Android Studio.

## The converter tool

This tool is used for uploading the Android app to a connected device, downloading answered questionaires from the device and converting them to .csv-files.

Download and install [Java](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html) and [Maven](https://maven.apache.org/).

Change the directory to `converter` and run 
```
mvn clean install
```

The .jar-file can be found inside the directory `converter\target`.