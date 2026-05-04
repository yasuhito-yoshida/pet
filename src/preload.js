const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  dragWindow: (dx, dy) => ipcRenderer.invoke('drag-window', dx, dy),
  sendCommand: (command, payload = {}) => ipcRenderer.send('pet-command', { command, ...payload }),
  onCommand: (callback) => ipcRenderer.on('pet-command', (_event, data) => callback(data)),
});
