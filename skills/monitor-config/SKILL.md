---
name: monitor-config
description: This skill should be used when the user asks to configure, optimize, or troubleshoot their display/monitor setup. Triggers on "optimize my monitors", "configure displays", "rotate monitor", "set up my screens", "display settings", "monitor resolution", or any request to adjust multi-monitor arrangements, resolutions, refresh rates, or orientations on macOS.
user-invocable: true
argument-hint: "[describe your setup or issue]"
---

# Monitor Configuration Assistant

Optimize multi-monitor setups on macOS through an interactive interview process. Discover connected displays, understand the user's physical arrangement and workflow, then configure optimal resolutions, refresh rates, and orientations.

## Requirements

- macOS
- `displayplacer` CLI tool (will prompt to install if missing)

## Workflow

### Step 1: Ensure displayplacer is Installed

Check if displayplacer is available:

```bash
command -v displayplacer || echo "NOT_INSTALLED"
```

If not installed, offer to install:

```bash
brew install displayplacer
```

### Step 2: Discover Connected Displays

Run displayplacer to get full display information:

```bash
displayplacer list
```

Parse and present the displays in a clear format:

```
I found these displays:

1. [Type] - [Size] inch
   - Current: [resolution] @ [hz]Hz
   - Rotation: [degrees]
   - Position: [origin]

2. ...
```

Identify each display by:
- Serial screen ID (persistent across reboots)
- Type (MacBook built-in, external)
- Size (27 inch, 32 inch, etc.)

### Step 3: Interview About Physical Setup

Ask about the physical arrangement:

1. "Which monitor is in front of you (center)?"
2. "What's to your left? Right?"
3. "Are any monitors rotated vertically (portrait mode)?"
4. "Roughly how far do you sit from your displays? (helps determine optimal resolution)"

### Step 4: Interview About Use Case

Ask about primary use:

1. "What do you primarily use this setup for?"
   - Programming/code reading
   - Video editing/media production
   - General productivity
   - Gaming
   - Mixed use

2. "Do you prefer maximum sharpness (smaller text) or comfortable readability (larger text)?"

3. "Is smooth scrolling important to you? (120Hz vs 60Hz)"

### Step 5: Analyze and Recommend

Based on the interview, reference `references/resolution_guidelines.md` for optimal settings.

Consider:
- **4K displays**: Can run at native 4K, scaled 1440p, or scaled 1080p
- **Portrait orientation**: Use `degree:90` or `degree:270` depending on cable exit preference
- **Refresh rates**: Prioritize 120Hz for programming/gaming if available
- **Main display**: Set the center/primary monitor as main with `origin:(0,0)`

Present the recommendation:

```
Based on your setup, I recommend:

Center (32" Dell): 3840x2160 @ 120Hz - Main display
  → Maximum 4K sharpness, smooth scrolling

Left (27" Dell): 1800x3200 @ 60Hz portrait
  → Vertical for code reading, high resolution

Right (MacBook): 1512x982 @ 120Hz
  → Native Retina scaling

Want me to apply this configuration?
```

### Step 6: Apply Configuration

Construct and execute the displayplacer command:

```bash
displayplacer \
  "id:[DISPLAY_ID] res:[WIDTH]x[HEIGHT] hz:[REFRESH] color_depth:8 enabled:true [scaling:on] origin:([X],[Y]) degree:[ROTATION]" \
  "id:[DISPLAY_ID] ..." \
  "id:[DISPLAY_ID] ..."
```

Key parameters:
- `id:` - Use persistent screen ID for reliability
- `res:` - Resolution (check available modes in displayplacer list)
- `hz:` - Refresh rate
- `scaling:on` - Enable HiDPI scaling (omit for native resolution)
- `origin:` - Position relative to other displays
- `degree:` - Rotation (0, 90, 180, 270)

### Step 7: Verify and Save Profile

After applying, verify the configuration:

```bash
displayplacer list | grep -E "(Serial screen id|Resolution:|Origin:|Rotation:)"
```

Offer to save as a reusable profile:

```bash
mkdir -p ~/.config/display-profiles
```

Create a shell script for the profile:

```bash
#!/bin/bash
# Profile: [name]
# [description]

displayplacer \
  "id:... res:... hz:... ..."

echo "Profile [name] applied"
```

Optionally add shell aliases for quick switching.

## Troubleshooting

### Monitor Shows Upside Down
Change rotation from `degree:90` to `degree:270` or vice versa.

### Resolution Mode Not Found
Some resolutions require `scaling:on`, others don't. Check the available modes in `displayplacer list` output and match exactly.

### Display IDs Changed
Use serial screen IDs (start with 's') instead of persistent IDs for more reliability, or use contextual IDs with the `--contextual` flag.

### Portrait Resolution Format
When rotated, specify resolution in portrait format: `1080x1920` instead of `1920x1080`.

## Example Session

```
User: optimize my monitors

Claude: Let me check your connected displays...
[runs displayplacer list]

I found 3 displays:
1. MacBook Pro 16" - Built-in Liquid Retina XDR
2. Dell S3225QS - 32" 4K @ 120Hz capable
3. Dell U2720Q - 27" 4K @ 60Hz capable

How are these physically arranged?

User: The 32" is center, 27" is on my left rotated vertical, MacBook on right

Claude: Great setup for coding! How far do you sit from the displays?

User: About 2.5 feet

Claude: At 2.5 feet from 4K displays, here's what I recommend:
- 32" center: 3840x2160 @ 120Hz (full 4K, maximum sharpness)
- 27" left: 1800x3200 portrait @ 60Hz (tons of code lines visible)
- MacBook right: Native Retina @ 120Hz

Want me to apply this?

User: Yes

Claude: [applies configuration]

Done! Your displays are now configured:
- 32" Dell: Main display, 4K @ 120Hz
- 27" Dell: Portrait left, 1800x3200
- MacBook: Right side, native resolution

I've also saved this as a profile at ~/.config/display-profiles/coding.sh
Run `display-coding` to restore this configuration anytime.
```
