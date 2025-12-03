
import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/screens/add_training.dart';
import 'package:frontend_rolly/screens/edit_training.dart';
import 'package:frontend_rolly/screens/track_training.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ShowTrainingPlan extends StatefulWidget {
  final VoidCallback onBack;
  final TrainingPlan training;
  final String? dayIso;
  final bool isToday;

  const ShowTrainingPlan({super.key, required this.onBack, required this.training, required this.dayIso, required this.isToday});
  
  @override
  State<ShowTrainingPlan> createState() => _ShowTrainingPlanState();
}

class _ShowTrainingPlanState extends State<ShowTrainingPlan>{
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.training.completed;
  }

  Future<void> _setTrainingCompleted() async {

    // Pobierz token z pamięci
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      return;
    }

    final url = Uri.parse('${AppConfig.markCompletedTrainingPlan}/${widget.training.id}/true'); 
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final message = response.body;

      if (mounted) {
        setState(() {
          _isCompleted = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
        );
      }
    } else {
      // Obsługa błędów
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }

  Future<void> _takeAction(String action) async {
    print(widget.training.completed);
    print(widget.training.id);

    if (action == 'add') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTraining(onBack: (){}, dayIso: widget.dayIso),
          ),
        );

        if (result == true) {
          _setTrainingCompleted();
          Navigator.pop(context, true);
        }
    } else if(action == 'track') {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrackTraining(onBack: (){}, dayIso: widget.dayIso),
          ),
        );

        if (result == true) {
          await _setTrainingCompleted();
          if (mounted) {
             Navigator.pop(context, true); 
          }
        }
    } else if (action == 'edit') {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTraining(onBack: (){}),
          ),
        );

        if (result == true) {
          await _setTrainingCompleted();
          if (mounted) {
             Navigator.pop(context, true); 
          }
        }
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
          title: Text(lang.t('yourTraining'), style: TextStyle(color: AppColors.text)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column( 
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        children: [

                          // WARTOŚCI
                          Row(children: [
                            Text(lang.t('trainingDate'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text('${widget.training.dateTime.day}.${widget.training.dateTime.month}.${widget.training.dateTime.year}', 
                            style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('trainingTime'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text('${widget.training.dateTime.hour}:${widget.training.dateTime.minute}', style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('duration'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text('${(widget.training.targetDuration ~/ 3600 )} h ${(widget.training.targetDuration % 3600) ~/ 60} min', style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          Row(children: [
                            Text(lang.t('notes'), style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                            Spacer(),
                             Expanded(
                              child: Center(
                                child: Align(
                                  alignment: AlignmentDirectional.centerEnd,
                                  child: Text(
                                    widget.training.notes,
                                    textAlign: TextAlign.justify,
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                    style: TextStyle(color: AppColors.text,))
                                  ),
                              )
                             )
                            ]),
                        const SizedBox(height: 32),

                        if (widget.isToday) ...[
                        // Track training
                        SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isCompleted ? AppColors.text : AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: (){
                                        if (!_isCompleted) {
                                          _takeAction('track');
                                        }
                                      },
                                      child: Text(
                                        _isCompleted ? lang.t('completed') : lang.t('trackTraining'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.background,
                                        ),
                                      ),
                                    ),
                            ),
                        const SizedBox(height: 12),
                        SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isCompleted ? AppColors.text : AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: (){
                                        if (!_isCompleted) {
                                          _takeAction('add');
                                        }
                                      },
                                      child: Text(
                                        _isCompleted ? lang.t('completed') : lang.t('addTraining'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.background,
                                        ),
                                      ),
                                    ),
                            ),
                        ] else ...[
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isCompleted ? AppColors.text : AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      onPressed: (){
                                        if (!_isCompleted) {
                                          _takeAction('edit');
                                        }
                                      },
                                      child: Text(
                                        _isCompleted ? lang.t('completed') : lang.t('editTraining'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.background,
                                        ),
                                      ),
                                    ),
                            ),
                        ],
                        const SizedBox(height: 24),

                        ],
                      )
                    ),
                  ),
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