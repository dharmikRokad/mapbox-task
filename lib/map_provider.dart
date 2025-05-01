import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:myapp/models/customer.dart';
import 'package:myapp/models/enums/store_level.dart';
import 'package:myapp/models/store.dart';
import 'package:myapp/utils/app_assets.dart';
import 'package:myapp/utils/app_keys.dart';
import 'package:myapp/utils/app_utils.dart';
import 'package:myapp/utils/marker_image_data.dart';

final Map<String, String> mapStyles = {
  AppKeys.streets: MapboxStyles.MAPBOX_STREETS,
  AppKeys.satellite: MapboxStyles.SATELLITE_STREETS,
  AppKeys.dark: MapboxStyles.DARK,
  AppKeys.light: MapboxStyles.LIGHT,
};

class MapProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Store> _stores = [];
  List<Customer> _customers = [];
  late MapboxMap _mapcontroller;
  late PointAnnotationManager _markerManager;

  final Map<String, bool> _filters = {
    StoreLevel.gold.name: true,
    StoreLevel.silver.name: true,
    StoreLevel.bronze.name: true,
    AppKeys.customers: true,
    AppKeys.visits: true,
  };

  String _selectedStyle = mapStyles[AppKeys.streets]!;

  bool get isLoading => _isLoading;
  List<Store> get stores => _stores;
  List<Customer> get customers => _customers;
  MapboxMap? get mapController => _mapcontroller;
  Map<String, bool> get filters => _filters;
  String get selectedStyle => _selectedStyle;

  void changeLoading(bool newLoading) {
    _isLoading = newLoading;
    notifyListeners();
  }

  void setStores(List<Store> stores) {
    _stores = stores;
    notifyListeners();
  }

  void setCustomer(List<Customer> customers) {
    _customers = customers;
    notifyListeners();
  }

  void changeMapController(MapboxMap newController) {
    _mapcontroller = newController;
    notifyListeners();
  }

  void changeFilter(String key, bool newValue) {
    _filters[key] = newValue;
    notifyListeners();
  }

  void changeMapStyle(String newStyle) {
    _selectedStyle = newStyle;
    _mapcontroller.loadStyleURI(newStyle);
    notifyListeners();
  }

  Future<void> onMapCreated(MapboxMap controlelr) async {
    changeMapController(controlelr);
    await Future.delayed(Duration(milliseconds: 300));
    _markerManager =
        await _mapcontroller.annotations.createPointAnnotationManager();

    addCurrentLocationMarker();
    await addStoreMarkers();
    await addcustomerMarkers();
  }

  void addCurrentLocationMarker() {
    _mapcontroller.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );
  }

  Future<void> addStoreMarkers() async {
    try {
      final List<PointAnnotationOptions> points = [];

      for (Store e in [..._stores.take(100)]) {
        log("stores image length => ${e.markerPath.length}");
        final point = PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              e.geoLocation.longitude,
              e.geoLocation.latitude,
            ),
          ),
          // image: e.markerPath,
          iconImage: AppAssets.goldGreen,
        );
        points.add(point);
      }
      await _markerManager.createMulti(points);
      log("added all store markers in the _mapController");
    } on Exception catch (e, s) {
      log('err - addStoreMarkers : $e');
      log('err - addStoreMarkers : $s');
    }
  }

  Future<void> addcustomerMarkers() async {
    // try {
    //   final List<PointAnnotationOptions> points = [];
    //   for (Customer e in [..._customers.take(100)]) {
    //     log("customer image length => ${e.marker.length}");
    //     final point = PointAnnotationOptions(
    //       geometry: Point(
    //         coordinates: Position(
    //           e.geoLocation.longitude,
    //           e.geoLocation.latitude,
    //         ),
    //       ),
    //       image: e.marker,
    //     );
    //     points.add(point);
    //   }
    //   await _markerManager.createMulti(points);
    //   log("added all customer markers in the _mapController");
    // } on Exception catch (e, s) {
    //   log('err - addcustomerMarkers : $e');
    //   log('err - addcustomerMarkers : $s');
    // }
  }

  Future<void> init() async {
    try {
      changeLoading(true);
      await MarkerImagesData().init();
      log("all marker images are loaded");
      final stores = await AppUtils.fetchJsonFromAsset(AppAssets.stores);

      final customers = await AppUtils.fetchJsonFromAsset(AppAssets.customers);

      _stores =
          (stores["stores"] as List).map((e) => Store.fromJson(e)).toList();
      _customers = (customers["customers"] as List)
          .map((e) => Customer.fromJson(e))
          .toList();
    } catch (e, s) {
      log("error - init : $e", name: "MapProvider");
      log("error - init : $s", name: "MapProvider");
    } finally {
      changeLoading(false);
    }
  }

  Future<void> moveToUserLocation() async {
    try {
      // Request location permission
      gl.LocationPermission permission = await gl.Geolocator.checkPermission();
      if (permission == gl.LocationPermission.denied ||
          permission == gl.LocationPermission.deniedForever) {
        permission = await gl.Geolocator.requestPermission();
        if (permission == gl.LocationPermission.denied ||
            permission == gl.LocationPermission.deniedForever) {
          throw Exception("Location permission not granted.");
        }
      }

      // Get current location
      final position = await gl.Geolocator.getCurrentPosition();

      // Move camera to location
      final cameraOptions = CameraOptions(
        center: Point(
          coordinates: Position(position.longitude, position.latitude),
        ),
        zoom: 14.0,
      );

      await _mapcontroller.flyTo(
        cameraOptions,
        MapAnimationOptions(duration: 1500),
      );
    } catch (e) {
      log("Error moving to user location: $e");
    }
  }
}
