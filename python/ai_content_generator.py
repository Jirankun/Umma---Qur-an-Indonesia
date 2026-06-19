#!/usr/bin/env python3
"""
AI Content Generator untuk Umma App
====================================
Menghasilkan konten Fiqih, Hadits, dan Quotes menggunakan Groq API.
Konteks konten menyesuaikan tanggal (Ramadhan vs non-Ramadhan).
Dilengkapi caching untuk menghemat kredit AI.

Cara pakai:
  python3 ai_content_generator.py                 # Generate semua kategori
  python3 ai_content_generator.py --type fiqih    # Hanya Fiqih
  python3 ai_content_generator.py --type hadits   # Hanya Hadits
  python3 ai_content_generator.py --type quotes   # Hanya Quotes
  python3 ai_content_generator.py --force         # Paksa generate (abaikan cache)
"""

import json
import os
import re
import sys
import time
from datetime import datetime, date
from typing import Optional
from pathlib import Path

try:
    import requests
except ImportError:
    print("❌ 'requests' library tidak ditemukan. Install dengan: pip3 install requests")
    sys.exit(1)

# ─── Konfigurasi ───────────────────────────────────────────────
GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")
GROQ_BASE_URL = "https://api.groq.com/openai/v1/chat/completions"
GROQ_MODEL = "llama-3.3-70b-versatile"

# Cache settings (dalam jam)
CACHE_DURATION_HOURS = {
    "fiqih": 48,
    "hadits": 24,
    "quotes": 12,
}

# Delay antar kategori (detik) — hindari rate limit
DELAY_BETWEEN_CALLS = 3

# Output directory (relatif ke script ini)
SCRIPT_DIR = Path(__file__).parent.resolve()
OUTPUT_DIR = SCRIPT_DIR / "generated"
FIQIH_DIR = OUTPUT_DIR / "fiqih"
HADITS_DIR = OUTPUT_DIR / "hadits"
QUOTES_DIR = OUTPUT_DIR / "quotes"

# ─── Deteksi Ramadhan ───────────────────────────────────────────
RAMADHAN_RANGES = [
    (2026, 2, 18, 2026, 3, 19),  # Ramadhan 1447 H
    (2027, 2, 7, 2027, 3, 8),
    (2028, 1, 27, 2028, 2, 25),
]


def is_ramadhan_season(check_date: date = None) -> bool:
    if check_date is None:
        check_date = date.today()
    for start_y, start_m, start_d, end_y, end_m, end_d in RAMADHAN_RANGES:
        start = date(start_y, start_m, start_d)
        end = date(end_y, end_m, end_d)
        start_extended = date.fromordinal(start.toordinal() - 7)
        end_extended = date.fromordinal(end.toordinal() + 3)
        if start_extended <= check_date <= end_extended:
            return True
    return False


def get_month_name_en(month: int) -> str:
    names = ["", "January", "February", "March", "April", "May", "June",
             "July", "August", "September", "October", "November", "December"]
    return names[month] if 1 <= month <= 12 else ""


# ─── JSON Parser (handle code fences) ──────────────────────────

def extract_json_array(text: str) -> Optional[list]:
    """Extract JSON array from text, handling markdown code fences."""
    if not text:
        return None

    # Remove markdown code fences
    text = re.sub(r'```json\s*', '', text)
    text = re.sub(r'```\s*', '', text)

    # Try direct parse
    try:
        items = json.loads(text)
        if isinstance(items, list):
            return items
    except json.JSONDecodeError:
        pass

    # Try to find array in the text using regex
    match = re.search(r'\[\s*\{', text)
    if match:
        start = match.start()
        # Find matching closing bracket
        depth = 0
        for i in range(start, len(text)):
            if text[i] == '[':
                depth += 1
            elif text[i] == ']':
                depth -= 1
                if depth == 0:
                    try:
                        items = json.loads(text[start:i + 1])
                        if isinstance(items, list):
                            return items
                    except json.JSONDecodeError:
                        pass
                    break

    # Last resort: try to parse line by line
    try:
        # Maybe it's a JSONL format or each line is a JSON object
        lines = text.strip().split('\n')
        items = []
        for line in lines:
            line = line.strip()
            if line and line.startswith('{') and line.endswith('}'):
                try:
                    items.append(json.loads(line))
                except json.JSONDecodeError:
                    pass
        if items:
            return items
    except Exception:
        pass

    return None


