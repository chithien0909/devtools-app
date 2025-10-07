# Text Tools

### Intra-line diff

`DiffService.diffLinesWithIntraline` pairs delete/insert line pairs and returns `DiffLine` objects with inline `DiffSegment`s, allowing the UI to highlight character-level changes within modified lines.
