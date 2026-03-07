class TrickList {
  int id;
  String categoryName;
  final String trickName;
  final String link;
  final String leg;
  final String description;
  bool isMastered;

  TrickList({
    required this.id,
    required this.categoryName, 
    required this.trickName, 
    required this.link, 
    required this.leg,
    required this.description,
    required this.isMastered    
  });

  factory TrickList.fromJson(Map<String, dynamic> json) {
    return TrickList(
      id: json['id'],
      categoryName: json['categoryName'],
      trickName: json['trickName'],
      link: json['link'],
      leg: json['leg'],
      description: json['description'],
      isMastered: json['mastered']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'trickName': trickName,
      'link': link,
      'leg': leg,
      'description': description,
      'isMastered': isMastered,
    };
  }
}
