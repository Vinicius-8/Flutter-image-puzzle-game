class Difficulty {
  final int? id;
  final String date;
  final int difficulty;

  Difficulty({this.id, required this.date, required this.difficulty});

  Map<String, dynamic> toMap() {
    return {
//      'id': id,
      'date': date,
      'difficulty': difficulty,
    };
  }



  @override
  String toString() {
    return '$difficulty,$date,$id';
  }
}
