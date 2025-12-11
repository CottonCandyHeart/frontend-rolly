import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:frontend_rolly/config.dart'; 
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart'; 
import 'package:frontend_rolly/screens/add_meeting.dart'; 
import 'package:frontend_rolly/theme/colors.dart'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart'; 

class ManageWidget extends StatefulWidget { 
  const ManageWidget(
    { super.key, required this.selectedScreen, required this.onBack, required this.onMeetingSelected }
  ); 

  final String selectedScreen; 
  final VoidCallback onBack; 
  final Function(Meeting meeting) onMeetingSelected;

   @override
  State<ManageWidget> createState() => _ManageWidgetState();
}

class _ManageWidgetState  extends State<ManageWidget> {
  late Future<List<Meeting>> _meetingFuture = Future.value([]);
  late List<Meeting> _meetings;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  void _loadMeetings() async {
    _meetingFuture = fetchMeetings();
    final meetingsList = await _meetingFuture;
    _meetings = meetingsList.map((m) => m).toList();
  }

  Future<List<Meeting>> fetchMeetings() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = AppConfig.getUserEvents; 
    
    final response = await http.get( Uri.parse(url), headers: {'Authorization': 'Bearer $token', 
        'Content-Type': 'application/json',}, ); 

    if (response.statusCode != 200) {
      print("Server error: ${response.body}");
      throw Exception("Server returned ${response.statusCode}");
    }
    
    final List data = jsonDecode(response.body); return data.map((e) => Meeting.fromJson(e)).toList(); 
  }

  Future<void> _addMeeting() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMeeting(onBack: (){}, onRefresh: () async {setState(() {_loadMeetings();});},)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            Spacer(),

                            Align( 
                              alignment: Alignment.center, 
                              child: Padding( 
                                padding: EdgeInsetsGeometry.fromLTRB(0, 0, 10, 0), 
                                child: SizedBox( 
                                  width: 150, 
                                  child: ElevatedButton( 
                                    style: ElevatedButton.styleFrom( 
                                      backgroundColor: AppColors.primary, 
                                      shape: RoundedRectangleBorder( 
                                        borderRadius: BorderRadius.circular(25), 
                                      ), 
                                      padding: const EdgeInsets.symmetric(vertical: 16), 
                                    ), 
                                    onPressed: _addMeeting, 
                                    child: Text( 
                                      lang.t('addMeeting'), 
                                      style: TextStyle( 
                                        color: AppColors.background, 
                                      ), 
                                    ), 
                                  ), 
                                ),
                              ), 
                            ),
                            Spacer(),
                            SizedBox(width: 20,),
                          ]
                        ),
                       
                        SizedBox(height: 32,),
                        Text( lang.t('noMeetingsAvailable'), 
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
                        Spacer(),

                        Align( 
                          alignment: Alignment.center, 
                          child: Padding( 
                            padding: EdgeInsetsGeometry.fromLTRB(0, 0, 10, 0), 
                            child: SizedBox( 
                              width: 150, 
                              child: ElevatedButton( 
                                style: ElevatedButton.styleFrom( 
                                  backgroundColor: AppColors.primary, 
                                  shape: RoundedRectangleBorder( 
                                    borderRadius: BorderRadius.circular(25), 
                                  ), 
                                  padding: const EdgeInsets.symmetric(vertical: 16), 
                                ), 
                                onPressed: _addMeeting, 
                                child: Text( 
                                  lang.t('addMeeting'), 
                                  style: TextStyle( 
                                    color: AppColors.background, 
                                  ), 
                                ), 
                              ), 
                            ), 
                          ), 
                        ),
                        Spacer(),
                        SizedBox(width: 20,),  
                      ],
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
                              child: Text( 
                                    '${meeting.dateTime.year}-${meeting.dateTime.month.toString().padLeft(2, '0')}-${meeting.dateTime.day.toString().padLeft(2, '0')} ${meeting.dateTime.hour.toString().padLeft(2, '0')}:${meeting.dateTime.minute.toString().padLeft(2, '0')} // ${meeting.name}', 
                                    style: const TextStyle( 
                                      color: AppColors.text, 
                                      fontFamily: 'Poppins-Bold', 
                                      fontSize: 12, 
                                    ), 
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