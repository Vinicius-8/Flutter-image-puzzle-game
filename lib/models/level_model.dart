class Level {
  final int? id;
  final String date;
  final int level;

  Level({this.id, required this.date, required this.level});

  Map<String, dynamic> toMap() {
    return {
//      'id': id,
      'date': date,
      'level': level,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.

  @override
  String toString() {
    return '$level,$date,$id';
  }
}
