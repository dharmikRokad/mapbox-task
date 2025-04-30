import 'package:myapp/models/geo_location.dart';

class Customer {
    String typename;
    String name;
    String email;
    String phone;
    GeoLocation geoLocation;
    String customerId;
    String address;

    Customer({
        required this.typename,
        required this.name,
        required this.email,
        required this.phone,
        required this.geoLocation,
        required this.customerId,
        required this.address,
    });

    factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        typename: json["__typename"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        geoLocation: GeoLocation.fromJson(json["geoLocation"]),
        customerId: json["customerId"],
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "__typename": typename,
        "name": name,
        "email": email,
        "phone": phone,
        "geoLocation": geoLocation.toJson(),
        "customerId": customerId,
        "address": address,
    };
}
