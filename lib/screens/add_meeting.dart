
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart';
import 'package:frontend_rolly/screens/add_location.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMeeting extends StatefulWidget{
  final VoidCallback onBack;
  final Future<void> Function()? onRefresh;

  const AddMeeting({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  State<StatefulWidget> createState() => _AddMeetingState();
}

class _AddMeetingState extends State<AddMeeting> {
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _descriptionController = new TextEditingController();

  List<String> _locations = [];

  String? _dateError;
  String? _nameError;
  String? _levelError;
  String? _typeError;
  String? _locationError;

  String? _selectedLevel;
  String? _selectedType;
  String? _selectedLocationName;

  String? _dateIso;

  int h = 0;
  int min = 0;

  double _minValue = 16;
  double _maxValue = 99;
  RangeValues _ageRange = const RangeValues(16, 60);

  RangeValues _participantsRange = const RangeValues(2, 5);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _addMeeting() async {
    final prefs = await SharedPreferences.getInstance(); 
      final token = prefs.getString('jwt_token')!; 
      final url = '${AppConfig.eventEndpoint}/'; 

      final dateTime = DateTime.parse(_dateIso!).add(Duration(hours: h, minutes: min));

      final meeting = Meeting(
        name: _nameController.text.trim(), 
        description: _descriptionController.text.trim(), 
        organizerUsername: "Unknown", 
        dateTime: dateTime, 
        level: _selectedLevel!, 
        type: _selectedType!, 
        age: '${_ageRange.start.round()} - ${_ageRange.end.round()}', 
        numberOfParticipants: _participantsRange.end.round().toInt(),
        locationName: _selectedLocationName!, 
        action: 'create'
      );

      print(meeting.toJson());
      
      final response = await http.post( 
        Uri.parse(url), 
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        }, 
        body: jsonEncode(meeting.toJson()),
      );
      
      setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;
      widget.onRefresh?.call();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
        _dateController.clear();
        _nameController.clear();
        _descriptionController.clear();
        Navigator.pop(context, true);
      }
    } else {
      // Obsługa błędów
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }

  Future<void> _addLocation() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddLocation(onBack: (){}, onRefresh: () async {setState(() {_fetchLocations();});},)),
    );
  }

  Future<void> _fetchLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;
    
    final response = await http.get(
      Uri.parse(AppConfig.getLocations),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        _locations = data.map<String>((loc) => loc['name'] as String).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AppLanguage>(context);

    final List<String> _levels = [
      context.read<AppLanguage>().t('levelOpt1'),
      context.read<AppLanguage>().t('levelOpt2'),
      context.read<AppLanguage>().t('levelOpt3'),
      context.read<AppLanguage>().t('levelOpt4'),
    ];

    final List<String> _types = [
      context.read<AppLanguage>().t('typeOpt1'),
      context.read<AppLanguage>().t('typeOpt2'),
      context.read<AppLanguage>().t('typeOpt3'),
      context.read<AppLanguage>().t('typeOpt4'),
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
          title: Text(lang.t('addMeeting'), style: TextStyle(color: AppColors.text)),
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

                  // Nazwa
                  Text(
                        lang.t('eventName'),
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

                  // Opis
                  Text(
                    lang.t('description'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: null, 
                    minLines: 5,
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Training date
                  Text(
                    lang.t('trainingDate'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        controller: _dateController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          errorText: _dateError,
                          errorMaxLines: 3,
                          hintText: lang.t('trainingDate'),
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
                        onTap: () async {
                          final DateTime now = DateTime.now();

                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: now,
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: AppColors.background,
                                    onSurface: AppColors.text,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                              setState(() {
                                _dateController.text = 
                                  "${picked.day.toString().padLeft(2,'0')}.${picked.month.toString().padLeft(2,'0')}.${picked.year}";
                                _dateIso =
                                  "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
                              });
                          }
                        },
                      ),
                      Positioned(
                        right: 18,
                        child: GestureDetector(
                          onTap: () async {},
                          child: const Icon(
                            Icons.calendar_today,
                            color: AppColors.text,
                            size: 20,
                          ),
                        ),
                      ),
                    ]
                  ),

                  // Czas treningu
                  const SizedBox(height: 36),
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
                          onChanged: (v) {
                            setState(() {
                              h = int.tryParse(v) ?? 0;
                            });
                          }
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: lang.t('minutes')),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            setState(() {
                              min = int.tryParse(v) ?? 0;
                            });
                          }
                        ),
                      ),
                    ],
                  ),

                  // Level
                  const SizedBox(height: 36),
                  Text(
                        lang.t('level'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: InputDecoration(
                      labelText: lang.t('chooseLevel'),
                      filled: true,
                      fillColor: AppColors.accent,
                      errorText: _levelError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _levels.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                        _levelError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Type
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
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: lang.t('chooseActivity'),
                      filled: true,
                      fillColor: AppColors.accent,
                      errorText: _typeError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _types.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                        _typeError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Nazwa lokacji
                  Text(
                    lang.t('location'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLocationName,
                    decoration: InputDecoration(
                      labelText: lang.t('locationName'),
                      filled: true,
                      fillColor: AppColors.accent,
                      errorText: _locationError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _locations.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocationName = value;
                        _locationError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('or'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Przycisk dodawania
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
                              lang.t('addNewLocation'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.background,
                              ),
                            ),
                          ),
                    ),
                  const SizedBox(height: 36),

                  // Przedział wiekowy
                  Text(
                    lang.t('ageRange'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        _ageRange.start.round().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 12, 
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        ),
                        child: RangeSlider(
                          min: _minValue,
                          max: _maxValue,
                          values: _ageRange,
                          activeColor: AppColors.current,
                          divisions: _maxValue.toInt(),
                          labels: RangeLabels(
                            _ageRange.start.round().toString(),
                            _ageRange.end.round().toString(),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _ageRange = values;
                            });
                          },
                        ),
                      ),
                      
                      Text(
                        _ageRange.end.round().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Spacer(),
                    ]
                  ),
                  
                  const SizedBox(height: 36),

                  // Ilość uczestników
                  Text(
                    lang.t('numberOfParticipants'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        _participantsRange.start.round().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 12, 
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                        ),
                        child: RangeSlider(
                          min: 2,
                          max: 30,
                          values: _participantsRange,
                          activeColor: AppColors.current,
                          divisions: 30,
                          labels: RangeLabels(
                            _participantsRange.start.round().toString(),
                            _participantsRange.end.round().toString(),
                          ),
                          onChanged: (values) {
                            setState(() {
                              _participantsRange = RangeValues(2, values.end);
                            });
                          },
                        ),
                      ),
                      
                      Text(
                        _participantsRange.end.round().toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      Spacer(),
                    ]
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
                                onPressed: _addMeeting,
                                child: Text(
                                  lang.t('addMeeting'),
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