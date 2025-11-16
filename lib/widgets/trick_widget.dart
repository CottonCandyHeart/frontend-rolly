import 'package:flutter/material.dart';
import 'package:frontend_rolly/lang/app_language.dart';
import 'package:frontend_rolly/models/trick_list.dart';
import 'package:frontend_rolly/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TrickWidget extends StatefulWidget {
  final TrickList trick;
  final VoidCallback onBack;

  const TrickWidget({
    super.key,
    required this.trick,
    required this.onBack,
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
