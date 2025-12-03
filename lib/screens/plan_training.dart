import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlanTraining extends StatefulWidget{
  final VoidCallback onBack;
  final String? dayIso;

  const PlanTraining({
    super.key,
    required this.onBack,
    required this.dayIso,
  });

  @override
  State<StatefulWidget> createState() => _PlanTrainingState();
}

class _PlanTrainingState extends State<PlanTraining> {
  TextEditingController _notesController = new TextEditingController();

  int hours = 0;
  int minutes = 0;

  int h = 0;
  int min = 0;

  Duration get duration => Duration(hours: hours, minutes: minutes);

  bool _isLoading = false;

  String fixIso(String iso) {
    final parts = iso.split('-');
    final y = parts[0];
    final m = parts[1].padLeft(2, '0');
    final d = parts[2].padLeft(2, '0');
    return "$y-$m-$d";
  }

  Future<void> _addTrainingPlan() async {

    setState(() => _isLoading = true);

    // Pobierz token z pamięci
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => _isLoading = false);
      return;
    }

    final dateTime = DateTime.parse(fixIso(widget.dayIso!)).add(Duration(hours: h, minutes: min));

    final training = TrainingPlan(
      id: 0,
      dateTime: dateTime,
      targetDuration: duration.inSeconds,
      notes: _notesController.text,
      completed: false
    );

    print(jsonEncode(training.toJson()));

    final url = Uri.parse(AppConfig.addTrainingPlan); 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(training.toJson()),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
          _notesController.clear();
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
          title: Text(lang.t('planTraining'), style: TextStyle(color: AppColors.text)),
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
                const SizedBox(height: 36),

                // Notatki
                Text(
                      lang.t('notes'),
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
                  controller: _notesController,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
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
                              onPressed: _addTrainingPlan,
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