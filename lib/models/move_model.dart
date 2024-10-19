class Move {
  final int? id;
  final String date;
  final int moves;

  Move({this.id, required this.date, required this.moves});

  Map<String, dynamic> toMap() {
    return {
//      'id': id,
      'date': date,
      'moves': moves,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.

  @override
  String toString() {
    return '$moves,$date,$id';
  }
}
