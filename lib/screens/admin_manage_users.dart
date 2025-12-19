import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
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

class AdminManageUsers extends StatefulWidget {
  const AdminManageUsers({super.key, required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final void Function()? onRefresh;

  @override
  State<AdminManageUsers> createState() => _AdminManageUsersState();
}

class _AdminManageUsersState extends State<AdminManageUsers> {
  String? selected;
  List<UserResponse> _allUsers = [];

  String _query = '';
  List<UserResponse> _filteredUsers = [];

  List<String> _roles = [];

  String? selectedRole;

  @override
  void initState() {
    super.initState();
    getUsers();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;
    
    final response = await http.get(
      Uri.parse(AppConfig.getAllRoles),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      if (!mounted) return;
      setState(() {
        _roles = data.map<String>((role) => role['name'] as String).toList();
      });
    }
  }

  Future<void> getUsers() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse(AppConfig.getAllUsers); 
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (!mounted) return;

      final List jsonList = jsonDecode(response.body);
      print(jsonList.length);
      final users = jsonList.map((e) => UserResponse.fromJson(e)).toList();

      setState(() {
        _allUsers = users;
        _allUsers.sort(
          (a, b) => a.username.toLowerCase().compareTo(b.username.toLowerCase()),
        );

         _filteredUsers = List.from(_allUsers);
      });
    } else {
      print("Action failed");
      if (!mounted) return;
    }
  }

  Timer? _debounce;

  void _filterUsers(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filteredUsers = _allUsers
            .where((u) =>
                u.username.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  Future<void> _confirmDelete(UserResponse user) async {
    final lang = context.read<AppLanguage>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.t('confirmDeleteTitle')),
          content: Text(
            lang.t('confirmDeleteMessage') + '\n\n${user.username}',
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
      await _deleteUser(user);
    }
  }

  Future<void> _deleteUser(UserResponse user) async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse(AppConfig.removeUser); 
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      body: jsonEncode(user.toJson())
    );

    if (response.statusCode == 200) {
      final message = response.body;
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      setState(() {
        getUsers();
      });
    } else {
      final message = response.body;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );
      if (!mounted) return;
    }
  }

  Future<void> _saveRole(UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');


    final response = await http.post(
      Uri.parse(AppConfig.changeRole),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': user.username,
        'roleName': user.role,
      }),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Action Failed')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role Saved')),
      );
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
          SizedBox(),
          Spacer(),
          Text(lang.t('adminManageUsers'), style: TextStyle(color: AppColors.text)),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.text),
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddUserScreen(
                    onBack: () async {
                      await getUsers();
                    },
                  )
                ),
              );
            },
          ),
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
                    onChanged: _filterUsers,
                    decoration: InputDecoration(
                      hintText: lang.t('searchUser'),
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
                ..._filteredUsers.map((t)=>Container(
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
                              t.username,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Spacer(),
                          if (t.username != 'admin')  ...[
                            IconButton(
                              onPressed: (){_confirmDelete(t);}, 
                              icon: Icon(Icons.delete, size: 30, color: Colors.red,),
                            )
                          ]
                        ],
                      ),
                      Row(children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              lang.t('role'),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Spacer(),
                        if (t.username != 'admin') ...[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: DropdownButtonFormField<String>(
                              value: t.role,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                filled: true,
                                fillColor: AppColors.secondary,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              items: _roles.map((style) {
                                return DropdownMenuItem(
                                  value: style,
                                  child: Text(style, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14,)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                setState(() {
                                  t.role = value;
                                });

                                _saveRole(t);
                              },
                            ),
                          ),
                        ] else ...[
                          Text(
                              t.role,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.text,
                              ),
                            ),
                        ]

                      ],)
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



