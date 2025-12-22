import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/trick_list.dart';
import 'package:frontend_rolly/screens/add_category_screen.dart';
import 'package:frontend_rolly/screens/add_trick_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';

class AdminManageTricks extends StatefulWidget {
  const AdminManageTricks({super.key, required this.onBack, required this.onRefresh});

  final VoidCallback onBack;
  final void Function()? onRefresh;

  @override
  State<AdminManageTricks> createState() => _AdminManageTricksState();
}

class _AdminManageTricksState extends State<AdminManageTricks> {
  String? selected;
  List<TrickList> _allTricks= [];

  String _query = '';
  List<TrickList> _filteredTricks = [];
  @override
  void initState() {
    super.initState();
    getTricks();
  }

  Future<void> getTricks() async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse(AppConfig.getAllTricks); 
    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      if (!mounted) return;

      final List jsonList = jsonDecode(response.body);
      print(jsonList.length);
      final trick = jsonList.map((e) => TrickList.fromJson(e)).toList();

      setState(() {
        _allTricks = trick;
        _allTricks.sort(
          (a, b) => a.trickName.toLowerCase().compareTo(b.trickName.toLowerCase()),
        );

         _filteredTricks = List.from(_allTricks);
      });
    } else {
      print("Action failed");
      if (!mounted) return;
    }
  }

  Timer? _debounce;

  void _filterTricks(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filteredTricks = _allTricks
            .where((u) =>
                u.trickName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  Future<void> _confirmDelete(TrickList trick) async {
    final lang = context.read<AppLanguage>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lang.t('confirmDeleteTitle')),
          content: Text(
            lang.t('confirmDeleteMessage') + '\n\n${trick.trickName}',
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
      await _deleteCategory(trick);
    }
  }

  Future<void> _deleteCategory(TrickList trick) async{
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    final url = Uri.parse('${AppConfig.deleteTrick}/${Uri.encodeComponent(trick.trickName)}'); 
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
        getTricks();
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
          SizedBox(),
          Spacer(),
          Text(lang.t('adminAddTrick'), style: TextStyle(color: AppColors.text)),
          Spacer(),
          IconButton(
            icon: Icon(Icons.add, color: AppColors.text),
            iconSize: 30,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTrickScreen(
                    onBack: () async {
                      await getTricks();
                    },
                    onRefresh: () {setState(){};},
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
                    onChanged: _filterTricks,
                    decoration: InputDecoration(
                      hintText: lang.t('searchTrick'),
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
                ..._filteredTricks.map((t)=>Container(
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
                              t.trickName,
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



