# Resolution Guidelines by Use Case

## Viewing Distance Reference

| Distance | 27" 4K | 32" 4K | MacBook 14/16" |
|----------|--------|--------|----------------|
| 2 feet   | 1440x2560 portrait / 2560x1440 | 2560x1440 | Native |
| 2.5 feet | 1800x3200 portrait / 3200x1800 | 3200x1800 - 3840x2160 | Native |
| 3 feet   | 2160x3840 portrait / 3840x2160 | 3840x2160 | Native |

## Use Case Profiles

### Programming / Code Reading
- **Center display**: Higher resolution preferred for more code visible
- **Portrait monitor**: Essential for reading long files without scrolling
- **Refresh rate**: 120Hz preferred for smooth scrolling
- **Recommended**: 4K or near-4K with scaling off for maximum sharpness

### Video Editing / Media
- **Center display**: Color-accurate, moderate scaling for UI visibility
- **Secondary**: Timeline or preview
- **Recommended**: 2560x1440 or 3200x1800 for comfortable UI sizing

### General Productivity
- **Center display**: Balance between sharpness and readability
- **Secondary**: Reference materials, chat, email
- **Recommended**: 2560x1440 scaled

### Presentations / Video Calls
- **All landscape**: Easier window management
- **Moderate resolution**: Larger UI elements
- **Recommended**: 1920x1080 scaled

## Portrait Mode Guidelines

Portrait rotation works best for:
- Code reading (see 100+ lines at once)
- Document editing
- Chat/communication apps
- Reading long articles

Rotation values:
- `degree:90` - Rotates counter-clockwise (cables exit right)
- `degree:270` - Rotates clockwise (cables exit left)

## Refresh Rate Priorities

| Use Case | Priority |
|----------|----------|
| Gaming | 120Hz+ critical |
| Programming | 120Hz nice-to-have for smooth scrolling |
| Video editing | 60Hz sufficient |
| General use | 60Hz sufficient |

## Multi-Monitor Alignment

Origin coordinates determine physical arrangement:
- `origin:(0,0)` - Main display reference point
- Negative X values - Left of main
- Positive X values - Right of main
- Y values - Vertical offset (negative = higher)

Example for 3 monitors (portrait left, main center, laptop right):
```
Portrait: origin:(-width,0)
Main: origin:(0,0)
Laptop: origin:(main_width,0)
```
