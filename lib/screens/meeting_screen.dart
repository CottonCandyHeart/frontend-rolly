import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart';
import 'package:frontend_rolly/widgets/find_meetings_widget.dart';
import 'package:frontend_rolly/widgets/manage_meetings_widget.dart';
import 'package:frontend_rolly/widgets/meeting_widget.dart';
import 'package:frontend_rolly/widgets/your_meeting_widget.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>{
  String? selected;
  Meeting? selectedMeeting;
  bool isAttended = false;

  @override
  Widget build(BuildContext context) {

    if (selectedMeeting != null) {
      return MeetingWidget(
        selectedMeeting: selectedMeeting!,
        onBack: () => setState(() => selectedMeeting = null),
        onMeetingUpdated: (updatedMeeting) {
          setState(() {
            selectedMeeting = updatedMeeting;
          });
        },
        onRefresh: () => setState((){}),
      );
    }

    if (selected == 'manage') {
      return ManageWidget(
        selectedScreen: selected!,
        onBack: () => setState(() => selected = null),
        onMeetingSelected: (meeting) {
          setState(() {
            selectedMeeting = meeting;
          });
        },
      );
    }
    
    if (selected == 'your') {
      return YourMeetingsWidget(
        selectedScreen: selected!,
        onBack: () => setState(() => selected = null),
        onMeetingSelected: (meeting) {
          setState(() {
            selectedMeeting = meeting;
          });
        },
        onRefresh: () => setState((){}),
      );
    }
    
    if (selected == 'find') {
      return FindMeetingsWidget(
        selectedScreen: selected!,
        onBack: () => setState(() => selected = null),
        onMeetingSelected: (meeting) {
          setState(() {
            selectedMeeting = meeting;
          });
        },
      );
    } 


    return _buildMeetingScreen(context);
    
  }

  Widget _buildMeetingScreen(BuildContext context) {
    final lang = context.read<AppLanguage>();

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  selected = 'manage';
                });
              },
              child: Container(
                decoration: BoxDecoration(color: AppColors.accent),
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.2,
                margin: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    lang.t('manageMeetings'),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontFamily: 'Poppins-Bold',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  selected = 'your';
                });
              },
              child: Container(
                decoration: BoxDecoration(color: AppColors.accent),
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.2,
                margin: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Text(
                    lang.t('yourMeetings'),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontFamily: 'Poppins-Bold',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                setState(() {
                  selected = 'find';
                });
              },
              child: Container(
                decoration: BoxDecoration(color: AppColors.accent),
                padding: const EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.75,
                height: MediaQuery.of(context).size.height * 0.2,
                margin: const EdgeInsets.only(top: 20),
                child: Center(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                        lang.t('findMeetings'),
                        style: const TextStyle(
                          color: AppColors.text,
                          fontFamily: 'Poppins-Bold',
                          fontSize: 20,
                        ),
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
      )
    );
  }
}