
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/location.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/widgets/select_location_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocation extends StatefulWidget{
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;

  const AddLocation({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  State<StatefulWidget> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  LatLng? latLng;

  TextEditingController _nameController = new TextEditingController();

  String? _nameError;

  bool _isLoading = false;

  String? _toString(dynamic v) => v?.toString();

  Future<(String? city, String? country)> getCityFromOSM(double? lat, double? lng) async {
    const apiKey = "0e5ea13e1f424699a36f86acd01c85bd";
    final url =
        "https://api.geoapify.com/v1/geocode/reverse?lat=$lat&lon=$lng&apiKey=$apiKey";

    final response = await http.get(Uri.parse(url), headers: {
      "Content-Type": "application/json",
      "User-Agent": "flutter-app"
    });

    final data = jsonDecode(response.body);
    final props = data["features"]?[0]?["properties"];

    print(jsonEncode(data));

    final city = _toString(
        props?["city"] ?? props?["town"] ?? props?["village"] ?? props?["municipality"]
    );

    final country = _toString(props?["country"]);

    return (city, country);

    // final city = await getCityFromOSM(point.latitude, point.longitude);
  }

  Future<void> _addLocation() async {
    if (latLng == null) {
      setState(() {
        _nameError = context.read<AppLanguage>().t('locationShouldNotBeEmpty') ;
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = '${AppConfig.addLocation}'; 

    final (city, country) = await getCityFromOSM(
      latLng!.latitude,
      latLng!.longitude,
    );

    final location = Location(
      id: 0,
      name: _nameController.text,
      city: city ?? "Unknown",
      country: country ?? "Unknown",
      latitude: latLng!.latitude,
      longitude: latLng!.longitude,
    );

    final response = await http.post( 
        Uri.parse(url), 
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        }, 
        body: jsonEncode(location.toJson()),
      );

      if (response.statusCode == 200) {
        final message = response.body;
        widget.onRefresh?.call();

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
        );


          setState(() => _isLoading = false);

        if (mounted) {
          _nameController.clear();
          Navigator.pop(context, true);
        }
      } else {
        // Obsługa błędów
        final message = response.body;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
        );
      }

  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

  
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) widget.onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              widget.onBack();
              Navigator.pop(context);
            },
          ),
          title: Text(lang.t('addLocation'), style: TextStyle(color: AppColors.text)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column( 
                children: [
                  SizedBox(height: 24,),
                  SizedBox(
                    height: 300,
                    child: SelectLocationMap(
                      onLocationSelected: (LatLng point) {
                        print("Wybrano: ${point.latitude}, ${point.longitude}");
                        setState(() {
                          latLng = point;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Nazwa
                  Text(
                        lang.t('locationName'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _nameError,
                      errorMaxLines: 3,
                      hintText: lang.t('name'),
                      hintStyle: TextStyle(
                        color: AppColors.text,
                      ),
                      filled: true,
                      fillColor: AppColors.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Przycisk dodawania
                  const SizedBox(height: 20),
                  SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _addLocation,
                                child: Text(
                                  lang.t('addLocation'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                ]
              )
            )
          )
        )
      )
      )
    );
  }
}