#!/usr/bin/env python3
import os
import re
import json
from collections import defaultdict

ROOT = os.path.abspath(os.curdir)
# Directory name fragments to skip
SKIP_DIRS = {'.git','build','android/.gradle','.dart_tool','.idea','.gradle'}
EXTS = {'.dart','.kt','.java','.kts','.xml','.gradle','.swift','.h','.m','.mm','.js','.ts','.jsx','.tsx','.yaml','.yml','.properties','.css','.scss','.html','.plist','.gradle.kts'}

single_line_c = re.compile(r'//.*')
multiline_c = re.compile(r'/\*.*?\*/', re.S)
shebang = re.compile(r'^#!')
hash_comment = re.compile(r'(^|\s)#.*')

report = {}
file_counts = defaultdict(int)
file_samples = defaultdict(list)

for dirpath, dirnames, filenames in os.walk(ROOT):
    # skip build and other heavy dirs
    if any(skip in dirpath for skip in SKIP_DIRS):
        continue
    for fname in filenames:
        ext = os.path.splitext(fname)[1].lower()
        if ext not in EXTS:
            continue
        fpath = os.path.join(dirpath, fname)
        try:
            with open(fpath, 'r', encoding='utf-8') as f:
                text = f.read()
        except Exception:
            continue
        matches = []
        # multiline C-style
        for m in multiline_c.findall(text):
            matches.append(('multiline_c', m.strip().splitlines()[0] if m.strip() else ''))
        # single-line C++ style
        for m in single_line_c.findall(text):
            # avoid http:// and https:// and http(s) inside strings naive check
            if 'http://' in m or 'https://' in m:
                # keep but mark
                matches.append(('single', m.strip()))
            else:
                matches.append(('single', m.strip()))
        # hash comments for yaml/properties/shell
        if ext in {'.yaml','.yml','.properties','.plist'}:
            for line in text.splitlines():
                if '#' in line:
                    # ignore shebang
                    if shebang.match(line.strip()):
                        continue
                    idx = line.find('#')
                    # simple heuristic: if # is inside quotes, skip
                    left = line[:idx]
                    if left.count('"')%2==0 and left.count("'")%2==0:
                        matches.append(('hash', line[idx:].strip()))
        if matches:
            file_counts[fpath] = len(matches)
            file_samples[fpath] = matches[:5]

# make a sorted report
items = sorted(file_counts.items(), key=lambda x: x[1], reverse=True)
summary = {
    'root': ROOT,
    'total_files_with_comments': len(items),
    'files': [{ 'path': p, 'count': c, 'samples': file_samples[p]} for p,c in items]
}
out_path = os.path.join('scripts','comment_report.json')
with open(out_path, 'w', encoding='utf-8') as out_f:
    json.dump(summary, out_f, indent=2, ensure_ascii=False)

# Print concise summary
print(f"Scanned root: {ROOT}")
print(f"Files with detected comments: {summary['total_files_with_comments']}")
print('Top 20 files:')
for item in summary['files'][:20]:
    print(f"{item['count']:4d}  {item['path']}")
print('\nReport written to', out_path)
