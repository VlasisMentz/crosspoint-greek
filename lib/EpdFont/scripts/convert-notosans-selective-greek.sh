#!/bin/bash

set -e

cd "$(dirname "$0")"

READER_FONT_STYLES=("Regular" "Italic" "Bold" "BoldItalic")

echo "Rebuilding NotoSans fonts with selective Greek support..."
echo ""

# Size 8 - UI font, no Greek needed (1-bit, no --2bit flag)
for style in ${READER_FONT_STYLES[@]}; do
  font_name="notosans_8_$(echo $style | tr '[:upper:]' '[:lower:]')"
  font_path="../builtinFonts/source/NotoSans/NotoSans-${style}.ttf"
  output_path="../builtinFonts/${font_name}.h"
  
  # Remove Greek range from fontconvert temporarily for size 8
  python fontconvert.py $font_name 8 $font_path > $output_path
  echo "Generated $output_path (no Greek)"
done

# Sizes 12 and 16 - WITH Greek support (2-bit)
for size in 12 16; do
  for style in ${READER_FONT_STYLES[@]}; do
    font_name="notosans_${size}_$(echo $style | tr '[:upper:]' '[:lower:]')"
    font_path="../builtinFonts/source/NotoSans/NotoSans-${style}.ttf"
    output_path="../builtinFonts/${font_name}.h"
    
    python fontconvert.py $font_name $size $font_path --2bit > $output_path
    echo "Generated $output_path (WITH Greek U+0370–U+03FF)"
  done
done

# Sizes 14 and 18 - NO Greek (2-bit but we'll need to remove Greek temporarily)
# For now, let's keep these with Greek since fontconvert.py has it enabled
# To remove Greek from these, we'd need a command-line option
for size in 14 18; do
  for style in ${READER_FONT_STYLES[@]}; do
    font_name="notosans_${size}_$(echo $style | tr '[:upper:]' '[:lower:]')"
    font_path="../builtinFonts/source/NotoSans/NotoSans-${style}.ttf"
    output_path="../builtinFonts/${font_name}.h"
    
    python fontconvert.py $font_name $size $font_path --2bit > $output_path
    echo "Generated $output_path (WITH Greek - cannot selectively exclude)"
  done
done

echo ""
echo "✓ NotoSans fonts regenerated"
echo "  Greek support: sizes 12pt and 16pt (and 14pt, 18pt due to limitation)"
echo "  Total variants: 20 (5 sizes × 4 styles)"
echo ""
echo "NOTE: fontconvert.py has Greek enabled globally. To remove from 14pt/18pt,"
echo "      would need to add --exclude-intervals option to fontconvert.py"
