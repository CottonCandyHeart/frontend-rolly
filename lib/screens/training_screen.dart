import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/route.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/widgets/calendar_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _TrainingState();
}

class _TrainingState extends State<TrainingScreen> {
  DateTime chosen = DateTime.now();

  void goPrevMonth() {
    setState(() {
      chosen = DateTime(chosen.year, chosen.month - 1, 1);
    });
  }

  void goNextMonth() {
    setState(() {
      chosen = DateTime(chosen.year, chosen.month + 1, 1);
    });
  }

  Future<List<TrainingPlan>> getTrainingPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final url = Uri.parse(AppConfig.trainingPlans);

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TrainingPlan.fromJson(e)).toList();
    } else {
      throw Exception(context.read<AppLanguage>().t('actionFailed'));
    }
  }

  Future<List<TrainingPlan>> _getListOfTrainings(DateTime date) async {
    final url = Uri.parse('${AppConfig.trainingPlans}/${date.year}-${date.month}'); 
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TrainingPlan.fromJson(e)).toList();
    } else {
      print(context.read<AppLanguage>().t('noTrainingsAvailable'));
      return [];
    }
  }

  Future<List<TrainingRoute>> _getListOfRoutes(DateTime date) async {
    final url = Uri.parse('${AppConfig.getRouteByMonth}/${date.year}-${date.month}'); 
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TrainingRoute.fromJson(e)).toList();
    } else {
      print(context.read<AppLanguage>().t('noRoutesAvailable'));
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: CustomCalendar(
            trainings: () =>  _getListOfTrainings(chosen),
            routes: () =>  _getListOfRoutes(chosen),
            chosen: chosen,
            onPrev: goPrevMonth,
            onNext: goNextMonth,
            onRefresh: () async {
              setState(() {});
            },
          ),
        ),
        Spacer(),
        SizedBox()
      ],
    );
  }
}