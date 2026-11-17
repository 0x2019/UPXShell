# UPX Shell

![License](https://img.shields.io/badge/License-GPL_2.0-blue.svg)
![Platform](https://img.shields.io/badge/Windows-7%2B-green)
![Delphi](https://img.shields.io/badge/Made%20with-Delphi%2012.1-orange)

UPX Shell - A GUI front-end for the UPX executable packer.
<br>
<br>
Created by Michael Hardy | Modified by 龍.

## 🌐 Language
English

## 📥 Download
Not yet available.

## 📄 License
This project is licensed under the GPL 2.0 License – see the [LICENSE](LICENSE) file for details.

## 🛠 Changes (Delphi 5.0 port & fixes)

### Delphi 5.0 compatibility
- Downgraded sources/DFMs/resources to build with **Delphi 5.0** (`dcc32` 13.0, `UPXMiracle.cfg`).
- Replaced newer-RTL/VCL APIs and constructs unsupported by D5 (`TEncoding`/`TBytes`/`TryStrTo*`/`FormatSettings`/`TStrings.DelimitedText`/`tkUString`/`CharInSet`/`Variants`/`MainFormOnTaskbar`/DFM published props like `ItemIndex`, `ParentBackground`, `DesignSize`, etc.).
- `UPXScrambler` rewritten without `TBytes/TEncoding`; manual `Split`/`JoinStrings`; `Globals`/`Compression`/`Shared`/`Translator`/forms adjusted accordingly. Sources kept cp1252 CRLF.

### Localization
- Added Simplified Chinese language pack: `Language\Chinese.lng` (GBK/CP936, CRLF), full key parity with `Language\English.lng`.
- Fixed hint translation on language switch: `Translator.TranslateForm` now applies `\n → CRLF` for hints; added missing `*.Hint` entries (Main/Setup/Multi forms, incl. Brute/Ultra Brute/filter/time/overlay etc.) to both `.lng` files.

### Compression / UPX options
- `GetCompressParams` emits only options supported by the bundled UPX versions:
  - Omit `--crp-ms`, `--no-lzma`, `--all-methods`, `--all-filters` (unsupported by bundled builds).
  - `--lzma` only for UPX 4.2.4 / 5.3.0; `--no-time` only when not UPX 3.09.
  - For bundled UPX, Brute/Ultra Brute emit `--brute` / `--ultra-brute` only.
- Fixes “all options checked” compression failures caused by unsupported flags.

### Resources & build
- `resources.rc` recompiled with D5 `brcc32`; help resources named correctly as `UPX1_HELP/UPX2_HELP/UPX3_HELP` (TEXTFILE) alongside `UPX1/UPX2/UPX3` (EXEFILE).
- `UPXMiracle.dpr` uses explicit resource includes: `{$R 'UPXMiracle.res'}` + `{$R 'resources.res'}` to avoid duplicate-resource / wildcard conflicts.
- Removed duplicate-resource and stale `UPXMiracle.str` / `UPXMiracle.drc` conflicts (incl. `RT_STRING` ID 65312 “ - Dock zone not found”); no `.str/.drc` generated.

### Toolchain / environment fix
- Repaired corrupted Delphi 5 VCL resource `D:\Application\Delphi5.0\Delphi5\lib\controls.res` (had ~2 MB garbage appended; restored to valid 2,776-byte cursor resources). The corruption caused `RLINK32: Too many resources to handle` for VCL projects.

### Build result (Delphi 5.0 / dcc32 13.0)
- Clean compile: **0 errors, 0 warnings, 0 hints** (`5127 lines, 472368 bytes code, 7489 bytes data`), outputs `UPXMiracle.exe`.
- Note: on modern Windows, D5 `rlink32` may require XP compatibility for VCL linking, e.g. `cmd /c "set __COMPAT_LAYER=WINXPSP3 && dcc32.exe UPXMiracle.dpr"` (and in IDE set compatibility for `dcc32`/`rlink32` or the IDE, then **Build** after cleaning `*.dcu`). Keep build outputs/scripts writing only inside the project directory (do not overwrite files under the Delphi `lib` path).
