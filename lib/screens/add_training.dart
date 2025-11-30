
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/measurements.dart';
import 'package:frontend_rolly/services/user_service.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/utils/num_utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend_rolly/models/route.dart';

class AddTraining extends StatefulWidget{
  final VoidCallback onBack;
  final String? dayIso;

  const AddTraining({
    super.key,
    required this.onBack,
    required this.dayIso
  });

  @override
  State<StatefulWidget> createState() => _AddTrainingState();
}

class _AddTrainingState extends State<AddTraining> {
  String? token;
  late Future<Measurements>? measurements;
  double? weight;
  Measurements? m;

  TextEditingController _timeController = new TextEditingController();
  TextEditingController _distanceController = new TextEditingController();

  String? _distanceError;
  String? _activityError;

  String? _selectedStyle;

  int hours = 0;
  int minutes = 0;

  int h = 0;
  int min = 0;

  Duration get duration => Duration(hours: hours, minutes: minutes);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('jwt_token');

    setState(() {
      token = storedToken;
    });

    if (token != null) {
      measurements = UserService().getMeasurements(token!);
      final result = await measurements;
      setState(() {
        m = result;      
        weight = m!.weight;     
      });
    }
  }

  Future<void> _addRoute() async {

    setState(() => _isLoading = true);

    final distanceText = _distanceController.text.trim();
    final distanceValue = double.tryParse(distanceText);

    if (distanceText.isEmpty || distanceValue == null || distanceValue <= 0) {
      setState(() {
        _distanceError = context.read<AppLanguage>().t('distanceNotANumber');
      });
      setState(() => _isLoading = false);
      return;
    }

    if (_selectedStyle == null) {
      setState(() {
        _activityError = context.read<AppLanguage>().t('activityNotSelected');
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _distanceError = null;
      _activityError = null;
    });

    // Pobierz token z pamięci
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final timeText = _timeController.text.trim();
    final timeParts = timeText.split(':');

    if (timeParts.length == 2) {
      h = int.tryParse(timeParts[0]) ?? 0;
      min = int.tryParse(timeParts[1]) ?? 0;
    } else {
      h = int.tryParse(timeText) ?? 0;
      min = 0;
    }

    final dateTime = DateTime.parse(widget.dayIso!).add(Duration(hours: h, minutes: min));

    final calories = NumUtils().countCalories(_selectedStyle, weight, duration, context.read<AppLanguage>());

    final route = TrainingRoute(
      name: "TR/${widget.dayIso}/${_timeController.text}",
      distance: double.tryParse(_distanceController.text) ?? 0.0,
      estimatedTime: duration.inSeconds, 
      date: dateTime,
      points: [],  
      photos: [],   
      caloriesBurned: calories,
    );

    print(route.name);
    print(route.distance);
    print(route.estimatedTime);
    print(route.points);
    print(route.photos);
    print(route.caloriesBurned);

    print(jsonEncode(route.toJson()));

    final url = Uri.parse(AppConfig.addRoute); 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(route.toJson()),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
          _timeController.clear();
          _distanceController.clear();
          Navigator.pop(context);
      }
    } else {
      // Obsługa błędów
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
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
          title: Text(lang.t('addTraining'), style: TextStyle(color: AppColors.text)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          child: Column( 
          children: [
          const SizedBox(height: 24),

          // Czas treningu
          Text(
                lang.t('trainingTime'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: lang.t('hours')),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => h = int.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: lang.t('minutes')),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => min = int.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Estymowany czas
          Text(
                lang.t('duration'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: lang.t('hours')),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => hours = int.tryParse(v) ?? 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(labelText: lang.t('minutes')),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => minutes = int.tryParse(v) ?? 0,
                ),
              ),
            ],
          ),

          // Dystans
          const SizedBox(height: 36),
              Text(
                lang.t('distance'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 48,
                    maxHeight: 48,
                  ),
                  child: TextField(
                    onChanged: (_) {
                      setState(() {
                        _distanceError = null;
                      });
                    },
                    controller: _distanceController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: lang.t('distance'),
                      hintStyle: TextStyle(
                        color: AppColors.text,
                      ),
                      errorText: _distanceError,
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 36),

          // Typ aktywności
          Text(
                lang.t('activityType'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedStyle,
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
                _selectedStyle = value;
                _activityError = null;
              });
            },
          ),

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
                        onPressed: _addRoute,
                        child: Text(
                          lang.t('addTraining'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.background,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
          ],
        )
        )
        )
        )
        )
      )
    );
  }
}