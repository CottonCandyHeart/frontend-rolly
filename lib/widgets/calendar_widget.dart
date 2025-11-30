import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/screens/add_training.dart';
import 'package:frontend_rolly/screens/plan_training.dart';
import 'package:frontend_rolly/screens/track_training.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';

class CustomCalendar extends StatefulWidget {
  final Future<List<TrainingPlan>> trainings;
  final DateTime chosen;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const CustomCalendar({
    super.key,
    required this.trainings,
    required this.chosen,
    required this.onPrev,
    required this.onNext,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar>{
  List<int> highlightedDays = [];

  int? selectedDay;
  List<TrainingPlan> selectedDayTrainings = [];
  List<TrainingPlan> allTrainings = [];

  @override
  void initState() {
    super.initState();
    widget.trainings.then((plans) {
      setState(() {
        allTrainings = plans;
        highlightedDays = extractTrainingDays(plans);
      });
    });
  }

  List<TrainingPlan> trainingsForDay(int day) {
    return allTrainings.where((t) =>
      t.dateTime.year == widget.chosen.year &&
      t.dateTime.month == widget.chosen.month &&
      t.dateTime.day == day
    ).toList();
  }


  List<int> extractTrainingDays(List<TrainingPlan> plans) {
    return plans
        .map((t) => t.dateTime.day)
        .toSet()
        .toList()
      ..sort();
  }

  int countDays(DateTime date) {
      final beginningNextMonth = (date.month < 12)
          ? DateTime(date.year, date.month + 1, 1)
          : DateTime(date.year + 1, 1, 1);
      final lastDayOfMonth = beginningNextMonth.subtract(const Duration(days: 1));
      return lastDayOfMonth.day;
  }

  final months = List.of([
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
  ]);

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();

    final DateTime today = DateTime.now();
    DateTime chosen = widget.chosen;
    int daysInMonth = countDays(chosen);

    bool isToday(int day){
      return (day == today.day && chosen.month == today.month && chosen.year == today.year);
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 28),
          decoration: BoxDecoration(
            color: AppColors.primary,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            selectedDay = null;
                            selectedDayTrainings = [];
                          });
                          widget.onPrev();
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.background,
                        iconSize: 30,
                      ),
                    ),
                  ),
                  Spacer(),

                  Text(
                    "${lang.t(months[chosen.month-1])} ${chosen.year}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(0, 0, 10, 0),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            selectedDay = null;
                            selectedDayTrainings = [];
                          });
                          widget.onNext();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        color: AppColors.background,
                        iconSize: 30,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              SizedBox(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isHighlighted = highlightedDays.contains(day);

                    return GestureDetector(
                      onTap: ()=>{
                        setState(() {
                          selectedDay = day;
                        })
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isToday(day) ? AppColors.secondary : (isHighlighted ? AppColors.accent : AppColors.current),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            "$day",
                            style: TextStyle(
                              color: isToday(day) ? AppColors.current : (isHighlighted ? AppColors.text : AppColors.background),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    );
                  },
                ),
              ),
            ]
          )
        ),
        Column(children: [
            const SizedBox(height: 16),
            if (selectedDay == null) ...[
              Center(
                child: Text(
                  lang.t('chooseDate'),
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold
                  )
                ),
              )
            ],
            if (selectedDay != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(20, 0, 0, 0),
                  child: Text(
                    "$selectedDay.${chosen.month}.${chosen.year}",
                    style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              ),
              const SizedBox(height: 8),

              ...selectedDayTrainings.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.current,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${t.targetDuration} min — ${t.notes}",
                  style: const TextStyle(color: AppColors.text),
                ),
              )),

            if ((DateTime(chosen.year, chosen.month, selectedDay!)).isBefore(today)) ...[
              Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackTraining(onBack: (){},),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('trackTraining'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        decoration: BoxDecoration(color: AppColors.primary),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrackTraining(onBack: (){},),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              color: AppColors.background,
                              iconSize: 30,
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
          ),
          Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTraining(onBack: (){}, dayIso: '${chosen.year}-${chosen.month}-$selectedDay'),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('addTraining'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        decoration: BoxDecoration(color: AppColors.primary),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTraining(
                                      onBack: (){}, 
                                      dayIso: '${chosen.year}-${chosen.month}-$selectedDay',
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  setState(() {});
                                }
                              },
                              icon: const Icon(Icons.add),
                              color: AppColors.background,
                              iconSize: 30,
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
          )],
          if ((DateTime(chosen.year, chosen.month, selectedDay!)).isAfter(today)) ...[
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanTraining(onBack: (){},),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(color: AppColors.accent),
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 10, right: 5),
                          child: Text(
                              lang.t('planTraining'),
                              style: TextStyle(color: AppColors.text, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        decoration: BoxDecoration(color: AppColors.primary),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlanTraining(onBack: (){},),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              color: AppColors.background,
                              iconSize: 30,
                            ),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
          ),
          ]
        ]
        ]
      ),
      ]
    );
  }
}
