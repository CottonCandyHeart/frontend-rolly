import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:frontend_rolly/config.dart'; 
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/location.dart';
import 'package:frontend_rolly/models/meeting.dart'; 
import 'package:frontend_rolly/theme/colors.dart';
import 'package:frontend_rolly/widgets/location_map.dart'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart'; 

class MeetingWidget extends StatefulWidget { 
  const MeetingWidget(
    { super.key, required this.selectedMeeting, required this.onBack, required this.onMeetingUpdated, required this.onRefresh}
  ); 

  final Meeting selectedMeeting; 
  final VoidCallback onBack; 
  final VoidCallback onRefresh;
  final Function(Meeting? meeting) onMeetingUpdated;

  @override
  State<MeetingWidget> createState() => _MeetingWidgetState();
}

class _MeetingWidgetState  extends State<MeetingWidget> {
  Location? location;
  int? noOfParticipants;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadAllInitialData();
  }

  Future<void> _loadAllInitialData() async {
    await _amIOwner();
    await _getNoOfParticipants();
    
    await _loadLocation();
  }

  Future<void> _loadLocation() async {
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = "${AppConfig.getLocationByName}/${Uri.encodeComponent(widget.selectedMeeting.locationName)}";
    final response = await http.get( Uri.parse(url), headers: {'Authorization': 'Bearer $token'}, );
    
    if (!mounted) return;

    print("API LOCATION DATA: ${response.body}");
    setState(() {
      location = Location.fromJson(jsonDecode(response.body));
    });
  }

  Future<void> _getNoOfParticipants() async {
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = '${AppConfig.getParticipants}/${Uri.encodeComponent(widget.selectedMeeting.name)}';
    final response = await http.get( 
      Uri.parse(url), 
      headers: {'Authorization': 'Bearer $token'},
    ); 

    final parsed = jsonDecode(response.body);

    if (!mounted) return;

    if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);

        print('API PARTICIPANTS DATA (JSON): $parsed');
        setState(() {
          noOfParticipants = parsed is int ? parsed : int.tryParse(parsed.toString()); 
        });
    } else {
        print('Status ${response.statusCode}, Body: ${response.body}');

        setState(() {
            noOfParticipants = 0; 
        });
        
        if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
            );
        }
    }
  }

  Future<void> _amIOwner() async {
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = '${AppConfig.checkOwner}/${Uri.encodeComponent(widget.selectedMeeting.name)}';
    final response = await http.get( 
      Uri.parse(url), 
      headers: {'Authorization': 'Bearer $token'},
    ); 
    
    try {
        if (response.statusCode == 200) {
            final parsed = jsonDecode(response.body);
            print('API OWNER DATA (JSON): $parsed');

            if (!mounted) return;

            setState(() {
                isOwner = parsed is bool ? parsed : false; 
            });

        } else {
            print('Status ${response.statusCode}, Body: ${response.body}');
            
            if (!mounted) return;
            
            setState(() {
                isOwner = false;
            });
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
            );
        }
      } catch (e) {
          print('$e');
          if (!mounted) return;
          setState(() {
              isOwner = false;
          });
      }

      print('Owner: $isOwner');
      print('Owner: ${response.statusCode}');

      if (!mounted) return;
  }

  Future<void> _deleteEvent() async {
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = '${AppConfig.deleteEvent}/${Uri.encodeComponent(widget.selectedMeeting.name)}';
    final response = await http.delete( 
      Uri.parse(url), 
      headers: {'Authorization': 'Bearer $token'},
    ); 

    print('Organizer: "${widget.selectedMeeting.organizerUsername}"');

    if (response.statusCode == 200) {
      final message = response.body;
      widget.onMeetingUpdated(null);
      widget.onRefresh.call();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      widget.onMeetingUpdated(null);
      widget.onRefresh.call();

      if (!mounted) return;
      
    } else {
      // Obsługa błędów
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }

  Future<void> _joinEvent() async{
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = '${AppConfig.eventEndpoint}/'; 

    widget.selectedMeeting.action = 'join';

    final response = await http.post( 
        Uri.parse(url), 
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        }, 
        body: jsonEncode(widget.selectedMeeting.toJson()),
    );

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
        await _getNoOfParticipants();
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
    final lang = context.read<AppLanguage>();

    final day = widget.selectedMeeting.dateTime.day.toString().padLeft(2, '0');
    final month = widget.selectedMeeting.dateTime.month.toString().padLeft(2, '0');
    final year = widget.selectedMeeting.dateTime.year.toString();

    final hour = widget.selectedMeeting.dateTime.hour.toString().padLeft(2, '0');
    final minute = widget.selectedMeeting.dateTime.minute.toString().padLeft(2, '0');

    if (location == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      SizedBox(
                        height: 300,
                        child: LocationMap(
                          location: location!,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${location!.latitude}, ${location!.longitude}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      Text(
                        widget.selectedMeeting.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$day.$month.$year',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            ' | ',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '$hour:$minute',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            ' | ',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            '${location!.city.isNotEmpty ? '${lang.t(location!.city)}, ' : ''}${lang.t(location!.country)}',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${lang.t('age')}: ${widget.selectedMeeting.age}',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            ' | ',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            lang.t(widget.selectedMeeting.type),
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            ' | ',
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            lang.t(widget.selectedMeeting.level),
                            style: TextStyle(
                              color: AppColors.text,
                            ),
                          ),
                        ]
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${lang.t('organizer')}: ${widget.selectedMeeting.organizerUsername}',
                        style: TextStyle(
                          color: AppColors.text,
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      Text(
                        widget.selectedMeeting.description,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 36),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 20),
                          if (isOwner) ...[
                            GestureDetector(
                              onTap: _deleteEvent,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                  color: Colors.red,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    lang.t('delete'),
                                    style: TextStyle(
                                      color: AppColors.background,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          GestureDetector(
                            onTap: (){
                              if (!isOwner){_joinEvent();};
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                color: AppColors.primary,
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '${noOfParticipants ?? 0} / ${widget.selectedMeeting.numberOfParticipants}',
                                  style: TextStyle(
                                    color: AppColors.background,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 20),
                        ],
                      ),
                      SizedBox(height: 36),
                  ],
              )
            ),
          )
        )
      )
    );
  }
  
  
}