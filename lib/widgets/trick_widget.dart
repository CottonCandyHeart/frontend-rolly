import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend_rolly/config.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/trick_list.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TrickWidget extends StatefulWidget {
  final TrickList trick;
  final Future<List<TrickList>> trickList;
  final VoidCallback onBack;
  final Function(TrickList trick) onTrickUpdated; 

  const TrickWidget({
    super.key,
    required this.trick,
    required this.trickList,
    required this.onBack,
    required this.onTrickUpdated,   
  });

  @override
  State<TrickWidget> createState() => _TrickWidgetState();
}

class _TrickWidgetState extends State<TrickWidget> {
  late YoutubePlayerController _controller;
  List<TrickList> allTypes = [];
  late TrickList selectedTrick;

  @override
  void initState() {
    super.initState();

    selectedTrick = widget.trick;

    final id = YoutubePlayerController.convertUrlToId(widget.trick.link);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: id!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    loadTricks();
  }

  Future<List<TrickList>> fetchTricks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')!;

    final url = "${AppConfig.trickByCategoryEndpoint}/${widget.trick.categoryName}";

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    final List data = jsonDecode(response.body);
    return data.map((e) => TrickList.fromJson(e)).toList();
  }


  Future<void> loadTricks() async {
   // final tricks = await widget.trickList;
   final tricks = await fetchTricks();

    if (!mounted) return;
    setState(() {
      allTypes = tricks
        .where((t) => t.trickName == widget.trick.trickName)
        .toList();
      
      final updated = allTypes.firstWhere(
        (t) => t.id == widget.trick.id,
        orElse: () => selectedTrick,
      );

      selectedTrick = updated;
    });
  }

  Future<void> _setMastered() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final url;

    if (!selectedTrick.isMastered){
      url = Uri.parse('${AppConfig.trickEndpoint}/${selectedTrick.id}'); 
    } else {
      url = Uri.parse('${AppConfig.trickEndpoint}/remove/${selectedTrick.id}'); 
    }


    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    

    if (response.statusCode == 200) {
      final message = response.body;
      setState(() {
        selectedTrick.isMastered = !selectedTrick.isMastered;

        int index = allTypes.indexWhere((t) => t.id == selectedTrick.id);
        if (index != -1) {
          allTypes[index].isMastered = selectedTrick.isMastered;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t(message))),
      );

      widget.onTrickUpdated(selectedTrick);
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

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0),
                  child: IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.text,
                    iconSize: 30,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            Text(
              widget.trick.trickName,
              style: const TextStyle(
                fontSize: 24,
                color: AppColors.text,
                fontFamily: 'Poppins-Bold',
              ),
            ),

            const SizedBox(height: 20),

            if (allTypes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 10,
                  children: allTypes.map((trickVariant) {
                    final isSelected = trickVariant.leg == selectedTrick.leg;

                    return ChoiceChip(
                      label: Text(trickVariant.leg),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedTrick = trickVariant;
                          

                          final id = YoutubePlayerController
                              .convertUrlToId(trickVariant.link);

                          _controller.loadVideoById(videoId: id!);
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.accent,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.background
                            : AppColors.text,
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 20),

            YoutubePlayer(
              controller: _controller,
            ),
            const SizedBox(height: 12),

            if (selectedTrick.isMastered)
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _setMastered,
                              child: Text(
                                lang.t('mastered'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                    ),
                  ),
              ),
            if (!selectedTrick.isMastered)
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsetsGeometry.fromLTRB(20, 0, 20, 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: _setMastered,
                              child: Text(
                                lang.t('notMastered'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.background,
                                ),
                              ),
                            ),
                    ),
                  ),
              ),

            const SizedBox(height: 20),

            Padding(
              padding: EdgeInsetsGeometry.all(20),
              child: Text(
                selectedTrick.description,
                textAlign: TextAlign.justify,
                style: const TextStyle(
                  color: AppColors.text,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          ],
        ),
      )
    );
  }
}
