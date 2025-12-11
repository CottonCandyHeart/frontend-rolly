import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:frontend_rolly/config.dart'; 
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/city.dart';
import 'package:frontend_rolly/models/meeting.dart'; 
import 'package:frontend_rolly/theme/colors.dart'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart'; 

class FindMeetingsWidget extends StatefulWidget { 
  const FindMeetingsWidget(
    { super.key, required this.selectedScreen, required this.onBack, required this.onMeetingSelected }
  ); 

  final String selectedScreen; 
  final VoidCallback onBack; 
  final Function(Meeting meeting) onMeetingSelected;

   @override
  State<FindMeetingsWidget> createState() => _FindMeetingsWidgetState();
}

class _FindMeetingsWidgetState  extends State<FindMeetingsWidget> {
  late Future<List<Meeting>> _meetingFuture = Future.value([]);
  late List<String> _cities = [];
  late List<Meeting> _meetings;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  void _loadCities() async {
    Future<List<City>> _citiesFuture = _getCities(); 
    final citiesList = await _citiesFuture;
    _cities = citiesList.map((c) => c.city).toList();
    setState(() {}); 
  }

  void _loadMeetings() async {
    _meetingFuture = fetchMeetings();
    final meetingsList = await _meetingFuture;
    _meetings = meetingsList.map((m) => m).toList();
  }

  Future<List<City>> _getCities() async {
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = "${AppConfig.getEventByCity}";
    final response = await http.get( Uri.parse(url), headers: {'Authorization': 'Bearer $token'}, ); 
    final List data = jsonDecode(response.body); return data.map((e) => City.fromJson(e)).toList();
  }
  
  Future<List<Meeting>> fetchMeetings() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = "${AppConfig.getEventByCity}/$_selectedCity/up"; 
    
    final response = await http.get( Uri.parse(url), headers: {'Authorization': 'Bearer $token', 
        'Content-Type': 'application/json',}, ); 

    if (response.statusCode != 200) {
      print("Server error: ${response.body}");
      throw Exception("Server returned ${response.statusCode}");
    }
    
    final List data = jsonDecode(response.body); return data.map((e) => Meeting.fromJson(e)).toList(); 
  } 
  
  @override Widget build(BuildContext context) { 
    final lang = context.read<AppLanguage>(); 

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: FutureBuilder<List<Meeting>>( 
            future: _meetingFuture, 
            builder: (context, snapshot) { 
              if (snapshot.connectionState == ConnectionState.waiting) { 
                return const Center(child: CircularProgressIndicator()); 
              } 
              if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) { 
                return Center( 
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(10),
                    child: Column( 
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [ 
                        Row(
                          children: [
                            Align( 
                              alignment: Alignment.centerLeft, 
                              child: Padding( 
                                padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0), 
                                child: IconButton( 
                                  onPressed: widget.onBack, 
                                  icon: const Icon(Icons.arrow_back), 
                                  color: AppColors.text, iconSize: 30, 
                                ), 
                              ), 
                            ),  
                          ],
                        ),
                        const SizedBox(height: 20), 
                        DropdownButtonFormField<String>(
                          value: _selectedCity,
                          decoration: InputDecoration(
                            labelText: lang.t('chooseCity'),
                            filled: true,
                            fillColor: AppColors.accent,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          items: _cities.map((style) {
                            return DropdownMenuItem(
                              value: style,
                              child: Text(style),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCity = value;
                              _loadMeetings();
                            });
                          },
                        ),
                        SizedBox(height: 32,),
                        Text( lang.t('chooseCity'), 
                          style: const TextStyle( 
                            fontSize: 18, 
                            color: AppColors.text, 
                            fontFamily: 'Poppins-Bold', 
                          ),
                        ), 
                        const SizedBox(height: 20), 
                      ], 
                    ), 
                  )
                  
                ); 
              } 
              
              return Padding(
                padding: EdgeInsetsGeometry.all(10),
                child: Column( 
                  children: [ 
                    Row(
                      children: [
                        Align( 
                          alignment: Alignment.centerLeft, 
                          child: Padding( 
                            padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0), 
                            child: IconButton( 
                              onPressed: widget.onBack, 
                              icon: const Icon(Icons.arrow_back), 
                              color: AppColors.text, iconSize: 30, 
                            ), 
                          ), 
                        ),  
                      ],
                    ),
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      labelText: lang.t('chooseCity'),
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _cities.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _loadMeetings();
                      });
                    },
                  ),

                  SizedBox(height: 24,),
                    
                    ..._meetings.map((meeting) { 
                      return GestureDetector( 
                        onTap: () => widget.onMeetingSelected(meeting), 
                        child: Container( 
                          decoration: BoxDecoration(
                            color: AppColors.accent), 
                            padding: const EdgeInsets.all(20), 
                            width: MediaQuery.of(context).size.width * 0.75, 
                            margin: const EdgeInsets.only(top: 20), 
                            child: Center( 
                              child: Row( 
                                children: [ 
                                  Text( 
                                    meeting.name, 
                                    style: const TextStyle( 
                                      color: AppColors.text, 
                                      fontFamily: 'Poppins-Bold', 
                                      fontSize: 20, 
                                    ), 
                                  ), 
                                ] 
                              ), 
                            ), 
                          ), 
                        ); 
                      }
                    ), 
                  ], 
                )
              );
            }, 
          )
        ),
      )
    );
  }
}