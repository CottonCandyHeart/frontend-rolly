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
  final VoidCallback onBack;
  final Function(TrickList trick) onTrickUpdated; 

  const TrickWidget({
    super.key,
    required this.trick,
    required this.onBack,
    required this.onTrickUpdated,   
  });

  @override
  State<TrickWidget> createState() => _TrickWidgetState();
}

class _TrickWidgetState extends State<TrickWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    final id = YoutubePlayerController.convertUrlToId(widget.trick.link);

    _controller = YoutubePlayerController.fromVideoId(
      videoId: id!,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
      ),
    );
  }

  Future<void> _setMastered() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final url;

    if (!widget.trick.isMastered){
      url = Uri.parse('${AppConfig.trickEndpoint}/${Uri.encodeComponent(widget.trick.trickName)}'); 
    } else {
      url = Uri.parse('${AppConfig.trickEndpoint}/remove/${Uri.encodeComponent(widget.trick.trickName)}'); 
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
      widget.trick.isMastered = !widget.trick.isMastered;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t(message))),
      );

      widget.onTrickUpdated(widget.trick);
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

    return Column(
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
              fontSize: 18,
              color: AppColors.text,
              fontFamily: 'Poppins-Bold',
            ),
          ),

          const SizedBox(height: 20),

          YoutubePlayer(
            controller: _controller,
          ),
          const SizedBox(height: 12),

          if (widget.trick.isMastered)
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
          if (!widget.trick.isMastered)
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
              widget.trick.description,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                color: AppColors.text,
                fontFamily: 'Poppins',
              ),
            ),
          )
        ],
      );
  }
}
