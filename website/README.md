# Forest at Night Website

A simple, atmospheric website featuring an animated dark forest scene with rain and sound effects.

## Features

- **Dynamic forest background** with multiple parallax layers creating depth
- **Dark stormy sky** with subtle pulsing animation
- **Realistic rainfall** with animated rain drops
- **Lightning effects** that flash periodically
- **Rain sound** generated using Web Audio API (no external files needed)
- **Fully responsive** design

## How to Run

Simply open `index.html` in a web browser. That's it!

```bash
open index.html
```

Or double-click the `index.html` file.

## Browser Compatibility

Works best in modern browsers (Chrome, Firefox, Safari, Edge). The rain sound will start after you click anywhere on the page (due to browser autoplay policies).

## Files

- `index.html` - Main HTML structure
- `styles.css` - All styling and animations
- `script.js` - Rain sound generation and dynamic rain effects

## Customization

You can easily customize the scene by editing `styles.css`:

- **Rain intensity**: Adjust the number of raindrops in `script.js` (line 32)
- **Rain sound volume**: Change `gainNode.gain.value` in `script.js` (line 83)
- **Sky colors**: Modify the gradient in `.sky` class
- **Forest density**: Add or remove radial gradients in forest layer classes
- **Lightning frequency**: Adjust animation timing in `.lightning` class

Enjoy the atmosphere!

