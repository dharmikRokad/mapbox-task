import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:myapp/map_provider.dart';
import 'package:myapp/models/enums/store_level.dart';
import 'package:myapp/utils/app_keys.dart';
import 'package:myapp/utils/app_text_styles.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Box Task"),
        actions: [
          /* IconButton(
            onPressed: context.read<MapProvider>().moveToUserLocation,
            icon: Icon(Icons.location_history),
          ), */
          IconButton(
            onPressed: _showFiltersheet,
            icon: Icon(Icons.filter_alt),
          ),
          IconButton(
            onPressed: _showInfoDilaog,
            icon: Icon(CupertinoIcons.info),
          ),
          Consumer<MapProvider>(builder: (context, provider, _) {
            return PopupMenuButton(
              onSelected: provider.changeMapStyle,
              itemBuilder: (context) {
                return mapStyles.entries
                    .map(
                      (e) => PopupMenuItem(
                        value: e.value,
                        child: ListTile(
                          leading: SizedBox(
                            width: 40,
                            child: provider.selectedStyle == e.value
                                ? Icon(Icons.check)
                                : null,
                          ),
                          title: Text(e.key),
                        ),
                      ),
                    )
                    .toList();
              },
              child: SizedBox(width: 45, child: Icon(Icons.light_mode)),
            );
          }),
        ],
      ),
      body: Consumer<MapProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return CircularProgressIndicator();
          }

          return MapWidget(
            onMapCreated: provider.onMapCreated,
          );
        },
      ),
    );
  }

  _showInfoDilaog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _buildTitleWidget("Store Categories", addClear: true),
                  const Divider(),
                  _buildPerformenceView(),
                  const SizedBox(height: 40),
                  _buildSalesPerformence(),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  _showFiltersheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return Consumer<MapProvider>(builder: (context, provider, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleWidget("Store Categories"),
              Divider(),
              ...StoreLevel.values.map((e) {
                return CheckboxListTile(
                  value: provider.filters[e.name] == true,
                  onChanged: (val) =>
                      provider.changeFilter(e.name, val ?? false),
                  title: Text(e.title, style: AppTextStyles.textStyle16),
                );
              }),
              Divider(),
              _buildTitleWidget("Analytics"),
              Divider(),
              CheckboxListTile(
                value: provider.filters[AppKeys.visits] == true,
                onChanged: (val) =>
                    provider.changeFilter(AppKeys.visits, val ?? false),
                title: Text("Store Visits", style: AppTextStyles.textStyle16),
              ),
              CheckboxListTile(
                value: provider.filters[AppKeys.customers] == true,
                onChanged: (val) =>
                    provider.changeFilter(AppKeys.customers, val ?? false),
                title: Text("Customers", style: AppTextStyles.textStyle16),
              ),
            ],
          );
        });
      },
    );
  }

  _buildTitleWidget(String title, {bool addClear = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.textStyle20Bold,
          ),
          if (addClear)
            IconButton(
              onPressed: Navigator.of(context).pop,
              icon: Icon(Icons.clear),
            ),
        ],
      ),
    );
  }

  _buildPerformenceView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            StoreLevel.values.map<Widget>(_buildPerformersWidget).toList(),
      ),
    );
  }

  _buildSalesPerformence() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales Performers",
            style: AppTextStyles.textStyle16Bold.copyWith(
              color: Colors.blueGrey,
            ),
          ),
          _buildSalesPerformanceTile(Colors.green, "High sales (>30%)"),
          _buildSalesPerformanceTile(Colors.yellow, "Medium sales (15-30%)"),
          _buildSalesPerformanceTile(Colors.red, "Low sales (<15%)"),
          _buildSalesPerformanceTile(Colors.grey, "No sales data"),
        ],
      ),
    );
  }

  Widget _buildPerformersWidget(StoreLevel level) {
    return Column(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          level.title,
          style: AppTextStyles.textStyle16Bold.copyWith(
            color: Colors.blueGrey,
          ),
        ),
        Row(
          spacing: 15,
          children: [
            Image.asset(level.iconPath, height: 26, width: 26),
            Text(level.subText, style: AppTextStyles.textStyle16)
          ],
        ),
      ],
    );
  }

  _buildSalesPerformanceTile(Color color, String text) {
    return Row(
      spacing: 15,
      children: [
        CircleAvatar(radius: 13, backgroundColor: color),
        Text(text, style: AppTextStyles.textStyle16),
      ],
    );
  }
}
