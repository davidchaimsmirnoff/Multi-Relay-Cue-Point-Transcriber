# 🛰️ The Multi Relay Cue Point Transcriber - MRCPT


> Get two Cursors Working for you NOW !!

> Transcribe without breaking flow. Play, pause, rewind, fast-forward — never touch your mouse.

## Demo
Click Thumbnail Below for Demo Video On YouTube and Click the Link in the Description Bellow to return back to Git Hub Repo to dowload the APP!
[![Watch Demo](https://img.youtube.com/vi/DU9xxgyxXzo/maxresdefault.jpg)](https://www.youtube.com/watch?v=DU9xxgyxXzo)

Or download/run locally for full experience.

The MRCPT puts a red dot on your screen you control independently of your real cursor. Aim it at your media player once, then use keyboard shortcuts to control playback from anywhere — your hands never leave the keyboard, your eyes never leave your document.

Built for transcriptionists who lose their place every time they reach for the mouse.

---

## Install & Run

No Xcode needed. Just paste this into Terminal:

```bash
clang -fobjc-arc -framework Cocoa -framework Carbon -framework Quartz -o MRCPT main.m && ./MRCPT
```

> **First launch:** macOS will ask for Accessibility permission. Go to **System Settings → Privacy & Security → Accessibility** and enable MRCPT. Then run it again.

---

## Shortcuts

| Shortcut | What it does |
|---|---|
| `⌃ ⌥ ⌘ G` | Toggle dot mode on/off. Move the red dot with your trackpad, press again to lock it. |
| `⌃ ⌥ ⌘ H` | Click at the red dot. Use this to play/pause. Your cursor stays exactly where it was. |
| `⌃ ⌥ ⌘ F` | Click at the dot + rewind (← arrow). Jumps back a few seconds. |
| `⌃ ⌥ ⌘ J` | Click at the dot + fast-forward (→ arrow). Skips ahead a few seconds. |

---

## How to use it

**1.** Open your media player and your text editor side by side.

**2.** Press `⌃⌥⌘G` — a green border appears and the red dot shows up. Move the dot over your media player's play button with your trackpad.

**3.** Press `⌃⌥⌘G` again — dot mode locks off, your real cursor snaps back to your document.

**4.** Start transcribing. Hit `⌃⌥⌘H` to play/pause, `F` to rewind, `J` to skip — all without leaving your keyboard.

---

## Requirements

- macOS 12 or later


## How it works

Two transparent windows float above everything on screen — a green dashed border to show dot mode is active, and a red dot that tracks your trackpad. When you hit a shortcut, The MRCPT silently moves the system cursor to the dot, fires a clean click with all modifier keys stripped (so it never acts like a ctrl-click), then moves the cursor straight back — invisibly, in under 60ms.

---

*macOS only · no dependencies · ~200 lines of Objective-C*
