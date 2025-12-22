import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/trick_list.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTrickScreen extends StatefulWidget{
  final VoidCallback onBack;
  final void Function()? onRefresh;

  const AddTrickScreen({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  State<StatefulWidget> createState() => _AddTrickScreenState();
}

class _AddTrickScreenState extends State<AddTrickScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  String? _nameError;
  String? _categoryError;
  String? _legError;
  String? _linkError;

  String? _selectedCategory;
  String? _selectedLeg;

  List<String> _categories = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = AppConfig.getCategoryEndpoint; 

    final response = await http.get( 
      Uri.parse(url), 
      headers: {'Authorization': 'Bearer $token',}, 
    );

    if (response.statusCode == 200){
      final List<dynamic> jsonList = jsonDecode(response.body);

      final List<String> categories = jsonList
          .map((e) => e['name'] as String)
          .toList();

      if (mounted) {
        
        setState(() {
          _categories = categories;
        });
      }

    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }

  Future<void> _addTrick() async {
    final prefs = await SharedPreferences.getInstance(); 
      final token = prefs.getString('jwt_token')!; 
      final url = AppConfig.adminAddTrick; 

      final trick = TrickList(
        categoryName: _selectedCategory!,
        trickName: _nameController.text.trim(),
        link: _linkController.text.trim(),
        leg: _selectedLeg!,
        description: _descriptionController.text.trim(), 
        isMastered: false,
      );
      
      final response = await http.post( 
        Uri.parse(url), 
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        }, 
        body: jsonEncode(trick.toJson()),
      );
      
      setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;
      widget.onRefresh?.call();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
        _nameController.clear();
        _descriptionController.clear();
        Navigator.pop(context, true);
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
    final lang = Provider.of<AppLanguage>(context);

    List<String> _legs = [lang.t('right'), lang.t('left')];

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
          title: Text(lang.t('addTrick'), style: TextStyle(color: AppColors.text)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column( 
                children: [
                  const SizedBox(height: 24),

                  // Nazwa
                  Text(
                        lang.t('trickName'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _nameError,
                      errorMaxLines: 3,
                      hintText: lang.t('name'),
                      hintStyle: TextStyle(
                        color: AppColors.text,
                      ),
                      filled: true,
                      fillColor: AppColors.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Opis
                  Text(
                    lang.t('description'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: null, 
                    minLines: 5,
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // link
                  Text(
                        lang.t('trickLink'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _linkController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      errorText: _linkError,
                      errorMaxLines: 3,
                      hintText: lang.t('link'),
                      hintStyle: TextStyle(
                        color: AppColors.text,
                      ),
                      filled: true,
                      fillColor: AppColors.accent,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // categoryName
                  Text(
                    lang.t('category'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: lang.t('chooseCategory'),
                      filled: true,
                      fillColor: AppColors.accent,
                      errorText: _categoryError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _categories.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _categoryError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // leg
                  Text(
                    lang.t('leg'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedLeg,
                    decoration: InputDecoration(
                      labelText: lang.t('chooseLeg'),
                      filled: true,
                      fillColor: AppColors.accent,
                      errorText: _legError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    items: _legs.map((style) {
                      return DropdownMenuItem(
                        value: style,
                        child: Text(style),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeg = value;
                        _legError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 36),

                  // Przycisk dodawania
                  const SizedBox(height: 20),
                  SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _addTrick,
                                child: Text(
                                  lang.t('addTrick'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
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
