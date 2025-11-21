import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/trick_list.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class TrickListWidget extends StatelessWidget {
  const TrickListWidget({
    super.key,
    required this.category,
    required this.onBack,
    required this.onTrickSelected,
  });

  final String category;
  final VoidCallback onBack;
  final Function(TrickList trick) onTrickSelected;

  Future<List<TrickList>> fetchTricks(BuildContext context) async {
    print("I'm here");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;

    final url = "${AppConfig.trickByCategoryEndpoint}/$category";
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    final List data = jsonDecode(response.body);

    return data.map((e) => TrickList.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppLanguage>();

    return FutureBuilder<List<TrickList>>(
      future: fetchTricks(context),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  lang.t('noTricksAvailable'),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.text,
                    fontFamily: 'Poppins-Bold',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: onBack,
                    child: Text(
                      lang.t('back'),
                      style: TextStyle(
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final tricks = snapshot.data!;

        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
                child: IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.text,
                  iconSize: 30,
                ),
              ),
            ),
            ...tricks.map((trick) {
              return GestureDetector(
                onTap: () => onTrickSelected(trick),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.accent),
                  padding: const EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width * 0.75,
                  margin: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      trick.trickName,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontFamily: 'Poppins-Bold',
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
