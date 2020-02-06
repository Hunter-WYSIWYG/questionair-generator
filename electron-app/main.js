const { app, BrowserWindow, dialog } = require('electron')

// global reference to browser window
let win
let contents

// Creates the browser window
function createWindow () {
  win = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true
    }
  })

  win.webContents.session.on('will-download', (event, downloadItem, webContents) => {

    var fileName = dialog.showSaveDialogSync(win, {
      filters: [
        { name: 'Fragebogen', extensions: ['json'] }]
    });

    if (typeof fileName == "undefined") {
      downloadItem.cancel()
    }
    else {
      downloadItem.setSavePath(fileName);
    }
  });

  // Hides the menu.
  win.setAutoHideMenuBar(true)
  // Maximizes the window.
  win.maximize()

  // Loads index.html.
  win.loadFile('index.html')

  // Dereferences the window object if the window gets closed
  win.on('closed', () => {
    win = null
  })
}

// Calls the function to create the window, after the electron finished the initiation.
app.on('ready', createWindow)

// Closes app after all windows are closed.
app.on('window-all-closed', () => {
  // App stays active under MacOS until the user closes the app.
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', () => {
  // For MacOS users:
  // Creates a new window of the app, if a user clicks the icon inside the dock.
  if (win === null) {
    createWindow()
  }
})

