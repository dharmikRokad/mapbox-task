import 'package:flutter/services.dart';
import 'package:myapp/utils/app_assets.dart';

class MarkerImagesData {
  MarkerImagesData._();

  static final MarkerImagesData _isntance = MarkerImagesData._();

  factory MarkerImagesData() => _isntance;

  late final Uint8List goldGreen;
  late final Uint8List goldYellow;
  late final Uint8List goldRed;
  late final Uint8List goldGrey;
  late final Uint8List silverGreen;
  late final Uint8List silverYellow;
  late final Uint8List silverRed;
  late final Uint8List silverGrey;
  late final Uint8List bronzeGreen;
  late final Uint8List bronzeYellow;
  late final Uint8List bronzeRed;
  late final Uint8List bronzeGrey;
  late final Uint8List customerMarker;
  late final Uint8List visitMarker;

  Future<void> init() async {
    final iconsToLoad = [
      AppAssets.goldGreen,
      AppAssets.goldYellow,
      AppAssets.goldRed,
      AppAssets.goldGray,
      AppAssets.silverGreen,
      AppAssets.silverYellow,
      AppAssets.silverRed,
      AppAssets.silverGray,
      AppAssets.bronzeGreen,
      AppAssets.bronzeYellow,
      AppAssets.bronzeRed,
      AppAssets.bronzeGray,
      AppAssets.blueMarker,
      AppAssets.visitPurple,
    ];

    final List<Uint8List> futures =
        await Future.wait(iconsToLoad.map((e) async {
      final ByteData bytes = await rootBundle.load(e);
      return bytes.buffer.asUint8List();
    }).toList());

    goldGreen = futures[0];
    goldYellow = futures[1];
    goldRed = futures[2];
    goldGrey = futures[3];
    silverGreen = futures[4];
    silverYellow = futures[5];
    silverRed = futures[6];
    silverGrey = futures[7];
    bronzeGreen = futures[8];
    bronzeYellow = futures[9];
    bronzeRed = futures[10];
    bronzeGrey = futures[11];
    customerMarker = futures[12];
    visitMarker = futures[13];
  }
}
