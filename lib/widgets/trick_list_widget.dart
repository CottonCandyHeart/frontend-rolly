import 'dart:async';
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
  List<TrickList> _filteredTricks = [];
  List<TrickList> _allTricks = [];

  @override
  void initState() {
    super.initState();
    _loadAllTricks();
  }

  void _loadAllTricks() async {
    _tricksFuture = fetchTricks();

    _allTricks = await _tricksFuture;
    final grouped = <String, List<TrickList>>{};

    for (var trick in _allTricks) {
      grouped.putIfAbsent(trick.trickName, () => []);
      grouped[trick.trickName]!.add(trick);
    }

    _allTricks = grouped.entries.map((entry) {
      final tricks = entry.value;

      final allMastered = tricks.every((t) => t.isMastered);

      final first = tricks.first;

      return TrickList(
        id: first.id,
        trickName: first.trickName,
        description: first.description,
        link: first.link,
        leg: first.leg,
        isMastered: allMastered, 
        categoryName: first.categoryName,
      );
    }).toList();

    _filteredTricks = _allTricks;
    if (mounted) setState(() {});
  }
  
  Future<List<TrickList>> fetchTricks() async { 
    final prefs = await SharedPreferences.getInstance(); 
    final token = prefs.getString('jwt_token')!; 
    final url = "${AppConfig.trickByCategoryEndpoint}/${widget.category}"; 
    final response = await http.get( Uri.parse(url), headers: {'Authorization': 'Bearer $token'}, ); 
    final List data = jsonDecode(response.body); 
    
    return data.map((e) => TrickList.fromJson(e)).toList(); 
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
      refresh();

      setState(() {
        _tricksFuture = fetchTricks();
      });

    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<AppLanguage>().t('actionFailed'))),
      );
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

  void refresh() {
    setState(() {
      _tricksFuture = fetchTricks();
    });
    _loadAllTricks();
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
        
        return SafeArea (
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView (
                padding: const EdgeInsets.only(bottom: 32),
                child: Column( 
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(context.read<AppLanguage>().t('confirmResetTitle')),
                                    content: Text(context.read<AppLanguage>().t('confirmResetMessage')),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(context.read<AppLanguage>().t('cancel')),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: Text(context.read<AppLanguage>().t('yes')),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed == true) {
                                  await _resetProgress(context);
                                }
                              },
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
                    
                    ..._filteredTricks.map((trick) { 
                      return GestureDetector( 
                        onTap: () async {
                          await widget.onTrickSelected(trick);
                          refresh();
                        },
                        child: Container( 
                          decoration: BoxDecoration(
                            color: AppColors.accent), 
                            padding: const EdgeInsets.all(20), 
                            width: MediaQuery.of(context).size.width * 0.75, 
                            margin: const EdgeInsets.only(top: 20), 
                            child: Center( 
                              child: Row( 
                                children: [ 
                                  Expanded(
                                    child: Text( 
                                      trick.trickName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis, 
                                      style: const TextStyle( 
                                        color: AppColors.text, 
                                        fontFamily: 'Poppins-Bold', 
                                        fontSize: 20, 
                                      ), 
                                    ), 
                                  ),
                                  
                                  //Spacer(), 
                                  
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
                )
              );
            }
          )
        );    
      }, 
    ); 
  }
}