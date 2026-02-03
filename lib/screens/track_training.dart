import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/measurements.dart';
import 'package:frontend_rolly/models/route.dart';
import 'package:frontend_rolly/models/route_photo.dart';
import 'package:frontend_rolly/models/route_point.dart';
import 'package:frontend_rolly/services/user_service.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/utils/num_utils.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TrackTraining extends StatefulWidget{
  final VoidCallback onBack;
  final String? dayIso;

  const TrackTraining({
    super.key,
    required this.onBack,
    required this.dayIso,
  });

  @override
  State<StatefulWidget> createState() => _TrackTrainingState();
}

class _TrackTrainingState extends State<TrackTraining> {
  TextEditingController _nameController = TextEditingController();

  late Future<Measurements>? measurements;

  String? _nameError;
  String? _activityError;

  StreamSubscription<Position>? positionStream;
  List<RoutePhoto> routePhotos = [];
  List<RoutePoint> routePoints = [];

  double totalDistance = 0.0;
  RoutePoint? lastPoint;

  Timer? _timer;
  int elapsedSeconds = 0;

  DateTime? startTime;
  DateTime? endTime;  

  String? selected;

  bool isTracking = false;

  late double weight;

  @override
  void initState() {
    super.initState();
    loadMeas();
  }

  void startTracking() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _nameError = context.read<AppLanguage>().t('wrongName');
      });
      return;
    }

    if (selected == null) {
      setState(() {
        _activityError = context.read<AppLanguage>().t('activityNotSelected');
      });
      return;
    }

    setState(() {
      _nameError = null;
      _activityError = null;
    });

    setState(() {
      isTracking = true;
    });

    startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        elapsedSeconds++;
      });
    });
    try {
      final startPosition = await Geolocator.getCurrentPosition();

      final startPoint = RoutePoint(
        id: 0,
        latitude: startPosition.latitude,
        longitude: startPosition.longitude,
        timestamp: DateTime.now(),
      );

      routePoints.add(startPoint);
      lastPoint = startPoint;


      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen((position) {
        final newPoint = RoutePoint(
          id: 0,
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: DateTime.now(),
        );

        if (lastPoint != null) {
        final distance = Geolocator.distanceBetween(
          lastPoint!.latitude,
          lastPoint!.longitude,
          newPoint.latitude,
          newPoint.longitude,
        );

        totalDistance += distance;
      }

      lastPoint = newPoint;
      routePoints.add(newPoint);
      });
    } catch (e) {
      setState(() {
        isTracking = false;
      });
      return;
    }
  }

  void stopTracking() async {
    await positionStream?.cancel();

    _timer?.cancel();
    _timer = null;

    endTime = DateTime.now();

    if (!isTracking) return;
    if (positionStream == null) return;

    final duration = Duration(seconds: elapsedSeconds);

    int calories = NumUtils().countCalories(
      selected,
      weight,
      duration,
      context.read<AppLanguage>()
    );

    final trainingRoute = TrainingRoute(
      name: _nameController.text,
      distance: totalDistance,
      estimatedTime: elapsedSeconds,
      date: DateTime.now(),
      points: routePoints,
      photos: routePhotos,
      caloriesBurned: calories,
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final url = Uri.parse(AppConfig.addRoute);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(trainingRoute.toJson()),
    );

    if (response.statusCode == 200){
      if (mounted) {
          final message = response.body;
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
          );

          widget.onBack();
          Navigator.pop(context);
        }
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }

  Future<void> takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    final position = await Geolocator.getCurrentPosition();

    routePhotos.add(
      RoutePhoto(
        id: 0,
        latitude: position.latitude,
        longitude: position.longitude,
        imageUrl: image.path,
        timestamp: DateTime.now(),
      ),
    );
  }

  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> loadMeas() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    setState(() {
      final token = storedToken;
      if (token != null) {
        measurements = UserService().getMeasurements(token);
        loadWeight();
      }
    });
  }
  Future<void> loadWeight() async {
    final m = await measurements;
    weight = m!.weight;
  }

  @override
  void dispose() {
    _timer?.cancel();
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    final List<String> _styles = [
      context.read<AppLanguage>().t('opt1'),
      context.read<AppLanguage>().t('opt2'),
      context.read<AppLanguage>().t('opt3'),
      context.read<AppLanguage>().t('opt4'),
    ];
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              widget.onBack();
              Navigator.pop(context);
            },
          ),
        title: Text(lang.t('trackTraining'), style: TextStyle(color: AppColors.text)),
      ),
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              if (!isTracking) ...[
              // Nazwa route
              Text(
                lang.t('routeName'),
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  errorText: _nameError,
                  hintText: lang.t('routeName'),
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
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: selected,
                decoration: InputDecoration(
                  labelText: lang.t('chooseActivity'),
                  filled: true,
                  fillColor: AppColors.accent,
                  errorText: _activityError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                items: _styles.map((style) {
                  return DropdownMenuItem(
                    value: style,
                    child: Text(style),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selected = value;
                    _activityError = null;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              GestureDetector(
                onTap: startTracking,
                child: Container(
                  decoration: BoxDecoration(color: AppColors.accent),
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.75,
                  height: MediaQuery.of(context).size.height * 0.2,
                  margin: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      lang.t('startTracking'),
                      style: const TextStyle(
                        color: AppColors.text,
                        fontFamily: 'Poppins-Bold',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              ] else ...[
                Text(
                  formatTime(elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap: takePhoto,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.accent),
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        lang.t('takeAPicture'),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontFamily: 'Poppins-Bold',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: stopTracking,
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.accent),
                    padding: const EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height * 0.2,
                    margin: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Text(
                        lang.t('stopTracking'),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontFamily: 'Poppins-Bold',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      )
    );
  }
}