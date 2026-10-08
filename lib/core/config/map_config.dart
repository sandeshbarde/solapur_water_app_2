/// Map configuration.
/// The optional Stadia / MapTiler API key is injected at build time via --dart-define.
/// Defaults to standard OpenStreetMap raster / OpenFreeMap vector styles without requiring any API key or showing watermarks.
///
/// Usage:
///   flutter run --dart-define=STADIA_MAPS_API_KEY=YOUR_KEY_HERE
///   flutter build apk --dart-define=STADIA_MAPS_API_KEY=YOUR_KEY_HERE
class MapConfig {
  static const String stadiaMapsApiKey = String.fromEnvironment(
    'STADIA_MAPS_API_KEY',
    defaultValue: '',
  );

  /// Solapur Municipal City Centre coordinates
  static const double solapurLat = 17.6599;
  static const double solapurLng = 75.9064;
  static const double defaultZoom = 13.0;

  /// OpenStreetMap / OpenFreeMap Tile URL without watermark or required keys
  static String get lightTileUrl {
    if (stadiaMapsApiKey.isNotEmpty) {
      return 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$stadiaMapsApiKey';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  /// Dark variant for dark mode
  static String get darkTileUrl {
    if (stadiaMapsApiKey.isNotEmpty) {
      return 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$stadiaMapsApiKey';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  /// Subdomains for OSM raster tiles
  static const List<String> freeSubdomains = ['a', 'b', 'c'];

  /// Attribution text
  static String get attribution {
    if (stadiaMapsApiKey.isNotEmpty) {
      return '© Stadia Maps, © OpenMapTiles, © OpenStreetMap contributors';
    }
    return '© OpenStreetMap contributors';
  }
}
