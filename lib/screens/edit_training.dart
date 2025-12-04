import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditTraining extends StatefulWidget {
  final VoidCallback onBack;
  final String? dayIso;
  final TrainingPlan training;

  const EditTraining ({required this.onBack, required this.dayIso, required this.training});

  @override
  State<StatefulWidget> createState() => _EditTrainingState();
}

class _EditTrainingState extends State<EditTraining> {
  late TextEditingController _notesController;

  late TextEditingController _hourController;
  late TextEditingController _minuteController;

  late TextEditingController _hController;
  late TextEditingController _minController;

  int hours = 0;
  int minutes = 0;

  int h = 0;
  int min = 0;

  Duration get duration => Duration(hours: hours, minutes: minutes);

  bool _isLoading = false;

  void initState() {
    super.initState();
    hours = widget.training.targetDuration ~/ 3600;
    minutes = (widget.training.targetDuration % 3600) ~/ 60;

    h = widget.training.dateTime.hour;
    min = widget.training.dateTime.minute; 

    _hourController = TextEditingController(text: hours.toString());
    _minuteController = TextEditingController(text: minutes.toString());

    _hController = TextEditingController(text: h.toString());
    _minController = TextEditingController(text: min.toString());
    
    _notesController = TextEditingController(); 
    _notesController.text = widget.training.notes;
  }

  @override
  void dispose() {
      _hourController.dispose();
      _minuteController.dispose();
      _hController.dispose();
      _minController.dispose();
      _notesController.dispose();
      super.dispose();
  }

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

    final dateOnly = DateTime.parse(fixIso(widget.dayIso!));

    final newDateTime = DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      h, 
      min,
    );

    final training = TrainingPlan(
      id: widget.training.id,
      dateTime: newDateTime, 
      targetDuration: duration.inSeconds,
      notes: _notesController.text,
      completed: widget.training.completed,
    );

    print(jsonEncode(training.toJson()));

    final url = Uri.parse(AppConfig.updateTrainingPlan); 
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
          title: Text(lang.t('editTraining'), style: TextStyle(color: AppColors.text)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  children: [
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
                            controller: _hController,
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
                            controller: _minController,
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
                            controller: _hourController,
                            decoration: InputDecoration(labelText: lang.t('hours')),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => hours = int.tryParse(v) ?? 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _minuteController,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}