# PDF Split & Merge

- `PdfSplitMergeService.splitDocument(bytes, ranges)` -> list of PDFs, one per `PdfPageRange`.
- `mergeDocuments` -> concatenates multiple PDFs into a single document (preserves page order).
- `renderPagePreview` -> renders a PNG thumbnail for UI previews.

**Usage tips**
1. Clamp ranges to the inspected `pageCount` to avoid `RangeError`.
2. Merge is synchronous; consider running in an isolate for large inputs.
3. Syncfusion requires a community/commercial license for production redistributions.

## UI Interaction Notes

- **Split ranges**: users can add/remove ranges; empty ranges collapse to single-page exports.
- **Merge queue**: supports multi-file pickers; merges follow selection order.
- **Output**: splitting writes into a user-selected directory, naming files `<basename>_partN.pdf`; merging uses `FilePicker.saveFile`.
- **Preview**: up to four thumbnails are rendered for quick validation (viewport-friendly).
