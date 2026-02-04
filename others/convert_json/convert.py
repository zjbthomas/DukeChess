#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path
import xml.etree.ElementTree as ET
from typing import Any, Dict, List, Optional

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
    Group <target> by <type>, collecting destinations into lists.

    Output example:
      [{"type": "Move", "destination": ["U","D"]},
       {"type": "Strike", "destination": ["UU"]}]
    """
    if targets_elem is None:
        return []

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


def parse_auras(side_elem: Optional[ET.Element]) -> List[Dict[str, Any]]:
    """
    From:
      <front|back>
        <auras>
          <aura>
            <targets>...</targets>
          </aura>
        </auras>
      </front|back>

    To:
      [
        {"targets": [ {type,destination[...]}, ... ]},
        ...
      ]
    """
    if side_elem is None:
        return []

    out: List[Dict[str, Any]] = []
    for aura in side_elem.findall("./auras/aura"):
        targets = _group_targets_by_type(aura.find("./targets"))
        aura_obj: Dict[str, Any] = {}
        aura_obj["targets"] = targets
        out.append(aura_obj)

    return out


def parse_center(root: ET.Element) -> Dict[str, Any]:
    center_obj: Dict[str, Any] = {}
    back_center = _text(root.find("./back/center"))
    if back_center is not None:
        center_obj["back"] = back_center
    front_center = _text(root.find("./front/center"))
    if front_center is not None:
        center_obj["front"] = front_center
    return center_obj


def convert_one(xml_path: Path, input_root: Path, output_root: Path) -> Path:
    rel = xml_path.relative_to(input_root)
    out_path = (output_root / rel).with_suffix(".json")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    tree = ET.parse(xml_path)
    root = tree.getroot()  # <chess ...>

    data: Dict[str, Any] = {}
    data["name"] = root.attrib.get("name")
    data["version"] = _coerce_int_if_possible(root.attrib.get("version"))

    loc = parse_localization(root)
    if loc:
        data["localization"] = loc

    center = parse_center(root)
    if center:
        data["center"] = center

    front = root.find("./front")
    back = root.find("./back")

    data["front-movements"] = parse_movements(front)
    data["back-movements"] = parse_movements(back)

    # NEW: auras
    front_auras = parse_auras(front)
    back_auras = parse_auras(back)
    if front_auras:
        data["front-auras"] = front_auras
    if back_auras:
        data["back-auras"] = back_auras

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
