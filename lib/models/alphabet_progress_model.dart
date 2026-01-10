import 'package:cloud_firestore/cloud_firestore.dart';

class AlphabetProgress {
  final String alphabetId;
  final bool isMastered;
  final DateTime updatedAt;

  AlphabetProgress({
    required this.alphabetId,
    required this.isMastered,
    required this.updatedAt,
  });

  // ✅ Cần có fromJson
  factory AlphabetProgress.fromJson(Map<String, dynamic> json) {
    return AlphabetProgress(
      alphabetId: json['alphabetId'] ?? '',
      isMastered: json['isMastered'] ?? false,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(
              json['updatedAt'] ?? DateTime.now().toIso8601String(),
            ),
    );
  }

  // ✅ Cần có toJson
  Map<String, dynamic> toJson() {
    return {
      'alphabetId': alphabetId,
      'isMastered': isMastered,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Optional: copyWith method
  AlphabetProgress copyWith({
    String? alphabetId,
    bool? isMastered,
    DateTime? updatedAt,
  }) {
    return AlphabetProgress(
      alphabetId: alphabetId ?? this.alphabetId,
      isMastered: isMastered ?? this.isMastered,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
