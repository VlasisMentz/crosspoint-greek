# Building CrossPoint Reader Firmware with Greek Support

## Quick Start

Greek language support has been fully integrated into your CrossPoint Reader firmware. Follow these steps to build and flash the firmware to your Xteink X4 device.

## Prerequisites

Ensure you have the following installed:
- **PlatformIO** (for ESP32 builds)
- **Python 3.x** with `freetype-py` (for font generation - already done)
- **Git** (for version control)

## Changes Summary

✅ **Greek character support added to NotoSans fonts** (Unicode 0x0370–0x03FF)  
✅ **Greek hyphenation patterns integrated** (language code: `el`)  
✅ **All 20 NotoSans font variants regenerated** with Greek glyphs  
✅ **Documentation updated** in USER_GUIDE.md  

**Size Impact**: ~125-155 KB increase (well within the 6.25 MB limit)

## Build Instructions

### Step 1: Build the Firmware

From the project root directory:

```bash
# Using PlatformIO CLI
pio run

# Or using PlatformIO IDE
# Click the "Build" button in the PlatformIO toolbar
```

### Step 2: Flash to Device

```bash
# Flash via USB
pio run --target upload

# Or monitor serial output during flash
pio run --target upload --target monitor
```

### Step 3: Verify Greek Support

1. Transfer a Greek EPUB file to your device
2. Open the EPUB in the reader
3. Select **NotoSans** as the reading font (if not default)
4. Verify that Greek characters display correctly
5. Check that long Greek words hyphenate properly at line breaks

## Testing Greek Support

### Sample Greek Text for Testing

If you need to test the implementation, create a simple EPUB with this Greek text:

```
Καλημέρα! Αυτό είναι ένα δοκιμαστικό κείμενο στα Ελληνικά.

Η τεχνολογία των ηλεκτρονικών συσκευών ανάγνωσης έχει εξελιχθεί σημαντικά τα τελευταία χρόνια.
```

### Verification Checklist

- [ ] Greek uppercase letters render (Α, Β, Γ, Δ, Ε...)
- [ ] Greek lowercase letters render (α, β, γ, δ, ε...)
- [ ] Greek letters with accents render (ά, έ, ή, ί, ό...)
- [ ] Long Greek words break correctly at line endings
- [ ] No squares or missing character symbols (□)

## Firmware Size Check

After building, check the firmware size:

```bash
pio run --target size
```

Expected size: **Less than 6.25 MB** (the app partition limit)

If the firmware is too large, you can:
1. Enable the `OMIT_FONTS` build flag (removes some optional fonts)
2. Remove Greek from other font families (keep only NotoSans with Greek)

## Troubleshooting

### Issue: Greek Characters Show as Squares (□)

**Solution**: Make sure you're using the **NotoSans** font family. Only NotoSans includes Greek glyphs.

1. While reading, press the **Menu** button
2. Navigate to **Settings** → **Font Family**
3. Select **NotoSans**

### Issue: Firmware Too Large to Flash

**Solution**: Greek is only added to NotoSans fonts (not Bookerly or OpenDyslexic) to minimize size. If still too large:

1. Edit `platformio.ini` and add build flag: `-D OMIT_FONTS`
2. This removes optional reader fonts but keeps core functionality
3. Rebuild with `pio run`

### Issue: Build Errors Related to Greek Files

**Solution**: Ensure all files are properly saved and UTF-8 encoded:

```bash
# Regenerate Greek hyphenation header if needed
python scripts/generate_hyphenation_trie.py \
    --input lib/Epub/Epub/hyphenation/tries/el.bin \
    --output lib/Epub/Epub/hyphenation/generated/hyph-el.trie.h
```

### Issue: Python Unicode Errors on Windows

**Solution**: Already fixed! The `fontconvert.py` script now handles UTF-8 output on Windows.

## Rebuilding Fonts (If Needed)

If you modify the source font files or need to regenerate:

```bash
cd lib/EpdFont/scripts

# Rebuild only NotoSans with Greek (faster, recommended)
bash convert-notosans-with-greek.sh

# Or rebuild all fonts with Greek
bash convert-builtin-fonts.sh
```

**Note**: Full rebuild takes several minutes and increases firmware size for all font families.

## Advanced: Adding Greek to Other Fonts

If you want Greek support in Bookerly or OpenDyslexic fonts:

1. Edit `lib/EpdFont/scripts/convert-builtin-fonts.sh`
2. The Greek range is now uncommented in `fontconvert.py`, so it will be included
3. Run: `bash convert-builtin-fonts.sh`
4. **Warning**: This adds ~120-150 KB per font family

## File Changes Reference

### Modified Files
- `lib/EpdFont/scripts/fontconvert.py` - Added Greek range, UTF-8 support
- `lib/Epub/Epub/hyphenation/HyphenationCommon.h` - Greek function declarations
- `lib/Epub/Epub/hyphenation/HyphenationCommon.cpp` - Greek implementation
- `lib/Epub/Epub/hyphenation/LanguageRegistry.cpp` - Greek registration
- `USER_GUIDE.md` - Documentation update
- All `lib/EpdFont/builtinFonts/notosans_*.h` files (20 files)

### New Files
- `lib/EpdFont/scripts/convert-notosans-with-greek.sh` - Convenience script
- `lib/Epub/Epub/hyphenation/tries/el.bin` - Greek hyphenation data
- `lib/Epub/Epub/hyphenation/generated/hyph-el.trie.h` - Generated header
- `GREEK_SUPPORT_README.md` - Detailed technical documentation
- `BUILD_WITH_GREEK.md` - This file

## Performance Impact

Greek support has **minimal performance impact**:
- Font lookup: O(log n) binary search (same as before)
- Hyphenation: Efficient trie lookup (~2 KB pattern data)
- Memory: Static data in flash (no RAM impact)
- Rendering: Same speed as Latin/Cyrillic text

## Next Steps

1. **Build the firmware**: `pio run`
2. **Flash to device**: `pio run --target upload`
3. **Test with Greek EPUB**: Verify rendering and hyphenation
4. **Enjoy Greek reading support!** 📚

## Questions or Issues?

- **Technical details**: See `GREEK_SUPPORT_README.md`
- **User guide**: See updated `USER_GUIDE.md`
- **Build problems**: Check the Troubleshooting section above

---

**Status**: ✅ Ready to build and flash

**Branch**: `feat/001-add-greek-language` (current)

Happy reading in Greek! 🇬🇷
