import 'package:flutter/material.dart';

class InfoCardModel {
  final String title;
  final String info;
  final String value;
  final String type;
  final IconData icon;
  final Color color;

  InfoCardModel({
    required this.title,
    required this.info,
    required this.value,
    required this.type,
    required this.icon,
    required this.color,
  });

  static const Map<String, IconData> _iconMap = {
    'home': Icons.home,
    'star': Icons.star,
    'error': Icons.error,
    'inventory': Icons.inventory,
    'inventory_2': Icons.inventory_2,
    'warning_amber': Icons.warning_amber,
    'shopping_cart': Icons.shopping_cart,
    'attach_money': Icons.attach_money,
  };

  factory InfoCardModel.fromJson(Map<String, dynamic> json) {
    return InfoCardModel(
      title: json['title'] as String,
      info: json['info'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      icon: _iconMap[json['icon']] ?? Icons.error,
      color: json['color'] != null ? Color(json['color']) : Colors.black,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'info': info,
      'type': type,
      'value': value,
      'icon':
          _iconMap.entries
              .firstWhere(
                (entry) => entry.value == icon,
                orElse: () => MapEntry('error', Icons.error),
              )
              .key,
      'color': color.value,
    };
  }
}
