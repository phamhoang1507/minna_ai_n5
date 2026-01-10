import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:minna_ai_n5/models/alphabet_progress_model.dart';

class AlphabetProgressService {
  final _firestore = FirebaseFirestore.instance;

  // Prefix để tránh trùng key với dữ liệu khác trong SharedPreferences
  static const String _localKeyPrefix = 'alphabet_progress_';

  /// LƯU LOCAL (OFFLINE) bằng SharedPreferences
  Future<void> saveLocal({
    required String userId,
    required AlphabetProgress progress,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localKeyPrefix${userId}_${progress.alphabetId}';

    // Chỉ lưu những thông tin cần thiết (bool + timestamp milliseconds)
    final Map<String, dynamic> localData = {
      'isMastered': progress.isMastered,
      'updatedAt': progress.updatedAt.millisecondsSinceEpoch, // Timestamp → int
    };

    // SharedPreferences chỉ lưu được primitive, nên encode thành JSON string
    await prefs.setString(key, localData.toString());
  }

  /// LẤY LOCAL từ SharedPreferences
  Future<AlphabetProgress?> getLocal({
    required String userId,
    required String alphabetId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_localKeyPrefix${userId}_$alphabetId';

    final String? dataString = prefs.getString(key);
    if (dataString == null) return null;

    // Parse lại string thành Map (cách đơn giản vì chỉ có 2 field)
    // Ví dụ: "{isMastered: true, updatedAt: 1736419200000}"
    final RegExp regExp = RegExp(r"isMastered: (\w+), updatedAt: (\d+)");
    final match = regExp.firstMatch(dataString);

    if (match == null) return null;

    final bool isMastered = match.group(1) == 'true';
    final int millis = int.parse(match.group(2)!);

    return AlphabetProgress(
      alphabetId: alphabetId,
      isMastered: isMastered,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(millis),
    );
  }

  /// ĐỒNG BỘ LÊN FIREBASE
  Future<void> syncToFirebase({
    required String userId,
    required AlphabetProgress progress,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('alphabet_progress')
        .doc(progress.alphabetId)
        .set(progress.toJson(), SetOptions(merge: true));
  }

  /// HÀM CHÍNH: Lưu cả local + sync Firebase (giống hàm cũ của bạn)
  Future<void> save({
    required String userId,
    required AlphabetProgress progress,
  }) async {
    // 1️⃣ Lưu local trước (offline first)
    await saveLocal(userId: userId, progress: progress);

    // 2️⃣ Đồng bộ lên Firebase (nếu có mạng thì thành công, không thì thôi)
    try {
      await syncToFirebase(userId: userId, progress: progress);
    } catch (e) {
      // Không crash app nếu không có mạng
      print('Sync Firebase thất bại (offline?): $e');
    }
  }
}