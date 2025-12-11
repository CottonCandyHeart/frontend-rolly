import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:frontend_rolly/config.dart'; 
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart'; 
import 'package:frontend_rolly/models/trick_list.dart'; 
import 'package:frontend_rolly/theme/colors.dart'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart'; 

class YourMeetingsWidget extends StatefulWidget { 
  const YourMeetingsWidget(
    { super.key, required this.selectedScreen, required this.onBack, required this.onMeetingSelected }
  ); 

  final String selectedScreen; 
  final VoidCallback onBack; 
  final Function(Meeting meeting) onMeetingSelected;

   @override
  State<YourMeetingsWidget> createState() => _YourMeetingsWidgetState();
}

class _YourMeetingsWidgetState  extends State<YourMeetingsWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
  
}