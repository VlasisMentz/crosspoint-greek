#!/bin/bash

set -e

cd "$(dirname "$0")"

READER_FONT_STYLES=("Regular" "Italic" "Bold" "BoldItalic")
NOTOSANS_FONT_SIZES=(8 12 14 16 18)

echo "Rebuilding NotoSans fonts with Greek support..."
echo ""

for size in ${NOTOSANS_FONT_SIZES[@]}; do
  for style in ${READER_FONT_STYLES[@]}; do
    font_name="notosans_${size}_$(echo $style | tr '[:upper:]' '[:lower:]')"
    font_path="../builtinFonts/source/NotoSans/NotoSans-${style}.ttf"
    output_path="../builtinFonts/${font_name}.h"
    
    # Use --2bit for sizes 12 and above (reader fonts), 1-bit for size 8 (UI font)
    if [ $size -eq 8 ]; then
      python fontconvert.py $font_name $size $font_path > $output_path
    else
      python fontconvert.py $font_name $size $font_path --2bit > $output_path
    fi
    
    echo "Generated $output_path"
  done
done

echo ""
echo "✓ NotoSans fonts regenerated with Greek support (U+0370–U+03FF)"
echo "  Total variants: 20 (5 sizes × 4 styles)"
