const { app, BrowserWindow, screen, ipcMain } = require('electron');
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = Number(process.env.PET_PORT || 17321);
const HOST = process.env.PET_HOST || '0.0.0.0';
let win;
let server;
let visible = true;

function createWindow() {
  const { workArea } = screen.getPrimaryDisplay();
  const width = 280;
  const height = 340;

  win = new BrowserWindow({
    width,
    height,
    x: workArea.x + workArea.width - width - 28,
    y: workArea.y + workArea.height - height - 28,
    transparent: true,
    frame: false,
    resizable: false,
    hasShadow: false,
    alwaysOnTop: true,
    skipTaskbar: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  win.setAlwaysOnTop(true, 'screen-saver');
  win.loadFile(path.join(__dirname, 'pet.html'));
  win.on('closed', () => { win = null; });
}

function sendPetCommand(command, payload = {}) {
  if (win) win.webContents.send('pet-command', { command, ...payload });
}

function showPet() {
  if (!win) createWindow();
  visible = true;
  win.showInactive();
  sendPetCommand('show');
  return { ok: true, visible };
}

function hidePet() {
  if (win) {
    visible = false;
    sendPetCommand('hide');
    setTimeout(() => win && win.hide(), 180);
  }
  return { ok: true, visible };
}

function togglePet() {
  return visible ? hidePet() : showPet();
}

function movePet(dx, dy) {
  if (!win) return { ok: false, error: 'window-not-ready' };
  const [x, y] = win.getPosition();
  const ddx = Number(dx) || 0;
  const ddy = Number(dy) || 0;
  win.setPosition(x + ddx, y + ddy);
  return { ok: true, x: x + ddx, y: y + ddy };
}

function startControlServer() {
  server = http.createServer((req, res) => {
    const url = new URL(req.url, `http://127.0.0.1:${PORT}`);
    let result;

    try {
      if (url.pathname === '/show') result = showPet();
      else if (url.pathname === '/hide') result = hidePet();
      else if (url.pathname === '/toggle') result = togglePet();
      else if (url.pathname === '/say') { sendPetCommand('say', { text: url.searchParams.get('text') || '呼んだ？' }); result = { ok: true, visible }; }
      else if (url.pathname === '/state') result = {
        ok: true,
        visible,
        port: PORT,
        host: HOST,
        appDir: __dirname,
        petHtml: path.join(__dirname, 'pet.html'),
        petImage: path.join(__dirname, 'pet-image.png'),
        petImageExists: fs.existsSync(path.join(__dirname, 'pet-image.png'))
      };
      else if (url.pathname === '/quit') { result = { ok: true, quitting: true }; setTimeout(() => app.quit(), 50); }
      else if (url.pathname === '/move') result = movePet(Number(url.searchParams.get('dx') || 0), Number(url.searchParams.get('dy') || 0));
      else result = { ok: false, error: 'unknown-command' };
    } catch (error) {
      result = { ok: false, error: String(error && error.message || error) };
    }

    res.writeHead(result.ok ? 200 : 404, {
      'Content-Type': 'application/json; charset=utf-8',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify(result));
  });

  server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
      console.error(`Robot pet control server is already running on port ${PORT}.`);
    } else {
      console.error(error);
    }
  });

  server.listen(PORT, HOST, () => {
    console.log(`Robot pet control server: http://${HOST}:${PORT}`);
  });
}

ipcMain.handle('drag-window', (_event, dx, dy) => {
  return movePet(Number(dx) || 0, Number(dy) || 0);
});

const gotLock = app.requestSingleInstanceLock();
if (!gotLock) {
  app.quit();
} else {
  app.on('second-instance', () => showPet());
  app.whenReady().then(() => {
    createWindow();
    startControlServer();
  });

  app.on('window-all-closed', (event) => {
    event.preventDefault();
  });

  app.on('before-quit', () => {
    if (server) server.close();
  });
}
