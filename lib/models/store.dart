import 'package:myapp/models/geo_location.dart';

class Store {
    String id;
    String typename;
    dynamic caseVolumeLtm;
    dynamic caseVolume2024;
    dynamic cirocCases;
    dynamic percentile;
    GeoLocation geoLocation;

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
        caseVolumeLtm: json["caseVolumeLTM"],
        caseVolume2024: json["caseVolume2024"],
        cirocCases: json["cirocCases"],
        percentile: json["percentile"],
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