import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minna_ai_n5/utils/date_utils.dart';

class StreakService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> markStudiedToday() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);

    final snapshot = await userRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final lastStudyDate = data['lastStudyDate'];
    final currentStreak = data['streak'] ?? 0;

    final today = DateUtilsHelper.todayKey();
    final yesterday = DateUtilsHelper.yesterdayKey();

    int newStreak = currentStreak;

    if (lastStudyDate == today) {
      // đã tính streak hôm nay → không làm gì
      return;
    }

    if (lastStudyDate == yesterday) {
      newStreak = currentStreak + 1;
    } else {
      newStreak = 1;
    }

    await userRef.update({
      'lastStudyDate': today,
      'streak': newStreak,
    });

    await userRef
        .collection('daily_activity')
        .doc(today)
        .set({'studied': true});
  }
}
