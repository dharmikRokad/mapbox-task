import 'dart:typed_data';

import 'package:myapp/models/enums/store_level.dart';
import 'package:myapp/models/geo_location.dart';
import 'package:myapp/utils/marker_image_data.dart';

class Store {
  String id;
  String typename;
  double? caseVolumeLtm;
  double? caseVolume2024;
  double? cirocCases;
  double? percentile;
  GeoLocation geoLocation;

  StoreLevel get level {
    return switch (percentile) {
      double a when a < 10 => StoreLevel.gold,
      double a when (a > 10 && a < 50) => StoreLevel.silver,
      double a when a > 50 => StoreLevel.bronze,
      _ => StoreLevel.bronze,
    };
  }

  double get caseVoulmePercent => caseVolumeLtm == null || cirocCases == null
      ? -1
      : (caseVolumeLtm! / cirocCases!) * 100;

  Uint8List get markerPath {
    if (level == StoreLevel.gold) {
      return switch (caseVoulmePercent) {
        double a when a > 30 => MarkerImagesData().goldGreen,
        double a when (a > 15 && a <= 30) => MarkerImagesData().goldYellow,
        double a when (a >= 0 && a >= 15) => MarkerImagesData().goldRed,
        -1 => MarkerImagesData().goldGrey,
        _ => MarkerImagesData().goldGrey
      };
    } else if (level == StoreLevel.silver) {
      return switch (caseVoulmePercent) {
        double a when a > 30 => MarkerImagesData().silverGreen,
        double a when (a > 15 && a <= 30) => MarkerImagesData().silverYellow,
        double a when (a >= 0 && a >= 15) => MarkerImagesData().silverRed,
        -1 => MarkerImagesData().silverGrey,
        _ => MarkerImagesData().silverGrey
      };
    } else {
      return switch (caseVoulmePercent) {
        double a when a > 30 => MarkerImagesData().bronzeGreen,
        double a when (a > 15 && a <= 30) => MarkerImagesData().bronzeYellow,
        double a when (a >= 0 && a >= 15) => MarkerImagesData().bronzeRed,
        -1 => MarkerImagesData().bronzeGrey,
        _ => MarkerImagesData().bronzeGrey
      };
    }
  }

  Store({
    required this.id,
    required this.typename,
    required this.caseVolumeLtm,
    required this.caseVolume2024,
    required this.cirocCases,
    required this.percentile,
    required this.geoLocation,
  });

  factory Store.fromJson(Map<String, dynamic> json) => Store(
        id: json["id"],
        typename: json["__typename"],
        caseVolumeLtm: (json["caseVolumeLTM"] as num?)?.toDouble(),
        caseVolume2024: (json["caseVolume2024"] as num?)?.toDouble(),
        cirocCases: (json["cirocCases"] as num?)?.toDouble(),
        percentile: (json["percentile"] as num?)?.toDouble(),
        geoLocation: GeoLocation.fromJson(json["geoLocation"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "__typename": typename,
        "caseVolumeLTM": caseVolumeLtm,
        "caseVolume2024": caseVolume2024,
        "cirocCases": cirocCases,
        "percentile": percentile,
        "geoLocation": geoLocation.toJson(),
      };
}
