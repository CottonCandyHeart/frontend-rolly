import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart';
import 'package:frontend_rolly/models/route.dart';
import 'package:frontend_rolly/models/training_plan.dart';
import 'package:frontend_rolly/screens/add_training.dart';
import 'package:frontend_rolly/screens/plan_training.dart';
import 'package:frontend_rolly/screens/show_training_plan.dart';
import 'package:frontend_rolly/screens/track_training.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/widgets/meeting_widget.dart';
import 'package:frontend_rolly/widgets/show_route.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCalendar extends StatefulWidget {
  final Future<List<TrainingPlan>> Function() trainings;
  final Future<List<TrainingRoute>> Function() routes;
  final DateTime chosen;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Future<void> Function()? onRefresh;

  const CustomCalendar({
    super.key,
    required this.trainings,
    required this.routes,
    required this.chosen,
    required this.onPrev,
    required this.onNext,
    required this.onRefresh,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar>{

  List<int> highlightedDays = [];
  List<int> daysWithPlannedTrainings = [];
  List<int> daysWithMeetings = [];

  int? selectedDay;
  List<TrainingPlan> selectedDayTrainings = [];
  List<TrainingRoute> selectedRoutes = [];
  List<Meeting> selectedMeetings = [];

  List<TrainingPlan> allTrainings = [];
  List<TrainingRoute> allRoutes = [];
  List<Meeting> allMeetings = [];

  @override
  void initState() {
    super.initState();
    widget.trainings().then((plans) {
      print("Plans fetched: ${plans.length}");
      setState(() {
        allTrainings = plans;
        daysWithPlannedTrainings = extractTrainingDays(plans);
      });
    });
    widget.routes().then((routes) {
      print("Routes fetched: ${routes.length}");
      setState(() {
        allRoutes = routes;
        highlightedDays = extractRouteDays(routes);
      });
    });
    _fetchAllMeetings();
  }

  List<Meeting> meetingsForDay(int day) {
    return allMeetings.where((m) =>
      m.dateTime.year == widget.chosen.year &&
      m.dateTime.month == widget.chosen.month &&
      m.dateTime.day == day
    ).toList();
  }

  List<TrainingPlan> trainingsForDay(int day) {
    return allTrainings.where((t) =>
      t.dateTime.year == widget.chosen.year &&
      t.dateTime.month == widget.chosen.month &&
      t.dateTime.day == day
    ).toList();
  }

  List<TrainingRoute> routesForDay(int day) {
    return allRoutes.where((r) =>
      r.date.year == widget.chosen.year &&
      r.date.month == widget.chosen.month &&
      r.date.day == day
    ).toList();
  }

  List<int> extractMeetingDays(List<Meeting> meetings) {
    return meetings
        .map((m) => m.dateTime.day)
        .toSet()
        .toList()
      ..sort();
  }

  List<int> extractMeetingDaysForMonth(List<Meeting> meetings) {
    return meetings
        .where((m) =>
            m.dateTime.year == widget.chosen.year &&
            m.dateTime.month == widget.chosen.month)
        .map((m) => m.dateTime.day)
        .toSet()
        .toList()
      ..sort();
  }

  List<int> extractTrainingDays(List<TrainingPlan> plans) {
    return plans
        .map((t) => t.dateTime.day)
        .toSet()
        .toList()
      ..sort();
  }

  List<int> extractRouteDays(List<TrainingRoute> routes) {
    return routes
        .map((r) => r.date.day)
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

  final daysOfWeek = List.of([
    'mon','tue','wed','thu','fri','sat','sun',
  ]);

  @override
  void didUpdateWidget(covariant CustomCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadMonth();
  }

  Future<void> _loadMonth() async {
    setState(() {
      highlightedDays = [];
      selectedDay = null;
      selectedDayTrainings = [];
      selectedRoutes = [];
    });

    final plans = await widget.trainings();
    final routes = await widget.routes();

    setState(() {
      allTrainings = plans;
      allRoutes = routes;
      highlightedDays = extractRouteDays(routes);
      daysWithPlannedTrainings = extractTrainingDays(plans);
    });
  }

  Future<void> _fetchAllMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;
    
    final url = AppConfig.getUserAttendedEvents;
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      print(jsonDecode(response.body));
      final meetings = jsonList.map((e) => Meeting.fromJson(e)).toList();

      setState(() {
        allMeetings = meetings;
        daysWithMeetings = extractMeetingDaysForMonth(meetings);
      });

      print("Meetings fetched: ${allMeetings.length}");
    } else {
      print("FAILED fetching meetings: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();

    final DateTime today = DateTime.now();
    DateTime chosen = widget.chosen;
    int daysInMonth = countDays(chosen);

    final firstDayOfMonth = DateTime(chosen.year, chosen.month, 1); // 1 - Monday
    final int startingWeekday = firstDayOfMonth.weekday;
    final int startOffset = startingWeekday - 1;
    final int totalItems = daysInMonth + startOffset;

    bool isToday(int day){
      return (day == today.day && chosen.month == today.month && chosen.year == today.year);
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
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
                                selectedRoutes = [];
                                allMeetings = [];
                              });
                              widget.onPrev();
                              _fetchAllMeetings();
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
                          color: AppColors.background,
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
                                selectedRoutes = [];
                                allMeetings = [];
                              });
                              widget.onNext();
                              _fetchAllMeetings();
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
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Text(
                          lang.t(daysOfWeek[index]),
                          style: TextStyle(
                            color: AppColors.background,
                          ),
                          )
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                      ),
                      itemCount: totalItems,
                      itemBuilder: (context, index) {
                        if (index < startOffset) {
                          return Container();
                        }

                        final day = index - startOffset + 1;
                        final isHighlighted = highlightedDays.contains(day);
                        final hasTraining = daysWithPlannedTrainings.contains(day);

                        return GestureDetector(
                          onTap: ()=>{
                            setState(() {
                              selectedDay = day;
                              selectedDayTrainings = trainingsForDay(day);
                              selectedRoutes = routesForDay(day);
                              selectedMeetings = meetingsForDay(day);
                            })
                          },
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isToday(day) ? AppColors.secondary : (isHighlighted ? AppColors.accent : AppColors.current),
                                  borderRadius: BorderRadius.circular(6),
                                  border: hasTraining ? Border.all(
                                    color: ((DateTime(chosen.year, chosen.month, day)).isBefore(today) && isHighlighted) ? 
                                          AppColors.text : AppColors.background, 
                                    width: 2.0,        
                                    style: BorderStyle.solid, 
                                  ) : null,
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
                              ),
                              if (daysWithMeetings.contains(day)) ...[
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.deepPurple,
                                    ),
                                  )
                                ),
                              ]
                            ],
                          ),
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

                if (daysWithMeetings.contains(selectedDay))  ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
                      child: Text(
                        lang.t('upcomingMeetings'),
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ),
                  
                  const SizedBox(height: 8),
                    
                  ...selectedMeetings.map((t) => GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetingWidget(
                            selectedMeeting: t,
                            onBack: () => Navigator.of(context).pop(), 
                            onMeetingUpdated: (updatedMeeting) {
                              setState(() {});
                            },
                            onRefresh: () => setState((){}),
                          ),
                        ),
                      );

                      if (result == true) {
                        await widget.onRefresh?.call();
                      }
                    },
                    child: Container(
                          width: MediaQuery.of(context).size.width * 0.75,
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.current,
                          ),
                          child: Text(
                            t.name,
                            style: const TextStyle(color: AppColors.background),
                          ),
                        ),
                  ),
                  ),
                ],

                if ((DateTime(chosen.year, chosen.month, selectedDay!)).isBefore(today)) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
                      child: Text(
                        lang.t('doneTrainings'),
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ),
                  
                  const SizedBox(height: 8),
                    
                  ...selectedRoutes.map((t) => GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowRoute(onBack: (){}, route: t),
                        ),
                      );

                      if (result == true) {
                        await widget.onRefresh?.call();
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.current,
                      ),
                      child: Text(
                        t.name,
                        style: const TextStyle(color: AppColors.background),
                      ),
                    )
                  ),
                  ),
                  if (isToday(selectedDay!)) ...[
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
                                      builder: (context) => TrackTraining(
                                        onBack: (){},
                                        dayIso: '${chosen.year}-${chosen.month}-$selectedDay',
                                      ),
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
                                          builder: (context) => TrackTraining(
                                            onBack: (){},
                                            dayIso: '${chosen.year}-${chosen.month}-$selectedDay',
                                          ),
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
              ],
              Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
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
                                await widget.onRefresh?.call();
                              }
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
                                      await widget.onRefresh?.call();
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

              const SizedBox(height: 12),

              if ((DateTime(chosen.year, chosen.month, selectedDay!)).isAfter(today) || isToday(selectedDay!)) ...[ 
                Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsetsGeometry.fromLTRB(25, 0, 0, 0),
                      child: Text(
                        lang.t('futureTrainings'),
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    )
                  ),
                  
                  const SizedBox(height: 8),

                ...selectedDayTrainings.map((t) => GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowTrainingPlan(
                            onBack: (){}, 
                            training: t,
                            dayIso: '${chosen.year}-${chosen.month}-$selectedDay',
                            isToday: isToday(selectedDay!),
                            ),
                          )
                        );
                      if (result == true) {
                          await widget.onRefresh?.call();
                      };
                    },
                    child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                    ),
                    child: Row(
                      children: [
                        Text(
                          t.dateTime.toString(),
                          style: const TextStyle(color: AppColors.text),
                        ),
                        Spacer(),
                        Icon(t.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: t.completed ? AppColors.primary : AppColors.text,
                        size: 30,),
                      ],
                    ),
                  )
                  ),
                ),

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.75,
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlanTraining(
                                    onBack: (){}, 
                                    dayIso: '${chosen.year}-${chosen.month}-$selectedDay',
                                  ),
                                ),
                              );

                              if (result == true) {
                                await widget.onRefresh?.call();
                              }
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
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PlanTraining(
                                          onBack: (){}, 
                                          dayIso: '${chosen.year}-${chosen.month}-$selectedDay',
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      await widget.onRefresh?.call();
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
              ),
              ]
            ]
            ]
          ),
          ]
        )
      )
    );
    
  }
}
