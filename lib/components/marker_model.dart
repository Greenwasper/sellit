import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerModel extends ChangeNotifier {
  Set<Marker> markers = {};

  void addMarker (Marker m) {
    markers.add(m);
    notifyListeners();
  }

  void removeMarker (LatLng latlng){
    markers.removeWhere((marker) => marker.position == latlng);
    notifyListeners();
  }

  void emptyMarkers () {
    markers = {};
    notifyListeners();
  }

  void setMarkers (Set<Marker> m) {
    markers = m;
    notifyListeners();
  }
}