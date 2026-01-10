// // File: lib/providers/alphabet_progress_provider.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:minna_ai_n5/core/service/alphabet_progress_service.dart';
// import '../models/alphabet_progress_model.dart';

// // Provider cho AlphabetProgressService (giữ nguyên)
// final alphabetProgressServiceProvider = Provider<AlphabetProgressService>(
//   (ref) => AlphabetProgressService(),
// );

// // ✨ THÊM MỚI: Provider để lấy Map của tất cả progress (alphabetId -> AlphabetProgress)
// final alphabetProgressMapProvider =
//     StreamProvider<Map<String, AlphabetProgress>>((ref) {
//       final userId = FirebaseAuth.instance.currentUser?.uid;

//       if (userId == null) {
//         return Stream.value({});
//       }

//       return FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('alphabet_progress')
//           .snapshots()
//           .map((snapshot) {
//             final Map<String, AlphabetProgress> progressMap = {};

//             for (var doc in snapshot.docs) {
//               try {
//                 final data = doc.data();
//                 progressMap[doc.id] = AlphabetProgress.fromJson({
//                   ...data,
//                   'alphabetId': doc.id, // Đảm bảo có alphabetId
//                 });
//               } catch (e) {
//                 print('Error parsing progress for ${doc.id}: $e');
//               }
//             }

//             return progressMap;
//           });
//     });

// // ✨ THÊM MỚI: Provider để lấy progress của một alphabet cụ thể (optional - nếu cần)
// final alphabetProgressProvider =
//     StreamProvider.family<AlphabetProgress?, String>((ref, alphabetId) {
//       final userId = FirebaseAuth.instance.currentUser?.uid;

//       if (userId == null) {
//         return Stream.value(null);
//       }

//       return FirebaseFirestore.instance
//           .collection('users')
//           .doc(userId)
//           .collection('alphabet_progress')
//           .doc(alphabetId)
//           .snapshots()
//           .map((doc) {
//             if (!doc.exists) return null;

//             try {
//               final data = doc.data()!;
//               return AlphabetProgress.fromJson({
//                 ...data,
//                 'alphabetId': alphabetId,
//               });
//             } catch (e) {
//               print('Error parsing progress for $alphabetId: $e');
//               return null;
//             }
//           });
//     });

// // ✨ THÊM MỚI: Provider để đếm số alphabet đã mastered (optional)
// final masteredCountProvider = StreamProvider<int>((ref) {
//   final userId = FirebaseAuth.instance.currentUser?.uid;

//   if (userId == null) {
//     return Stream.value(0);
//   }

//   return FirebaseFirestore.instance
//       .collection('users')
//       .doc(userId)
//       .collection('alphabet_progress')
//       .where('isMastered', isEqualTo: true)
//       .snapshots()
//       .map((snapshot) => snapshot.docs.length);
// });

// File: lib/providers/alphabet_progress_provider.dart
// File: lib/providers/alphabet_progress_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minna_ai_n5/core/service/alphabet_progress_service.dart';
import '../models/alphabet_progress_model.dart';

final alphabetProgressServiceProvider = Provider<AlphabetProgressService>(
  (ref) => AlphabetProgressService(),
);

// ✅ Provider chung cho TẤT CẢ progress
final alphabetProgressMapProvider =
    StreamProvider<Map<String, AlphabetProgress>>((ref) {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        return Stream.value({});
      }

      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('alphabet_progress')
          .snapshots()
          .map((snapshot) {
            final Map<String, AlphabetProgress> progressMap = {};

            for (var doc in snapshot.docs) {
              try {
                final data = doc.data();
                progressMap[doc.id] = AlphabetProgress.fromJson({
                  ...data,
                  'alphabetId': doc.id,
                });
              } catch (e) {
                print('Error parsing progress for ${doc.id}: $e');
              }
            }

            return progressMap;
          });
    });

// ✅ Provider riêng cho HIRAGANA progress - FIX
final hiraganaProgressMapProvider =
    Provider<AsyncValue<Map<String, AlphabetProgress>>>((ref) {
      final allProgressAsync = ref.watch(alphabetProgressMapProvider);

      return allProgressAsync.whenData((map) {
        // Lọc chỉ lấy hiragana progress và bỏ prefix
        final hiraganaMap = <String, AlphabetProgress>{};
        map.forEach((key, value) {
          if (key.startsWith('hiragana_')) {
            // final shortKey = key.replaceFirst(
            //   'hiragana_',
            //   '',
            // ); // "hiragana_a" -> "a"
            hiraganaMap[key] = value;
          }
          // print('111111111111');
          // print(value);
          // print('111111111111');
          // hiraganaMap[key] = value;
        });
        return hiraganaMap;
      });
    });

// ✅ Provider riêng cho KATAKANA progress - FIX
final katakanaProgressMapProvider =
    Provider<AsyncValue<Map<String, AlphabetProgress>>>((ref) {
      final allProgressAsync = ref.watch(alphabetProgressMapProvider);

      return allProgressAsync.whenData((map) {
        // Lọc chỉ lấy katakana progress và bỏ prefix
        final katakanaMap = <String, AlphabetProgress>{};
        map.forEach((key, value) {
          if (key.startsWith('katakana_')) {
            // final shortKey = key.replaceFirst(
            //   'katakana_',
            //   '',
            // ); // "katakana_a" -> "a"
            // katakanaMap[shortKey] = value;
          katakanaMap[key] = value;
          }
        });
        return katakanaMap;
      });
    });

// Optional: Đếm số đã mastered cho từng loại
final hiraganaMasteredCountProvider = Provider<int>((ref) {
  final progressMapAsync = ref.watch(hiraganaProgressMapProvider);

  return progressMapAsync.when(
    data: (map) => map.values.where((p) => p.isMastered).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final katakanaMasteredCountProvider = Provider<int>((ref) {
  final progressMapAsync = ref.watch(katakanaProgressMapProvider);

  return progressMapAsync.when(
    data: (map) => map.values.where((p) => p.isMastered).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
