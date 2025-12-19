import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/meeting.dart';
import 'package:frontend_rolly/models/user.dart';
import 'package:frontend_rolly/models/user_response.dart';
import 'package:frontend_rolly/screens/add_user.dart';
import 'package:frontend_rolly/screens/settings_screen.dart';
import 'package:frontend_rolly/units/app_units.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import 'home_screen.dart';
import 'education_screen.dart';
import 'training_screen.dart';
import 'meeting_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminManageMeetings extends StatefulWidget {
  const AdminManageMeetings({super.key, required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final void Function()? onRefresh;

  @override
  State<AdminManageMeetings> createState() => _AdminManageMeetingsState();
}

class _AdminManageMeetingsState extends State<AdminManageMeetings> {
  String? selected;
  List<Meeting> _allMeetings = [];

  String _query = '';
  List<Meeting> _filteredMeetings = [];
  @override
  void initState() {
    super.initState();
    getMeetings();
  }

  Future<void> getMeetings() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse(AppConfig.getAllEvents); 
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (!mounted) return;

      final List jsonList = jsonDecode(response.body);
      print(jsonList.length);
      final meet = jsonList.map((e) => Meeting.fromJson(e)).toList();

      setState(() {
        _allMeetings = meet;
        _allMeetings.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

         _filteredMeetings = List.from(_allMeetings);
      });
    } else {
      print("Action failed");
      if (!mounted) return;
    }
  }

  Timer? _debounce;

  void _filterMeetings(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filteredMeetings = _allMeetings
            .where((u) =>
                u.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  Future<void> _confirmDelete(Meeting meeting) async {
    final lang = context.read<AppLanguage>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.t('confirmDeleteTitle')),
          content: Text(
            lang.t('confirmDeleteMessage') + '\n\n${meeting.name}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(lang.t('cancel')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(lang.t('delete'), 
                style: TextStyle(color: AppColors.background)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteMeeting(meeting);
    }
  }

  Future<void> _deleteMeeting(Meeting meeting) async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse('${AppConfig.adminDeleteEvent}/${Uri.encodeComponent(meeting.name)}'); 
    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final message = response.body;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      setState(() {
        getMeetings();
      });
    } else {
      final message = response.body;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<AppLanguage>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.text,
            onPressed: () {
              widget.onBack();
            },
          ),
        title: Row(children: [
          Text(lang.t('adminManageMeetings'), style: TextStyle(color: AppColors.text)),
        ],)
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 32,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: TextField(
                    onChanged: _filterMeetings,
                    decoration: InputDecoration(
                      hintText: lang.t('searchMeeting'),
                      prefixIcon: const Icon(Icons.search, color: AppColors.text,),
                      filled: true,
                      fillColor: AppColors.accent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24,),
                ..._filteredMeetings.map((t)=>Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                    ),
                    child: Column(children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              t.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: (){_confirmDelete(t);}, 
                            icon: Icon(Icons.delete, size: 30, color: Colors.red,),
                          )
                        ],
                      ),
                    ],)
                  ),
                  ),
              ]
            ),
          ),
        )
      ),
    );
  }
}



