const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const pty = require('node-pty');

let mainWindow;
let ptyProcess = null;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        minWidth: 1000,
        minHeight: 700,
        backgroundColor: '#1a1a2e',
        titleBarStyle: 'hiddenInset',
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    mainWindow.loadFile(path.join(__dirname, 'index.html'));

    // Uncomment for debugging
    // mainWindow.webContents.openDevTools();
}

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
    if (ptyProcess) {
        ptyProcess.kill();
    }
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
        createWindow();
    }
});

// Start the agent chain script
ipcMain.on('start-chain', (event, projectPrompt) => {
    const scriptPath = path.join(__dirname, '..', '..', 'agent_chain.sh');
    const workDir = path.join(__dirname, '..', '..');

    // Kill existing process if any
    if (ptyProcess) {
        ptyProcess.kill();
        ptyProcess = null;
    }

    // Use node-pty for proper PTY support
    ptyProcess = pty.spawn('bash', [scriptPath, projectPrompt], {
        name: 'xterm-256color',
        cols: 120,
        rows: 30,
        cwd: workDir,
        env: {
            ...process.env,
            TERM: 'xterm-256color',
            COLORTERM: 'truecolor'
        }
    });

    ptyProcess.onData((data) => {
        event.sender.send('terminal-data', data);

        // Detect stage changes
        if (data.includes('STAGE 1') || data.includes('Planning')) {
            event.sender.send('stage-change', 1);
        } else if (data.includes('STAGE 2') || data.includes('Frontend')) {
            event.sender.send('stage-change', 2);
        } else if (data.includes('STAGE 3') || data.includes('Backend')) {
            event.sender.send('stage-change', 3);
        } else if (data.includes('STAGE 4') || data.includes('Review')) {
            event.sender.send('stage-change', 4);
        }
    });

    ptyProcess.onExit(({ exitCode }) => {
        event.sender.send('chain-complete', exitCode);
        ptyProcess = null;
    });
});

// Send input to the terminal
ipcMain.on('terminal-input', (event, data) => {
    if (ptyProcess) {
        ptyProcess.write(data);
    }
});

// Resize terminal
ipcMain.on('terminal-resize', (event, { cols, rows }) => {
    if (ptyProcess) {
        ptyProcess.resize(cols, rows);
    }
});

// Stop the chain
ipcMain.on('stop-chain', () => {
    if (ptyProcess) {
        ptyProcess.kill();
        ptyProcess = null;
    }
});
