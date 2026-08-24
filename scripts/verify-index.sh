#!/usr/bin/env bash
# verify-index.sh — sprawdza lokalne pliki względem indeksu wskazanego przez pack.toml.
# Odpalaj po każdym pushu packa; rozjazd = klienci nie wstaną (packwiz-installer Hash invalid).
set -euo pipefail

cd "$(dirname "$0")/.."

python - <<'PY'
import hashlib
import pathlib
import re
import sys

root = pathlib.Path.cwd()
pack_path = root / "pack.toml"

try:
    pack_text = pack_path.read_text(encoding="utf-8")
except OSError as exception:
    print(f"BLAD - nie mozna odczytac {pack_path.name}: {exception}")
    sys.exit(1)

index_match = re.search(
    r'(?ms)^\[index\]\s*.*?^file\s*=\s*"([^"]+)"\s*$',
    pack_text,
)
if index_match is None:
    print("BLAD - pack.toml nie wskazuje pliku w sekcji [index]")
    sys.exit(1)

index_name = index_match.group(1)
index_path = root / index_name
try:
    index_text = index_path.read_text(encoding="utf-8")
except OSError as exception:
    print(f"BLAD - nie mozna odczytac indeksu {index_name}: {exception}")
    sys.exit(1)

blocks = re.split(r'(?m)^\[\[files\]\]\s*$', index_text)[1:]
if not blocks:
    print(f"BLAD - indeks {index_name} nie zawiera wpisow [[files]]")
    sys.exit(1)

bad = 0
checked = 0
for block in blocks:
    file_match = re.search(r'(?m)^file\s*=\s*"([^"]+)"\s*$', block)
    hash_match = re.search(r'(?m)^hash\s*=\s*"([a-fA-F0-9]{64})"\s*$', block)
    if file_match is None or hash_match is None:
        print("BLAD - niepelny wpis [[files]] w indeksie")
        bad += 1
        continue

    relative_name = file_match.group(1)
    expected_hash = hash_match.group(1).lower()
    file_path = root / relative_name
    if not file_path.is_file():
        print("BRAK:", relative_name)
        bad += 1
        continue

    actual_hash = hashlib.sha256(file_path.read_bytes()).hexdigest()
    checked += 1
    if actual_hash != expected_hash:
        print("ROZJAZD:", relative_name)
        bad += 1

status = "OK" if bad == 0 else "BLAD"
print(f"{status} - indeks: {index_name}, sprawdzono: {checked}, problemy: {bad}")
sys.exit(1 if bad else 0)
PY
