class TrickList {
  final String categoryName;
  final String trickName;
  final String link;
  final String leg;
  final String description;
  bool isMastered;

  TrickList({
    required this.categoryName, 
    required this.trickName, 
    required this.link, 
    required this.leg,
    required this.description,
    required this.isMastered    
  });

  factory TrickList.fromJson(Map<String, dynamic> json) {
    return TrickList(
      categoryName: json['categoryName'],
      trickName: json['trickName'],
      link: json['link'],
      leg: json['leg'],
      description: json['description'],
      isMastered: json['mastered']
    );
  }
}
