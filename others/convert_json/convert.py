#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import xml.etree.ElementTree as ET
from typing import Any, Dict, List, Optional, Tuple

# -----------------------------
# CONFIG (edit these two paths)
# -----------------------------
INPUT_DIR = Path(r"E:\eDocs\Personal\DukeChess\Godot\chess")
OUTPUT_DIR = Path(r"E:\eDocs\Personal\chess-json")


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
    <localization><zh>...</zh>...</localization>
      -> [{"zh": "...", ...}]
    Always returns a list.
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


def _group_targets_by_type(targets_elem: Optional[ET.Element]) -> List[Dict[str, Any]]:
    """
    XML:
      <targets>
        <target><destination>...</destination><type>Move</type></target>
        <target><destination>...</destination><type>Move</type></target>
        <target><destination>...</destination><type>Strike</type></target>
      </targets>

    JSON (grouped by type, preserving first-seen order of types):
      [
        {"type": "Move", "destination": ["...", "..."]},
        {"type": "Strike", "destination": ["..."]}
      ]

    Also enforces key order: type first, then destination.
    """
    if targets_elem is None:
        return []

    # Keep order of "type" groups by first appearance
    order: List[str] = []
    grouped: Dict[str, List[str]] = {}

    for tgt in targets_elem.findall("./target"):
        typ = _text(tgt.find("./type")) or ""
        dest = _text(tgt.find("./destination")) or ""

        if typ not in grouped:
            grouped[typ] = []
            order.append(typ)
        grouped[typ].append(dest)

    out: List[Dict[str, Any]] = []
    for typ in order:
        out.append({
            "type": typ,
            "destination": grouped[typ],
        })
    return out


def parse_movements(side_elem: Optional[ET.Element]) -> List[Dict[str, Any]]:
    """
    <front|back>
      <movements>
        <movement>
          <action>Move</action>
          <targets>...</targets>
        </movement>
      </movements>
    </front|back>

    -> [
         {"action": "...", "targets": [ {type,destination[...]}, ... ]},
         ...
       ]
    """
    if side_elem is None:
        return []

    out: List[Dict[str, Any]] = []
    for mv in side_elem.findall("./movements/movement"):
        action = _text(mv.find("./action"))
        targets = _group_targets_by_type(mv.find("./targets"))

        mv_obj: Dict[str, Any] = {}
        mv_obj["action"] = action
        mv_obj["targets"] = targets
        out.append(mv_obj)

    return out


def parse_center(root: ET.Element) -> Dict[str, Any]:
    """
    Sample 1 expects:
      <back><center>D</center></back>
    -> "center": {"back": "D"}

    Only include if the node exists and has non-empty text.
    """
    center_obj: Dict[str, Any] = {}
    back_center = _text(root.find("./back/center"))
    if back_center is not None:
        center_obj["back"] = back_center
    return center_obj


def convert_one(xml_path: Path, input_root: Path, output_root: Path) -> Path:
    """
    Convert one XML file, preserving directory structure:
      output_root / (xml_path relative to input_root) with .json extension
    """
    rel = xml_path.relative_to(input_root)
    out_path = (output_root / rel).with_suffix(".json")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    tree = ET.parse(xml_path)
    root = tree.getroot()  # <chess ...>

    data: Dict[str, Any] = {}

    # Root attributes -> top-level keys
    data["name"] = root.attrib.get("name")
    data["version"] = _coerce_int_if_possible(root.attrib.get("version"))

    # localization -> list of dicts
    loc = parse_localization(root)
    if loc:
        data["localization"] = loc

    # optional center (currently only back/center shown in sample)
    center = parse_center(root)
    if center:
        data["center"] = center

    # movements
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