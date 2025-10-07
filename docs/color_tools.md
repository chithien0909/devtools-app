# Color Tools

### Palette extraction

- Deterministic k-means (seeded) keeps UI previews consistent.
- `paletteSize` defaults to 5 colours, capped at 12 to avoid over-sampling.
- `sampleStride` trades accuracy for speed (4 ≈ 1/16th of pixels).
- Returned ints are RGB (`0xRRGGBB`); convert to hex with `rgbToHex`.
