class VocabularyWord {
  final String kana;
  final String kanji;
  final String romaji;
  final String meaningVi;
  final String meaningEn;
  final String typeEn;
  final String typeVi;
  final String audio;

  VocabularyWord({
    required this.kana,
    required this.kanji,
    required this.romaji,
    required this.meaningVi,
    required this.meaningEn,
    required this.typeEn,
    required this.typeVi,
    required this.audio,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      kana: json['kana'] ?? '',
      kanji: json['kanji'] ?? '',
      romaji: json['romaji'] ?? '',
      meaningVi: json['meaning_vi'] ?? '',
      meaningEn: json['meaning_en'] ?? '',
      typeVi: json['type_vi'] ?? '',
      typeEn: json['type_en'] ?? '',
      audio: json['audio_url'] ?? '',
    );
  }
}
