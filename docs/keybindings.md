# Maleo Fedora Remix - Keybindings Reference

## Window Management

| Keybinding | Action |
|------------|--------|
| `Super + Q` | Close active window |
| `Super + V` | Toggle floating mode |
| `Super + F` | Toggle fullscreen |
| `Super + P` | Toggle pseudo-tiling |
| `Super + J` | Toggle split direction |

## Navigation

### Focus Movement

| Keybinding | Action |
|------------|--------|
| `Super + H` | Focus left |
| `Super + J` | Focus down |
| `Super + K` | Focus up |
| `Super + L` | Focus right |
| `Super + ←` | Focus left |
| `Super + ↓` | Focus down |
| `Super + ↑` | Focus up |
| `Super + →` | Focus right |

### Workspace Switching

| Keybinding | Action |
|------------|--------|
| `Super + 1-9` | Switch to workspace 1-9 |
| `Super + 0` | Switch to workspace 10 |
| `Super + Mouse Wheel Up` | Next workspace |
| `Super + Mouse Wheel Down` | Previous workspace |

### Move Windows

| Keybinding | Action |
|------------|--------|
| `Super + Shift + 1-9` | Move window to workspace 1-9 |
| `Super + Shift + 0` | Move window to workspace 10 |
| `Super + LMB (drag)` | Move window |
| `Super + RMB (drag)` | Resize window |

## Applications

| Keybinding | Action |
|------------|--------|
| `Super + Return` | Open terminal (Alacritty) |
| `Super + D` | Application launcher (Rofi) |
| `Super + E` | File manager (Nautilus) |
| `Super + L` | Lock screen |
| `Super + M` | Exit Hyprland |

## Screenshots

| Keybinding | Action |
|------------|--------|
| `Print` | Screenshot selection to clipboard |
| `Shift + Print` | Screenshot full screen to clipboard |
| `Super + Print` | Screenshot selection to file |

## Media Controls

| Keybinding | Action |
|------------|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

## Brightness

| Keybinding | Action |
|------------|--------|
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

## System

| Keybinding | Action |
|------------|--------|
| `Super + Shift + R` | Reload Hyprland config |
| `Super + Shift + E` | Exit Hyprland |

## Customization

To customize keybindings, edit:
```bash
~/.config/hypr/bindings.conf
```

Then reload Hyprland:
```bash
hyprctl reload
```

## Tips

- **Super key** is usually the Windows key or Command key
- Hold `Super` and use mouse to move/resize windows
- Use workspaces to organize your workflow
- Screenshots are saved to `~/Pictures/` by default
