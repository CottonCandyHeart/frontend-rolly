import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddCategoryScreen extends StatefulWidget{
  final VoidCallback onBack;

  const AddCategoryScreen({
    super.key,
    required this.onBack,
  });

  @override
  State<StatefulWidget> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();

  String? _nameError;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _addCategory() async {
    final prefs = await SharedPreferences.getInstance(); 
      final token = prefs.getString('jwt_token')!; 
      final url = AppConfig.addCategory; 
      
      final response = await http.post( 
        Uri.parse(url), 
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json',
        }, 
        body: jsonEncode({
          'id': 0,
          'name': _nameController.text.trim(),
        }),
      );
      
      setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<AppLanguage>().t('$message'))),
      );

      if (mounted) {
        _nameController.clear();
        widget.onBack();
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
          title: Text(lang.t('addCategory'), style: TextStyle(color: AppColors.text)),
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
                        lang.t('categoryName'),
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
                                onPressed: _addCategory,
                                child: Text(
                                  lang.t('addCategory'),
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
