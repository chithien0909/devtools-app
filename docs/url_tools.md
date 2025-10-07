# URL Tools

### URL Builder service

- `validate` -> returns `UrlValidationResult` with parsed `Uri` when possible.
- `normalize` -> lowercases scheme/host, removes default ports, and sorts query parameters for deterministic output.
- `toClipboardPayload` / `toShareMessage` -> helpers used by the UI to copy/share consistent URLs.
