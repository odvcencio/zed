# WSL Parity Testing Guide

This guide covers how to build and test all the WSL features we've added to Zed on Windows.

## Prerequisites

- Windows 10 version 2004+ or Windows 11
- WSL 2 installed with at least one Linux distribution (e.g., Ubuntu-24.04)
- Visual Studio 2022 with C++ build tools
- Rust toolchain for Windows
- PowerShell 7+

## Building Zed for Windows

### From Windows PowerShell (Recommended)

```powershell
# Navigate to the zed repository
cd C:\path\to\zed

# Checkout the wsl-parity branch
git checkout ch/wsl-parity

# Build the Windows bundle
.\script\bundle-windows.ps1

# Or for development/testing (faster builds):
cargo build --release -p zed
```

The release binary will be at: `target\x86_64-pc-windows-msvc\release\zed.exe`

### From WSL (Cross-compile)

```bash
# Add Windows target
rustup target add x86_64-pc-windows-msvc

# This is complex and not recommended for testing
# Better to build on Windows directly
```

## Testing Checklist

### 1. Command Palette Actions

**Test: `wsl: connect to wsl`**
1. Set default distro in settings:
   ```json
   {
     "remote": {
       "default_wsl_distro": "Ubuntu-24.04"
     }
   }
   ```
2. Open command palette (Ctrl+Shift+P)
3. Type "wsl: connect to wsl"
4. Should connect to Ubuntu-24.04 without prompting

**Expected:**
- ✅ Status modal appears
- ✅ Shows: "Detecting WSL environment..."
- ✅ Shows: "Detecting WSL capabilities..."
- ✅ Shows: "Detecting WSL platform..."
- ✅ Shows: "Preparing server binary..."
- ✅ Progress bar visible (if downloading binary)
- ✅ Shows: "WSL environment ready"
- ✅ Remote Projects panel opens

**Test: `wsl: connect to wsl using distro`**
1. Open command palette
2. Type "wsl: connect to wsl using distro"
3. Should show picker with all WSL distributions

**Expected:**
- ✅ Picker shows all installed distros
- ✅ Can select and connect to any distro
- ✅ Status messages appear during connection

**Test: `wsl: reopen folder in wsl`**
1. Open a local Windows folder in Zed
2. Open command palette
3. Type "wsl: reopen folder in wsl"
4. Select a distribution

**Expected:**
- ✅ Picker appears with WSL distributions
- ✅ Selected distro opens the same folder path
- ✅ Connection status visible

**Test: `wsl: disconnect`**
1. While connected to WSL, open command palette
2. Type "wsl: disconnect"

**Expected:**
- ✅ Closes the remote connection
- ✅ Prompts to save unsaved files
- ✅ Window closes or returns to local mode

**Test: `projects: open folder in wsl`**
1. Open command palette
2. Type "projects: open folder in wsl"
3. Select a Windows folder
4. Select WSL distribution

**Expected:**
- ✅ Folder browser appears
- ✅ Distribution picker appears
- ✅ Folder opens in WSL

**Test: `projects: open wsl`**
1. Open command palette
2. Type "projects: open wsl"

**Expected:**
- ✅ Remote Projects panel opens
- ✅ Shows WSL section
- ✅ Lists configured WSL connections

---

### 2. CLI Testing

**Test: `wsl://` URL scheme**

```powershell
# From Windows PowerShell
zed wsl://Ubuntu-24.04/home/username/project
```

**Expected:**
- ✅ Zed opens with connection modal
- ✅ Connects to Ubuntu-24.04
- ✅ Opens /home/username/project

**Test: `wsl://` with username**

```powershell
zed wsl://myuser@Ubuntu-24.04/home/myuser/code
```

**Expected:**
- ✅ Connects as specified user
- ✅ Opens correct path

**Test: `--remote wsl+distro` flag**

```powershell
zed --remote wsl+Ubuntu-24.04 ~/project
```

**Expected:**
- ✅ Connects to Ubuntu-24.04
- ✅ Path expanded correctly in WSL

**Test: `--remote wsl+distro+user` flag**

```powershell
zed --remote wsl+Ubuntu-24.04+alice /home/alice/work
```

**Expected:**
- ✅ Connects as user 'alice'
- ✅ Opens /home/alice/work

**Test: WSL Shim Script**

```bash
# From inside WSL (e.g., Ubuntu-24.04)
zed .
zed ~/myproject
zed /etc/hosts:15
```

**Expected:**
- ✅ Launches Windows Zed
- ✅ Auto-converts paths to wsl:// URLs
- ✅ Opens in correct WSL distribution
- ✅ Line numbers preserved (`:15`)

---

### 3. Settings & Configuration

**Test: Default distro setting**

Add to `~/.config/zed/settings.json` (Windows: `%APPDATA%\Zed\settings.json`):

```json
{
  "remote": {
    "default_wsl_distro": "Ubuntu-24.04"
  }
}
```

Then use `wsl: connect to wsl` action.

**Expected:**
- ✅ Connects to Ubuntu-24.04 without prompt
- ✅ Setting is respected

**Test: WSL connections configuration**

```json
{
  "remote": {
    "wsl_connections": [
      {
        "distro_name": "Ubuntu-24.04",
        "projects": [
          { "paths": ["/home/username/zed"] }
        ]
      },
      {
        "distro_name": "Debian",
        "user": "devuser",
        "projects": [
          { "paths": ["/home/devuser/work"] }
        ]
      }
    ]
  }
}
```

