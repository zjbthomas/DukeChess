#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import xml.etree.ElementTree as ET
from typing import Any, Dict, List, Optional

# -----------------------------
# CONFIG (edit these two paths)
# -----------------------------
INPUT_DIR = Path(r"E:\eDocs\Personal\DukeChess\Godot\chess")     # e.g., ./chess/Assassin/Assassin.xml
OUTPUT_DIR = Path(r"E:\eDocs\Personal\chess-json")   # e.g., ./output/Assassin/Assassin.json


def _text(elem: Optional[ET.Element]) -> Optional[str]:
    if elem is None or elem.text is None:
        return None
    s = elem.text.strip()
    return s if s else None


def _coerce_int_if_possible(v: Optional[str]) -> Any:
    if v is None:
        return None
    s = v.strip()
    if s == "":
        return None
    try:
        return int(s)
    except ValueError:
        return s


def parse_localization(root: ET.Element) -> List[Dict[str, str]]:
    """
    From:
      <localization><zh>刺客</zh>...</localization>
    To:
      [{"zh": "刺客", ...}]
    Always returns a LIST (matches sample).
    """
    out: List[Dict[str, str]] = []
    for loc in root.findall("./localization"):
        obj: Dict[str, str] = {}
        for child in list(loc):
            key = child.tag
            val = _text(child)
            if val is not None:
                obj[key] = val
        if obj:
            out.append(obj)
    return out


def parse_targets(targets_elem: Optional[ET.Element]) -> List[Dict[str, Any]]:
    """
    From:
      <targets>
        <target><destination>UU</destination><type>JumpSlide</type></target>
        ...
      </targets>
    To:
      [{"type": "...", "destination": "..."}, ...]
    Key order: type then destination (as requested).
    """
    if targets_elem is None:
        return []

    out: List[Dict[str, Any]] = []
    for tgt in targets_elem.findall("./target"):
        typ = _text(tgt.find("./type"))
        dest = _text(tgt.find("./destination"))

        # Enforce insertion order: type first, then destination
        obj: Dict[str, Any] = {}
        obj["type"] = typ
        obj["destination"] = dest
        out.append(obj)
    return out


def parse_movements(side_elem: Optional[ET.Element]) -> List[Dict[str, Any]]:
    """
    From:
      <front><movements><movement>...</movement></movements></front>
    To:
      [{"action": "...", "targets": [...]}, ...]
    """
    if side_elem is None:
        return []

    out: List[Dict[str, Any]] = []
    for mv in side_elem.findall("./movements/movement"):
        action = _text(mv.find("./action"))
        targets = parse_targets(mv.find("./targets"))

        mv_obj: Dict[str, Any] = {}
        mv_obj["action"] = action
        mv_obj["targets"] = targets
        out.append(mv_obj)

    return out


def convert_one(xml_path: Path, input_root: Path, output_root: Path) -> Path:
    """
    Convert one XML file, preserving directory structure:
      output_root / (xml_path relative to input_root) with .json extension
    """
    rel = xml_path.relative_to(input_root)
    out_path = (output_root / rel).with_suffix(".json")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    tree = ET.parse(xml_path)
    root = tree.getroot()

    data: Dict[str, Any] = {}

    # Root attributes => top-level keys (no "chess", no "@attributes")
    data["name"] = root.attrib.get("name")
    data["version"] = _coerce_int_if_possible(root.attrib.get("version"))

    # localization => list of dicts
    loc = parse_localization(root)
    if loc:
        data["localization"] = loc

    # front/back flattened => front-movements / back-movements
    data["front-movements"] = parse_movements(root.find("./front"))
    data["back-movements"] = parse_movements(root.find("./back"))

    with out_path.open("w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

    return out_path


def main() -> None:
    input_root = INPUT_DIR.resolve()
    output_root = OUTPUT_DIR.resolve()

    if not input_root.exists() or not input_root.is_dir():
        raise SystemExit(f"INPUT_DIR does not exist or is not a directory: {input_root}")

    xml_files = sorted(input_root.rglob("*.xml"))
    if not xml_files:
        print(f"No .xml files found under: {input_root}")
        return

    print(f"Found {len(xml_files)} XML file(s) under {input_root}")
    for xml_path in xml_files:
        try:
            out_path = convert_one(xml_path, input_root, output_root)
            print(f"✓ {xml_path} -> {out_path}")
        except Exception as e:
            print(f"✗ Failed: {xml_path} ({e})")


if __name__ == "__main__":
    main()
