class GeoLocation {
    String typename;
    double latitude;
    double longitude;

    GeoLocation({
        required this.typename,
        required this.latitude,
        required this.longitude,
    });

    factory GeoLocation.fromJson(Map<String, dynamic> json) => GeoLocation(
        typename: json["__typename"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "__typename": typename,
        "latitude": latitude,
        "longitude": longitude,
    };
}