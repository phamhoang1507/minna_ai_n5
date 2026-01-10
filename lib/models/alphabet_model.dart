class AlphabetModel {
  final String id;
  final String char;
  final String romaji;
  final String audio;

  AlphabetModel({
    required this.id,
    required this.char,
    required this.romaji,
    required this.audio,
  });

  factory AlphabetModel.fromJson(Map<String, dynamic> json) {
    return AlphabetModel(
      id: json['id'],
      char: json['char'],
      romaji: json['romaji'],
      audio: json['audio'],
    );
  }
}
