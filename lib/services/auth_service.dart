import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= SIGN UP =================
  // Update your signUp method in AuthService.dart
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
    String? specialization,
    String? barCouncilId,
    // New Fields
    String? courtType,
    String? state,
    String? district,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final Map<String, dynamic> userData = {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'avatarInitial': name.isNotEmpty ? name[0].toUpperCase() : 'U',
      'createdAt': FieldValue.serverTimestamp(),
      // ✅ NEW: Verification status
      'status': role == 'lawyer' ? 'pending' : 'verified',
      'isVerified': false,
    };

    if (role == 'lawyer') {
      userData.addAll({
        'specialization': specialization ?? '',
        'barCouncilId': barCouncilId ?? '',
        'courtType': courtType ?? '',
        'state': state ?? '',
        'district': district ?? '',
        'experience': 0,
      });
    }

    await _firestore.collection('users').doc(uid).set(userData);
  }

  // ================= LOGIN =================
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential =
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  // ================= ROLE FETCH =================
  Future<String> getUserRole(String uid) async {
    final doc =
    await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    return doc['role'] as String;
  }

  // ================= GOOGLE LOGIN =================
  Future<void> saveGoogleUserIfNew({
    required User user,
    required String role,
    String? specialization,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      final name = user.displayName ?? 'User';

      /// ✅ SAME FIX HERE
      final Map<String, dynamic> data = {
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'avatarInitial': name[0].toUpperCase(),
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (role == 'lawyer') {
        data.addAll({
          'specialization': specialization ?? '',
          'verified': false,
          'experience': 0,
        });
      }

      await ref.set(data);
    }
  }
}
