import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/trick_list.dart';
import 'package:frontend_rolly/widgets/trick_list_widget.dart';
import 'package:frontend_rolly/widgets/trick_widget.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../models/Category.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationState();
}

class _EducationState extends State<EducationScreen> {
  String? selectedCategory;
  TrickList? selectedTrick;

  Future<List<Category>> fetchCategories(BuildContext context) async {
    final lang = context.read<AppLanguage>();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final response = await http.get(
      Uri.parse(AppConfig.getCategoryEndpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception(lang.t('noCategoriesAvailable'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // kategoria nie jest wybrana
    if (selectedCategory == null) {
      return _buildCategoryList(context);
    } 

    // trick wybrany
    if(selectedTrick == null){
      return TrickListWidget(
        category: selectedCategory!,
        onBack: () => setState(() => selectedCategory = null),
        onTrickSelected: (trick) {
          setState(() {
            selectedTrick = trick;
          });
        },
      );
    }

    // trick niewybrany
    return TrickWidget(
      trick: selectedTrick!,
      onBack: () => setState(() => selectedTrick = null),
      onTrickUpdated: (updatedTrick) {
        setState(() {
          selectedTrick = updatedTrick;
        });
      },
    );
  }
  
  Widget _buildCategoryList(BuildContext context) {
    final lang = context.read<AppLanguage>();

    return FutureBuilder<List<Category>>(
      future: fetchCategories(context),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              lang.t('noAvailableCategories'),
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.text,
                fontFamily: 'Poppins-Bold',
              ),
            ),
          );
        }

        final categories = snapshot.data!;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: categories.map((category) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category.name;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(color: AppColors.accent),
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.75,
                  margin: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontFamily: 'Poppins-Bold',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}