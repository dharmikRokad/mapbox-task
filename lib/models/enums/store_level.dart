import 'package:myapp/utils/app_assets.dart';

enum StoreLevel {
  gold(
      iconPath: AppAssets.goldIcon,
      title: "High Performers (Gold)",
      subText: "Top 10% of biggest stores"),
  silver(
      iconPath: AppAssets.silverIcon,
      title: "Medium Performers (Silver)",
      subText: "10-50% of biggest stores"),
  bronze(
      iconPath: AppAssets.bronzeIcon,
      title: "Standard Performers (Bronze)",
      subText: "50-100% of biggest stores");

  final String title;
  final String subText;
  final String iconPath;

  const StoreLevel({
    required this.title,
    required this.subText,
    required this.iconPath,
  });
}
