class VocabularyWord {
  final String id;
  final String kana;
  final String kanji;
  final String romaji;
  final String meaningVi;
  final String meaningEn;
  final String typeEn;
  final String typeVi;
  final String audio;

  VocabularyWord({
    required this.id,
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
      id: json['id'] ?? '',
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

  factory VocabularyWord.fromMap(Map<String, dynamic> map) {
    return VocabularyWord(
      id: map['id'],
      kana: map['kana'] ?? '',
      kanji: map['kanji'] ?? '',
      romaji: map['romaji'] ?? '',
      meaningVi: map['meaning_vi'] ?? '',
      meaningEn: map['meaning_en'] ?? '',
      typeVi: map['type_vi'] ?? '',
      typeEn: map['type_en'] ?? '',
      audio: map['audio_url'] ?? '',
    );
  }
}
