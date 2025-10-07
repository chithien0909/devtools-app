# Media Tools

### EXIF Service

- `readTags` -> delegates to `package:exif` for broad metadata coverage (JPEG, TIFF, WebP).
- `stripTags` -> decodes using `package:image`, clears EXIF, re-encodes to the original format.
- JPEG quality defaults to 95 to avoid visible degradation; adjust if needed.
