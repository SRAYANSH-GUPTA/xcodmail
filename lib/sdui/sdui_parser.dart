import 'package:flutter/material.dart';
import 'components/sdui_text.dart';
import 'components/sdui_button.dart';
import 'components/sdui_column.dart';
import 'components/sdui_row.dart';
import 'components/sdui_image.dart';
import 'components/sdui_list.dart';
import 'components/sdui_card.dart';
import 'components/sdui_input.dart';

class SDUIParser {
  static Widget parse(Map<String, dynamic> json) {
    String type = json['type'];
    Map<String, dynamic> properties = json['properties'] ?? {};
    List<dynamic> childrenJson = json['children'] ?? [];
    Map<String, dynamic>? action = json['action'];

    List<Widget> children = childrenJson.map((child) => parse(child)).toList();

    switch (type) {
      case 'text':
        return SDUIText(properties: properties);
      case 'button':
        return SDUIButton(properties: properties, action: action);
      case 'column':
        return SDUIColumn(children: children, properties: properties);
      case 'row':
        return SDUIRow(children: children, properties: properties);
      case 'image':
        return SDUIImage(properties: properties);
      case 'list':
        return SDUIList(children: children, properties: properties);
      case 'card':
        return SDUICard(children: children, properties: properties);
      case 'input':
        return SDUIInput(properties: properties);
      default:
        return SizedBox.shrink();
    }
  }
}
