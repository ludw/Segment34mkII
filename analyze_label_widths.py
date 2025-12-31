#!/usr/bin/env python3
"""Analyze label widths across all language files using storre.fnt font."""

import re
import xml.etree.ElementTree as ET
from pathlib import Path
from collections import defaultdict

def parse_fnt_file(fnt_path):
    """Parse a BMFont .fnt file and return character widths."""
    char_widths = {}

    with open(fnt_path, 'r') as f:
        for line in f:
            if line.startswith('char id='):
                # Parse: char id=65 x=0 y=0 width=6 height=10 xoffset=0 yoffset=3 xadvance=8 page=0
                parts = line.split()
                char_id = None
                xadvance = None

                for part in parts:
                    if part.startswith('id='):
                        char_id = int(part.split('=')[1])
                    elif part.startswith('xadvance='):
                        xadvance = int(part.split('=')[1])

                if char_id is not None and xadvance is not None:
                    char_widths[chr(char_id)] = xadvance

    return char_widths

def calculate_text_width(text, char_widths, default_width=8):
    """Calculate the pixel width of text using character widths."""
    width = 0
    for char in text:
        width += char_widths.get(char, default_width)
    return width

def parse_strings_xml(xml_path):
    """Parse a strings.xml file and return label data."""
    tree = ET.parse(xml_path)
    root = tree.getroot()

    labels = {}
    for string_elem in root.findall('string'):
        string_id = string_elem.get('id')
        text = string_elem.text or ''

        # Only process LABEL_ strings
        if string_id and string_id.startswith('LABEL_'):
            labels[string_id] = text

    return labels

def categorize_label(label_id):
    """Categorize label by suffix (_1, _2, _3, or other)."""
    if label_id.endswith('_1'):
        return '1'
    elif label_id.endswith('_2'):
        return '2'
    elif label_id.endswith('_3'):
        return '3'
    else:
        return 'other'

def main():
    base_dir = Path(__file__).parent
    fnt_path = base_dir / 'resources' / 'fonts' / 'storre.fnt'

    # Parse font file
    print("Parsing storre.fnt...")
    char_widths = parse_fnt_file(fnt_path)
    print(f"Found {len(char_widths)} character widths\n")

    # Find all strings.xml files
    lang_dirs = [
        ('English', base_dir / 'resources' / 'strings' / 'strings.xml'),
        ('Swedish', base_dir / 'resources-swe' / 'strings' / 'strings.xml'),
        ('French', base_dir / 'resources-fre' / 'strings' / 'strings.xml'),
        ('Italian', base_dir / 'resources-ita' / 'strings' / 'strings.xml'),
        ('Polish', base_dir / 'resources-pol' / 'strings' / 'strings.xml'),
    ]

    # Collect all labels with widths
    all_data = []

    for lang_name, xml_path in lang_dirs:
        if not xml_path.exists():
            print(f"Warning: {xml_path} not found")
            continue

        labels = parse_strings_xml(xml_path)

        for label_id, text in labels.items():
            width = calculate_text_width(text, char_widths)
            category = categorize_label(label_id)
            all_data.append({
                'language': lang_name,
                'label_id': label_id,
                'text': text,
                'width': width,
                'length': len(text),
                'category': category
            })

    # Generate report
    print("=" * 80)
    print("LABEL WIDTH ANALYSIS USING storre.fnt")
    print("=" * 80)
    print()

    # Group by category
    by_category = defaultdict(list)
    for data in all_data:
        by_category[data['category']].append(data)

    # Report for each category - show ALL widest labels by unique label ID
    for category in ['1', '2', '3']:
        if category not in by_category:
            continue

        items = by_category[category]

        # Group by label ID to find the widest version of each label
        by_label_id = defaultdict(list)
        for item in items:
            by_label_id[item['label_id']].append(item)

        # Find the widest version of each label
        widest_per_label = []
        for label_id, versions in by_label_id.items():
            widest = max(versions, key=lambda x: x['width'])
            widest_per_label.append(widest)

        widest_per_label.sort(key=lambda x: x['width'], reverse=True)

        print(f"\n{'=' * 100}")
        print(f"LABELS ENDING WITH _{category}")
        print(f"{'=' * 100}")
        print(f"Total unique labels: {len(widest_per_label)}")
        print(f"Showing widest version of each label across all languages")
        print()
        print(f"{'Width':<8} {'Chars':<8} {'Language':<12} {'Label ID':<30} {'Text'}")
        print("-" * 100)

        # Show top 30 widest
        for item in widest_per_label[:30]:
            print(f"{item['width']:<8} {item['length']:<8} {item['language']:<12} {item['label_id']:<30} {item['text']}")

        # Statistics
        widths = [item['width'] for item in widest_per_label]
        print()
        print(f"Statistics for _{category} labels:")
        print(f"  Max width: {max(widths)}px")
        print(f"  Min width: {min(widths)}px")
        print(f"  Average width: {sum(widths)/len(widths):.1f}px")

        # Count how many exceed certain thresholds
        over_100 = sum(1 for w in widths if w > 100)
        over_90 = sum(1 for w in widths if w > 90)
        over_80 = sum(1 for w in widths if w > 80)
        over_70 = sum(1 for w in widths if w > 70)

        if over_100:
            print(f"  Labels over 100px: {over_100}")
        if over_90:
            print(f"  Labels over 90px: {over_90}")
        if over_80:
            print(f"  Labels over 80px: {over_80}")
        if over_70:
            print(f"  Labels over 70px: {over_70}")

    print("\n")

if __name__ == '__main__':
    main()
