import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String logoPath;
  final Color color;

  ServiceModel({
    required this.id, 
    required this.name, 
    required this.logoPath, 
    this.color = Colors.blue
  });
}