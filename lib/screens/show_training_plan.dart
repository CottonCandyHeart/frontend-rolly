import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';


class ShowTrainingPlan extends StatefulWidget {
  final VoidCallback onBack;
  final TrainingPlan training;

  const ShowTrainingPlan({required this.onBack, required this.training});
  
  @override
  State<ShowTrainingPlan> createState() => _ShowTrainingPlanState();
}

class _ShowTrainingPlanState extends State<ShowTrainingPlan>{
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
                            Text('${widget.training.dateTime.day}.${widget.training.dateTime.month}.${widget.training.dateTime.day}', 
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
                            Text(widget.training.notes, style: TextStyle(color: AppColors.text)),
                          ],),
                          const SizedBox(height: 8),
                          
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