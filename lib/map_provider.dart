import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:myapp/models/customer.dart';
import 'package:myapp/models/store.dart';
import 'package:myapp/utils/app_assets.dart';
import 'package:myapp/utils/app_utils.dart';

class MapProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Store> _stores = [];
  List<Customer> _customers = [];
  MapboxMap? _mapcontroller;

  bool get isLoading => _isLoading;
  List<Store> get stores => _stores;
  List<Customer> get customers => _customers;
  MapboxMap? get mapController => _mapcontroller;

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

  List<Store> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => Store.fromJson(e)).toList();
  }

  Future<void> init() async {
    try {
      changeLoading(true);
      final stores = await AppUtils.fetchJsonFromAsset(AppAssets.stores);

      final customers = await AppUtils.fetchJsonFromAsset(AppAssets.customers);

      _stores =
          (stores["stores"] as List).map((e) => Store.fromJson(e)).toList();
      _stores =
          (customers["customers"] as List)
              .map((e) => Store.fromJson(e))
              .toList();
    } catch (e, s) {
      log("error - init : $e", name: "MapProvider");
      log("error - init : $s", name: "MapProvider");
    } finally {
      changeLoading(false);
    }
  }
}
