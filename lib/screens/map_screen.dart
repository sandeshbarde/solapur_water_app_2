import 'package:flutter/material.dart';
import 'smart_water_map.dart';

/// Legacy alias forwarding to canonical Aqua Civic SmartWaterMap
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SmartWaterMap();
  }
}
