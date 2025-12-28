#!/usr/bin/env python3
"""
Fetch SCASM source files from txbobsc.com and save as .s files
"""

import os
import re
import sys
import subprocess
from html.parser import HTMLParser
from pathlib import Path


class SourceExtractor(HTMLParser):
    """Extract source code from <pre> tags"""

    def __init__(self):
        super().__init__()
        self.in_pre = False
        self.source_code = []

    def handle_starttag(self, tag, attrs):
        if tag == 'pre':
            self.in_pre = True

    def handle_endtag(self, tag):
        if tag == 'pre':
            self.in_pre = False

    def handle_data(self, data):
        if self.in_pre:
            self.source_code.append(data)

    def get_source(self):
        return ''.join(self.source_code)


# All source files organized by directory
SOURCE_FILES = {
    'ASM1': [
        'X.ACF',
        'X.NEW.QUOTES',
        'X.TABLES.DIREC',
        'X.ASM.VECTORS',
        'IO.STANDARD',
        'IO.STB80',
        'IO.TWO.E',
        'IO.ULTRA',
        'IO.VIDEX',
    ],
    'ASM2': [
        'SC.LOADER',
        'X.DATA',
        'X.PARAMETERS',
        'X.EDIT',
        'X.MISC.COMMANDS',
        'X.SEARCH.COMMA',
        'X.TEXT.SEARCH',
        'X.FIND.AND.REP',
        'X.READ.LINE',
        'X.EDIT.LINES',
        'X.OUTPUT.ROUTI',
        'X.DISK.OPERATI',
        'X.PARSE.LINE.R',
        'X.ASM.GENERAL',
        'X.ASM.NEXT.LINE',
        'X.EXPRESSION.C',
        'X.SYMBOL.TABLE',
        'X.PRINT.SYMBOLS',
        'X.MACRO',
        'X.DIRECTIVES.1',
        'X.DIRECTIVES.2',
        'X.AC.DIRECTIVE',
    ],
    'ASM65816': [
        'X.ACF',
        'X.DATA',
        'X.ASM.LINKAGE',
        'X.ASM.65816.1',
        'X.ASM.65816.2',
        'X.OP.DIRECTIVE',
        'X.TABLES.65816',
    ],
    'SCI': [
        'SC',
        'SC.EQUATES',
        'SC.COMMAND.PAR',
        'SC.CATALOG',
        'SC.EXEC',
        'SC.ONLINE',
        'SC.PR.IN',
        'SC.ERRORS',
        'SC.LOAD.SAVE',
        'SC.OPEN.CLOSE',
        'SC.RWPA',
        'SC.TABLES',
        'SC.VARIABLES',
        'SC.GLOBAL.PAGE',
        'S.NOW',
    ],
    'ASM6811': [
        'X.ACF',
        'X.DATA',
        'XASM.LOADER',
        'X.ASM.LINKAGE',
        'X.ASM.6811',
        'X.OP.DIRECTIVE',
        'OPTEST.6811',
    ],
}

BASE_URL = 'https://www.txbobsc.com/scsc/scassembler'


def fetch_source(directory, filename):
    """Fetch a single source file and extract the assembly code"""
    url = f'{BASE_URL}/{directory}/{filename}.html'
    print(f'Fetching {directory}/{filename}...', end=' ')

    try:
        result = subprocess.run(
            ['curl', '-s', url],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode != 0:
            print(f'✗ (curl failed)')
            return None

        html = result.stdout
        parser = SourceExtractor()
        parser.feed(html)
        source = parser.get_source()

        if source.strip():
            print('✓')
            return source
        else:
            print('✗ (no source found)')
            return None

    except Exception as e:
        print(f'✗ ({e})')
        return None


def main():
    """Download all source files"""

    # Create source directories
    for directory in SOURCE_FILES.keys():
        Path(directory).mkdir(exist_ok=True)

    downloaded = 0
    failed = 0

    for directory, files in SOURCE_FILES.items():
        for filename in files:
            source = fetch_source(directory, filename)

            if source:
                # Save as .s file
                output_path = Path(directory) / f'{filename}.s'
                with open(output_path, 'w') as f:
                    f.write(source)
                downloaded += 1
            else:
                failed += 1

    print(f'\nDownloaded: {downloaded} files')
    if failed > 0:
        print(f'Failed: {failed} files')

    return 0 if failed == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
