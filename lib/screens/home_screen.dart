import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onPicked});

  final void Function(int pageNo) onPicked;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DateTime today = DateTime.now();

  List<TrainingPlan> allTrainings = [];
  List<Meeting> allMeetings = [];

  @override
  void initState() {
    super.initState();
    _fetchtTrainingPlans();
    _fetchAllMeetings();
  }

  int randomNumber(){
    final random = Random();
    return random.nextInt(29)+1;
  }

  Future<void> _fetchtTrainingPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final url = Uri.parse('${AppConfig.getTrainingPlansForToday}/${today.year}-${today.month}-${today.day}');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final trainingPlans = data.map((e) => TrainingPlan.fromJson(e)).toList();

      setState(() {
        allTrainings = trainingPlans;
      });
    } else {
      throw Exception(context.read<AppLanguage>().t('actionFailed'));
    }
  }

  Future<void> _fetchAllMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;
    
    final url = Uri.parse('${AppConfig.getUserAttendedEventsForToday}/${today.year}-${today.month}-${today.day}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      print(jsonDecode(response.body));
      final meetings = jsonList.map((e) => Meeting.fromJson(e)).toList();

      setState(() {
        allMeetings = meetings;
      });

      print("Meetings fetched: ${allMeetings.length}");
    } else {
      print("FAILED fetching meetings: ${response.body}");
    }
  }

  String cleanTime(int h, int m){
    final hour = '$h'.padLeft(2,'0');
    final min = '$m'.padLeft(2,'0');

    return '$hour:$min';
  }

  String cleanDuration(int d){
    final h = d ~/ 3600;
    final m = (d % 3600) ~/ 60;

    String msg = '';

    if (d > 0) msg += '$h h';
    if (m > 0){
      msg += ' ';
      msg += '$m'.padLeft(2,'0');
      msg += ' min';
    }

    return msg;
  }
  
  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();

    return Center(
      child: Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.white,       
                    AppColors.background,   
                  ],
                  stops: [0.2, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.75,
              margin: const EdgeInsets.only(top: 20),
              child: Center(
                child: Text(
                  lang.t('mot${randomNumber()}'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dancingScript(
                    color: AppColors.text,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: (){
              widget.onPicked(2);
            },
            child: Container(
              decoration: BoxDecoration(color: AppColors.accent),
              padding: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width * 0.75,
              margin: const EdgeInsets.only(top: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('upcomingMeetings'),
                      style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: allMeetings.map((t) => Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  cleanTime(t.dateTime.hour, t.dateTime.minute),
                                  style: const TextStyle(color: AppColors.text),
                                ),
                                Spacer(),
                                Text(
                                  t.name,
                                  style: const TextStyle(color: AppColors.text),
                                ),
                                
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    SizedBox(height: 8,), 
                    Text(
                      lang.t('upcomingTrainings'),
                      style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: allTrainings.map((t) => Container(
                            width: MediaQuery.of(context).size.width * 0.75,
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  cleanTime(t.dateTime.hour, t.dateTime.minute),
                                  style: const TextStyle(color: AppColors.text),
                                ),
                                Spacer(),
                                Text(
                                  cleanDuration(t.targetDuration),
                                  style: const TextStyle(color: AppColors.text),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Last training',
                style: TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(color: AppColors.accent),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.75,
            margin: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'Last meeting',
                style: TextStyle(color: AppColors.text, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}