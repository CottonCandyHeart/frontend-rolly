import 'dart:convert'; 
import 'package:flutter/material.dart'; 
import 'package:frontend_rolly/config.dart'; 
import 'package:frontend_rolly/lang/app_language.dart'; 
import 'package:frontend_rolly/models/trick_list.dart'; 
import 'package:frontend_rolly/theme/colors.dart'; 
import 'package:http/http.dart' as http; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:provider/provider.dart'; 

class TrickListWidget extends StatefulWidget { 
  const TrickListWidget(
    { super.key, required this.category, required this.onBack, required this.onTrickSelected, }
  ); 

  final String category; 
  final VoidCallback onBack; 
  final Function(TrickList trick) onTrickSelected;

   @override
  State<TrickListWidget> createState() => _TrickListWidgetState();
}

class _TrickListWidgetState  extends State<TrickListWidget> {
  late Future<List<TrickList>> _tricksFuture;

  @override
  void initState() {
    super.initState();
    _tricksFuture = fetchTricks();
  }
  
  Future<List<TrickList>> fetchTricks() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = "${AppConfig.trickByCategoryEndpoint}/${widget.category}"; 
    final response = await http.get( Uri.parse(url), headers: {'Authorization': 'Bearer $token'}, ); 
    final List data = jsonDecode(response.body); return data.map((e) => TrickList.fromJson(e)).toList(); 
  } 

  Future<void> _resetProgress(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception("Missing token");
    }

    final url = Uri.parse(AppConfig.resetTrickEndpoint); 

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    

    if (response.statusCode == 200) {
      final message = response.body;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t(message))),
      );

      setState(() {
        _tricksFuture = fetchTricks();
      });

    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
    }
  }
  
  @override Widget build(BuildContext context) { 
    final lang = context.read<AppLanguage>(); 
    return FutureBuilder<List<TrickList>>( 
      future: _tricksFuture, 
      builder: (context, snapshot) { 
        if (snapshot.connectionState == ConnectionState.waiting) { 
          return const Center(child: CircularProgressIndicator()); 
        } 
        if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) { 
          return Center( 
            child: Column( 
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [ 
                Text( lang.t('noTricksAvailable'), 
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
                    onPressed: widget.onBack, 
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
            Row(
              children: [
                Align( 
                  alignment: Alignment.centerLeft, 
                  child: Padding( 
                    padding: EdgeInsetsGeometry.fromLTRB(10, 0, 0, 0), 
                    child: IconButton( 
                      onPressed: widget.onBack, 
                      icon: const Icon(Icons.arrow_back), 
                      color: AppColors.text, iconSize: 30, 
                    ), 
                  ), 
                ), 
                Spacer(),
                Align( 
                  alignment: Alignment.centerRight, 
                  child: Padding( 
                    padding: EdgeInsetsGeometry.fromLTRB(0, 0, 20, 0), 
                    child: GestureDetector(
                      onTap: () => _resetProgress(context),
                      child: Text(
                        lang.t('resetProgress'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ), 
                ), 
              ],
            ),
            
            ...tricks.map((trick) { 
              return GestureDetector( 
                onTap: () => widget.onTrickSelected(trick), 
                child: Container( 
                  decoration: BoxDecoration(
                    color: AppColors.accent), 
                    padding: const EdgeInsets.all(20), 
                    width: MediaQuery.of(context).size.width * 0.75, 
                    margin: const EdgeInsets.only(top: 20), 
                    child: Center( 
                      child: Row( 
                        children: [ 
                          Text( 
                            trick.trickName, 
                            style: const TextStyle( 
                              color: AppColors.text, 
                              fontFamily: 'Poppins-Bold', 
                              fontSize: 20, 
                            ), 
                          ), 
                          
                          Spacer(), 
                          
                          if (trick.isMastered) 
                            const Icon( 
                              Icons.check, 
                              color: AppColors.current, 
                              size: 28,
                            ), 
                        ] 
                      ), 
                    ), 
                  ), 
                ); 
              }
            ), 
          ], 
        ); 
      }, 
    ); 
  }
}