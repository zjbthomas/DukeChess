import xml.etree.ElementTree as ET
import os

def handle_movement(style, new_movement):
    new_action = ET.SubElement(new_movement, 'action')
    new_action.text = action

    new_targets = ET.SubElement(new_movement, 'targets')

    for target in style.findall('./targets/target'):
        new_target = ET.SubElement(new_targets, 'target')

        destination = target.find('./destination').text

        new_destination = ET.SubElement(new_target, 'destination')
        new_destination.text = destination

        movement = target.find('./movement').text

        new_type = ET.SubElement(new_target, 'type')
        new_type.text = movement

for chess in ET.parse("..\\dukechess\\resources\\Chess.xml") .getroot().findall('./chess'):
    chess_name = chess.attrib['name']

    new_root = ET.Element('chess')
    new_root.set('name', chess_name)
    new_root.set('version', '1')

    new_front = ET.SubElement(new_root, 'front')
    new_back = ET.SubElement(new_root, 'back')

    new_front_movements = ET.SubElement(new_front, 'movements')
    new_back_movements = ET.SubElement(new_back, 'movements')

    for style in chess.findall('./styles/style'):
        action = style.find('./action').text

        if (action != 'Summon'):
            starter = int(style.find('./starter').text)

            if (starter == 1):
                new_movement = ET.SubElement(new_front_movements, 'movement')
            else:
                new_movement = ET.SubElement(new_back_movements, 'movement')

            handle_movement(style, new_movement) 
        else:
            for new_movements in [new_front_movements, new_back_movements]:
                new_movement = ET.SubElement(new_movements, 'movement')
                handle_movement(style, new_movement)

    os.makedirs('./' + chess_name)
    f = open('./' + chess_name + '/' + chess_name + '.xml', 'wb')
    tree = ET.ElementTree(new_root)
    ET.indent(tree, space="    ", level=0)
    tree.write(f)
    f.close()


