# Greek Language Support for CrossPoint Reader

This document describes the Greek language support that has been added to the CrossPoint eink reader firmware.

## Summary

Greek language support (Unicode range 0x0370–0x03FF) has been successfully added to the firmware with the following features:

- **Font Support**: NotoSans font family (all 20 variants) now includes Greek & Coptic character glyphs
- **Hyphenation**: Full Greek hyphenation support using Typst's hypher library patterns
- **Language Code**: `el` (Greek)
- **Character Coverage**: 144 Greek characters including uppercase, lowercase, and diacritics

## Changes Made

### 1. Font Generation (`lib/EpdFont/`)

- **Modified**: `scripts/fontconvert.py`
  - Uncommented Greek & Coptic range (0x0370-0x03FF)
  - Added UTF-8 output handling for Windows compatibility

- **Created**: `scripts/convert-notosans-with-greek.sh`
  - Convenience script to rebuild only NotoSans fonts with Greek support
  - Processes 20 font variants (5 sizes × 4 styles)

- **Regenerated**: All NotoSans font headers
  - `lib/EpdFont/builtinFonts/notosans_*.h` (20 files)
  - Sizes: 8pt, 12pt, 14pt, 16pt, 18pt
  - Styles: Regular, Italic, Bold, BoldItalic

### 2. Hyphenation Support (`lib/Epub/Epub/hyphenation/`)

- **Modified**: `HyphenationCommon.h`
  - Added `toLowerGreek()` function declaration
  - Added `isGreekLetter()` function declaration

- **Modified**: `HyphenationCommon.cpp`
  - Implemented `toLowerGreek()` for Greek case conversion
  - Implemented `isGreekLetter()` for Greek character detection
  - Updated `isAlphabetic()` to include Greek letters

- **Modified**: `LanguageRegistry.cpp`
  - Added Greek hyphenation pattern include
  - Created `greekHyphenator` instance
  - Registered Greek language with code "el"
  - Updated entry array size to 7 languages

- **Added**: `tries/el.bin`
  - Binary hyphenation trie from Typst's hypher project
  - Size: ~2 KB

- **Generated**: `generated/hyph-el.trie.h`
  - C header containing Greek hyphenation patterns
  - Auto-generated from `el.bin` using `scripts/generate_hyphenation_trie.py`

### 3. Documentation

- **Modified**: `USER_GUIDE.md`
  - Updated supported languages section
  - Removed Greek from "not supported" list
  - Added Greek to supported Unicode blocks

## Size Impact

The addition of Greek support adds approximately:

- **Per NotoSans font variant**: ~5-8 KB (for 144 Greek glyphs at 2-bit grayscale)
- **Total NotoSans increase**: ~120-150 KB (20 variants)
- **Hyphenation data**: ~2 KB
- **Total firmware increase**: ~125-155 KB

This is well within the ~6.25 MB app partition size limit.

## Supported Greek Characters

The following Greek & Coptic Unicode characters (0x0370–0x03FF) are now supported:

- Greek uppercase letters (Α-Ω): U+0391–U+03A9
- Greek lowercase letters (α-ω): U+03B1–U+03C9
- Greek letters with diacritics (tonos, dialytika, etc.)
- Archaic Greek letters
- Coptic letters (partial coverage based on font availability)

## Usage

### For Users

Greek text in EPUB files will now render automatically when using the NotoSans font family. To use Greek text:

1. Open an EPUB file containing Greek text
2. Select NotoSans as your reading font (if not already selected)
3. Greek characters will render with proper hyphenation

### For Developers

#### Rebuilding Fonts with Greek Support

If you need to regenerate the fonts (e.g., after updating source fonts):

```bash
cd lib/EpdFont/scripts
bash convert-notosans-with-greek.sh
```

This will regenerate all 20 NotoSans font variants with Greek support.

#### Adding Greek to Other Font Families

To add Greek support to Bookerly or OpenDyslexic fonts:

1. Modify `lib/EpdFont/scripts/convert-builtin-fonts.sh` to uncomment Greek range
2. Run the full font conversion script
3. Note: This will increase firmware size by an additional ~120-150 KB per font family

#### Language Detection

Greek text is automatically detected by the hyphenation system when:
- The EPUB file specifies `lang="el"` in HTML
- The text contains Greek characters (0x0370–0x03FF)

## Testing

To test Greek support:

1. **Font Rendering**: Open an EPUB with Greek text and verify characters display correctly
2. **Hyphenation**: Check that long Greek words break properly at line endings
3. **Character Coverage**: Test uppercase, lowercase, and accented Greek characters

## Known Limitations

- **Font Support**: Only NotoSans font family includes Greek. Bookerly and OpenDyslexic do not (to save space)
- **Ancient Greek**: While supported by the character set, some archaic forms may not render perfectly
- **Polytonic Greek**: Full polytonic (multiple accents) support depends on the NotoSans font coverage

## Technical Details

### Greek Case Conversion

The Greek case conversion function handles:
- Standard Greek letters (Α-Ω → α-ω)
- Greek with tonos (Ά-Ί → ά-ί)
- Special cases (Ό → ό, Ύ-Ώ → ύ-ώ)

### Hyphenation Pattern Source

Greek hyphenation patterns are sourced from:
- **Origin**: Typst's hypher project (https://github.com/typst/hypher)
- **Pattern File**: `tries/el.bin`
- **Algorithm**: Liang hyphenation algorithm with Greek-specific patterns

## Build Instructions

The changes are integrated into the standard build process. Simply build the firmware as usual:

```bash
pio run
```

The Greek font data and hyphenation patterns are automatically included.

## Reverting Greek Support

If you need to remove Greek support to reduce firmware size:

1. **Fonts**: Restore the original NotoSans font headers from git history
2. **Hyphenation**: 
   - Remove `#include "generated/hyph-el.trie.h"` from `LanguageRegistry.cpp`
   - Remove `greekHyphenator` declaration
   - Remove Greek entry from `kEntries` array
   - Update `EntryArray` size back to 6
3. **Character Detection**: 
   - Remove `toLowerGreek()` and `isGreekLetter()` functions
   - Update `isAlphabetic()` to exclude Greek

## Credits

- **Hyphenation Patterns**: Typst hypher project (https://github.com/typst/hypher)
- **Font**: NotoSans by Google Fonts
- **Implementation**: Added to CrossPoint Reader firmware

---

For questions or issues related to Greek support, please check:
- Character not rendering? → Verify NotoSans font is selected
- Word breaking incorrectly? → Check EPUB language tag (`lang="el"`)
- Firmware too large? → Consider Greek-only for NotoSans (current configuration)