**Expected:**
- ✅ Remote Projects panel shows configured connections
- ✅ Projects appear under each distro
- ✅ User specification works correctly

---

### 4. Progress Indicators & Status Messages

**Test: Connection progress**

1. Connect to a fresh WSL distro (no server binary installed)
2. Watch the status modal

**Expected sequence:**
1. ✅ "Detecting WSL environment..."
2. ✅ "Detecting WSL capabilities..."
3. ✅ "Detecting WSL platform..."
4. ✅ "Preparing server binary..."
5. ✅ "Uploading remote server" (if binary downloaded)
6. ✅ "Extracting remote server" (if uploaded)
7. ✅ "WSL environment ready"
8. ✅ Progress bar animates
9. ✅ Percentage indicator shows (if downloading)

**Test: Reconnection**

1. Connect to WSL
2. Close Zed
3. Reopen the same WSL project

**Expected:**
- ✅ Reconnects faster (binary already exists)
- ✅ Status messages still appear
- ✅ "WSL environment ready" appears quickly

---

### 5. Error Handling

**Test: Invalid distro name**

```powershell
zed wsl://NonexistentDistro/home/user
```

**Expected:**
- ✅ Clear error message
- ✅ Indicates distro not found
- ✅ Lists available distros (ideally)

**Test: Invalid path**

```powershell
zed wsl://Ubuntu-24.04/nonexistent/path
```

**Expected:**
- ✅ Connects to WSL
- ✅ Shows path error
- ✅ Doesn't crash

**Test: No default distro set**

1. Remove `default_wsl_distro` from settings
2. Use `wsl: connect to wsl` action

**Expected:**
- ✅ Shows info prompt
- ✅ Explains how to set default distro
- ✅ Suggests using "connect to wsl using distro"

---

### 6. Integration Tests

**Test: Language servers**

1. Connect to WSL
2. Open a Python/Rust/TypeScript project
3. Verify language server starts

**Expected:**
- ✅ LSP runs in WSL, not Windows
- ✅ Completions work
- ✅ Go-to-definition works

**Test: Terminal**

1. Connect to WSL
2. Open integrated terminal (Ctrl+`)

**Expected:**
- ✅ Terminal runs in WSL (shows Linux prompt)
- ✅ `uname -a` shows Linux
- ✅ `pwd` shows Linux path

**Test: Git integration**

1. Connect to WSL
2. Open a Git repository
3. Make changes and stage/commit

**Expected:**
- ✅ Git status works
- ✅ Diffs display correctly
- ✅ Commit works
- ✅ Branch switching works

**Test: File watching**

1. Connect to WSL
2. Open a file
3. Edit the file outside Zed (using vim in WSL terminal)

**Expected:**
- ✅ Zed detects external changes
- ✅ Prompts to reload

---

### 7. Performance Tests

**Test: Large project**

1. Connect to WSL
2. Open a large project (e.g., Linux kernel source)

**Expected:**
- ✅ Project opens (may be slow with >100k files)
- ✅ File tree loads
- ✅ Search works

**Test: WSL 2 vs WSL 1**

If you have both:
1. Test same project on WSL 1 distribution
2. Test same project on WSL 2 distribution

**Expected:**
- ✅ WSL 2 is noticeably faster
- ✅ Both work correctly
- ✅ File watching works on both

---

## Troubleshooting

### Build Issues

**Error: "Visual Studio not found"**
- Install Visual Studio 2022 with "Desktop development with C++" workload

**Error: "Rust not installed"**
```powershell
# Install Rust on Windows
winget install --id Rustlang.Rustup
```

### Connection Issues

**Check WSL is running:**
```powershell
wsl -l -v
```

**Check distribution exists:**
```powershell
wsl -l --all
```

**Check wsl.exe on PATH:**
```powershell
where.exe wsl
```

**View Zed logs:**
- Open command palette
- Type "Open Telemetry Log"
- Look for WSL-related errors

### Binary Issues

**Server binary fails to download:**
- Check internet connection
- Check firewall settings
- Try connecting to https://zed.dev manually

**Server binary fails to execute:**
- Verify WSL distribution has execute permissions
- Check `~/.zed_server/` directory in WSL

---

## Reporting Issues

If you find bugs, please include:

1. Zed version: `zed --version`
2. Windows version: `winver`
3. WSL version: `wsl --version`
4. Distribution: `wsl -l -v`
5. Exact command or action used
6. Expected vs actual behavior
7. Zed logs (from Telemetry Log)
8. Any error messages shown

File issues at: https://github.com/zed-industries/zed/issues

---

## Quick Smoke Test Script

Run this after building to verify core functionality:

```powershell
# 1. Test URL scheme
zed wsl://Ubuntu-24.04/tmp

# Wait for connection, then close

# 2. Test --remote flag
zed --remote wsl+Ubuntu-24.04 /tmp

# Wait for connection, then close

# 3. Test command palette
# Open Zed, press Ctrl+Shift+P
# Type: wsl: connect to wsl using distro
# Select Ubuntu-24.04
# Verify it opens Remote Projects

# 4. Test shim from WSL
wsl -d Ubuntu-24.04 -e bash -c "cd /tmp && /mnt/c/path/to/zed/target/release/zed ."

# Should launch Windows Zed connected to WSL
```

If all 4 tests pass, core WSL functionality is working! 🎉