# ─── Cache Helpers ──────────────────────────────────────────────

def get_cache_path(category: str) -> Path:
    paths = {
        "fiqih": FIQIH_DIR / "ai_fiqih_items.json",
        "hadits": HADITS_DIR / "ai_hadits_items.json",
        "quotes": QUOTES_DIR / "ai_quotes_items.json",
    }
    return paths.get(category, OUTPUT_DIR / f"{category}.json")


def get_metadata_path(category: str) -> Path:
    return get_cache_path(category).with_suffix(".meta.json")


def is_cache_valid(category: str) -> bool:
    meta_path = get_metadata_path(category)
    if not meta_path.exists():
        return False
    try:
        with open(meta_path, "r") as f:
            meta = json.load(f)
        generated_at = meta.get("generated_at", 0)
        age_hours = (time.time() - generated_at) / 3600
        max_age = CACHE_DURATION_HOURS.get(category, 24)
        return age_hours < max_age and meta.get("status") == "success" and meta.get("item_count", 0) > 0
    except (json.JSONDecodeError, KeyError, OSError):
        return False


def save_cache(category: str, data: list, extra_meta: dict = None):
    cache_path = get_cache_path(category)
    meta_path = get_metadata_path(category)
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    with open(cache_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    meta = {
        "generated_at": time.time(),
        "generated_at_iso": datetime.now().isoformat(),
        "category": category,
        "item_count": len(data),
        "status": "success",
        "ramadhan_mode": is_ramadhan_season(),
        **(extra_meta or {}),
    }
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print(f"  ✅ Cache tersimpan: {cache_path.name} ({len(data)} items)")


def read_cache(category: str) -> Optional[list]:
    if not is_cache_valid(category):
        return None
    cache_path = get_cache_path(category)
    try:
        with open(cache_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return data if isinstance(data, list) else None
    except (json.JSONDecodeError, OSError):
        return None


# ─── API Call ───────────────────────────────────────────────────

def call_groq(system_prompt: str, user_prompt: str, temperature: float = 0.7) -> Optional[str]:
    if not GROQ_API_KEY:
        print("  ⚠️  GROQ_API_KEY tidak diset.")
        return None

    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {GROQ_API_KEY}",
    }

    payload = {
        "model": GROQ_MODEL,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        "temperature": temperature,
        "max_tokens": 4096,
        "top_p": 0.9,
    }

    try:
        resp = requests.post(GROQ_BASE_URL, headers=headers, json=payload, timeout=180)
        resp.raise_for_status()
        data = resp.json()
        content = data["choices"][0]["message"]["content"]
        return content
    except requests.exceptions.HTTPError as e:
        print(f"  ❌ HTTP Error: {e}")
        if hasattr(e, 'response') and e.response is not None:
            print(f"     Response: {e.response.text[:300]}")
        return None
    except requests.exceptions.RequestException as e:
        print(f"  ❌ Gagal panggil Groq API: {e}")
        return None
    except (KeyError, IndexError, json.JSONDecodeError) as e:
        print(f"  ❌ Gagal parse response: {e}")
        return None


# ─── Generator Functions ────────────────────────────────────────

def generate_fiqih() -> list:
    """Generate konten Fiqih via AI."""
    now = date.today()
    ramadhan = is_ramadhan_season(now)

    if ramadhan:
        system_prompt = """Kamu adalah ahli fiqih Islam untuk Muslim Indonesia.

Tugasmu: Hasilkan 30-40 item materi fiqih tentang PUASA RAMADHAN.
Setiap item harus informatif, akurat secara fiqih, dengan dalil yang jelas.

OUTPUT: Hanya array JSON. JANGAN GUNAKAN markdown atau teks lain.

SETIAP ITEM format:
{"id": "ai_fiqih_1", "title": "judul", "content": "isi materi", "category": "puasa", "source": "dalil"}

GUNAKAN BAHASA INDONESIA. Sertakan dalil."""
    else:
        system_prompt = """Kamu adalah ahli fiqih Islam untuk Muslim Indonesia.

Tugasmu: Hasilkan 40-50 item materi fiqih ISLAM secara umum.
Topik: thaharah, shalat, zakat, muamalah, pernikahan, jenazah, dan ibadah sehari-hari.

OUTPUT: Hanya array JSON. JANGAN GUNAKAN markdown atau teks lain.

SETIAP ITEM format:
{"id": "ai_fiqih_1", "title": "judul", "content": "isi", "category": "thaharah/sholat/zakat/muamalah/nikah/jenazah/amalan/puasa/doa", "source": "dalil"}

GUNAKAN BAHASA INDONESIA. Sertakan dalil."""

    user_prompt = f"Hasilkan konten fiqih untuk {now.day} {get_month_name_en(now.month)} {now.year}. {'Fokus puasa Ramadhan.' if ramadhan else 'Fokus fiqih umum.'} Berikan variasi topik."

    print(f"  📋 Generate Fiqih ({'Ramadhan' if ramadhan else 'Umum'})...")
    result = call_groq(system_prompt, user_prompt, temperature=0.7)

    if not result:
        return []

    items = extract_json_array(result)
    if items:
        return items

    print(f"  ⚠️  Gagal parse JSON. Response (300 chars): {result[:300]}")
    return []


def generate_hadits() -> list:
    """Generate konten Hadits via AI."""
    now = date.today()
    ramadhan = is_ramadhan_season(now)

    if ramadhan:
        system_prompt = """Kamu adalah ahli hadits untuk Muslim Indonesia.

Tugasmu: Hasilkan 20-30 hadits PILIHAN tentang PUASA RAMADHAN.
Setiap hadits shahih/hasan, dengan sanad jelas.

OUTPUT: Hanya array JSON. JANGAN GUNAKAN markdown.

SETIAP ITEM format:
{"id": "ai_hadits_1", "title": "judul", "content": "isi hadits", "source": "perawi"}

GUNAKAN BAHASA INDONESIA."""
    else:
        system_prompt = """Kamu adalah ahli hadits untuk Muslim Indonesia.

Tugasmu: Hasilkan 20-30 hadits PILIHAN tentang IMAN, IBADAH, AKHLAK.
Topik: shalat, sedekah, jujur, sabar, silaturahmi, ilmu, birrul walidain.

OUTPUT: Hanya array JSON. JANGAN GUNAKAN markdown.

SETIAP ITEM format:
{"id": "ai_hadits_1", "title": "judul", "content": "isi hadits", "source": "perawi"}

GUNAKAN BAHASA INDONESIA."""

    user_prompt = f"Hasilkan konten hadits untuk {now.day} {get_month_name_en(now.month)} {now.year}. {'Fokus hadits puasa Ramadhan.' if ramadhan else 'Fokus hadits umum tentang iman dan ibadah.'}"

    print(f"  📋 Generate Hadits ({'Ramadhan' if ramadhan else 'Umum'})...")
    result = call_groq(system_prompt, user_prompt, temperature=0.7)

    if not result:
        return []

    items = extract_json_array(result)
    if items:
        return items

    print(f"  ⚠️  Gagal parse JSON. Response (300 chars): {result[:300]}")
    return []


def generate_quotes() -> list:
    """Generate konten Quotes via AI."""
    now = date.today()
    ramadhan = is_ramadhan_season(now)

    if ramadhan:
        system_prompt = """Kamu adalah penulis konten Islami untuk Muslim Indonesia.

Tugasmu: Hasilkan 15-20 quotes INSPIRATIF tentang RAMADHAN.
Dari Al-Qur'an, Hadits, kata ulama, atau renungan Islami.

OUTPUT: Hanya array JSON. JANGAN GUNAKAN markdown.

SETIAP ITEM format:
{"id": "ai_quote_1", "text": "kutipan", "author": "sumber"}

GUNAKAN BAHASA INDONESIA."""
    else:
        system_prompt = """Kamu adalah penulis konten Islami untuk Muslim Indonesia.

Tugasmu: Hasilkan 15-20 quotes INSPIRATIF tentang ISLAM umum.
Topik: kehidupan, kesabaran, syukur, taubat, cinta Allah, ukhuwah.

OUTPUT: Hanya array JSON. JANGAN GUNAKAN markdown.

SETIAP ITEM format:
{"id": "ai_quote_1", "text": "kutipan", "author": "sumber"}

GUNAKAN BAHASA INDONESIA."""

    user_prompt = f"Hasilkan quotes Islami untuk {now.day} {get_month_name_en(now.month)} {now.year}. {'Fokus semangat Ramadhan.' if ramadhan else 'Fokus inspirasi Islami umum.'}"

    print(f"  📋 Generate Quotes ({'Ramadhan' if ramadhan else 'Umum'})...")
    result = call_groq(system_prompt, user_prompt, temperature=0.8)

    if not result:
        return []

    items = extract_json_array(result)
    if items:
        return items

    print(f"  ⚠️  Gagal parse JSON. Response (300 chars): {result[:300]}")
    return []


# ─── Main ────────────────────────────────────────────────────────

def generate(category: str, force: bool = False) -> bool:
    print(f"\n{'='*50}")
    print(f"📌 {category.upper()}")
    print(f"{'='*50}")

    if not force and is_cache_valid(category):
        print(f"  ✅ Cache masih valid ({CACHE_DURATION_HOURS[category]} jam).")
        cached = read_cache(category)
        if cached:
            print(f"  📦 {len(cached)} item dari cache.")
            return True

    generators = {
        "fiqih": generate_fiqih,
        "hadits": generate_hadits,
        "quotes": generate_quotes,
    }

    gen_func = generators.get(category)
    if not gen_func:
        print(f"  ❌ Kategori '{category}' tidak dikenal.")
        return False

    items = gen_func()
    if not items:
        print(f"  ❌ Gagal generate {category}.")
        return False

    save_cache(category, items)
    return True


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="AI Content Generator untuk Umma App")
    parser.add_argument("--type", "-t", choices=["fiqih", "hadits", "quotes", "all"],
                        default="all", help="Kategori konten")
    parser.add_argument("--force", "-f", action="store_true",
                        help="Paksa generate ulang")
    parser.add_argument("--check-date", action="store_true",
                        help="Cek Ramadhan")

    args = parser.parse_args()

    print(f"🕌 AI Content Generator — Umma App")
    print(f"📅 Tanggal: {date.today().isoformat()}")
    print(f"🌙 Ramadhan: {'YA' if is_ramadhan_season() else 'TIDAK'}")
    print(f"🔑 Groq API Key: {'✅ Terisi' if GROQ_API_KEY else '❌ KOSONG'}")

    if args.check_date:
        sys.exit(0)

    if not GROQ_API_KEY:
        print("\n❌ GROQ_API_KEY belum diset. Set dengan:")
        print('   export GROQ_API_KEY="gsk_your_key_here"')
        sys.exit(1)

    categories = ["fiqih", "hadits", "quotes"] if args.type == "all" else [args.type]

    success = True
    for i, cat in enumerate(categories):
        if i > 0:
            print(f"\n  ⏳ Delay {DELAY_BETWEEN_CALLS}s antar kategori...")
            time.sleep(DELAY_BETWEEN_CALLS)
        result = generate(cat, force=args.force)
        if not result:
            success = False

    print(f"\n{'='*50}")
    print("📊 RINGKASAN")
    print(f"{'='*50}")
    for cat in categories:
        cache_path = get_cache_path(cat)
        if cache_path.exists():
            size = os.path.getsize(cache_path)
            meta_path = get_metadata_path(cat)
            count = 0
            if meta_path.exists():
                try:
                    with open(meta_path) as f:
                        meta = json.load(f)
                        count = meta.get("item_count", 0)
                except Exception:
                    pass
            print(f"  ✅ {cat}: {count} items ({size / 1024:.1f} KB)")
        else:
            print(f"  ❌ {cat}: belum tergenerate")

    if success:
        print(f"\n✨ Semua konten berhasil digenerate!")
    else:
        print(f"\n⚠️  Beberapa konten gagal digenerate.")
        sys.exit(1)


if __name__ == "__main__":
    main()
