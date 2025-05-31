import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final _storage = const FlutterSecureStorage();

  // 获取当前用户
  User? get currentUser => _auth.currentUser;

  // 获取用户ID
  String? get userId => currentUser?.uid;

  // 检查用户是否已登录
  Future<bool> isLoggedIn() async {
    return currentUser != null;
  }

  // Google 登录
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 保存用户信息到安全存储
        await _storage.write(key: 'user_id', value: user.uid);
        await _storage.write(key: 'user_email', value: user.email);
        await _storage.write(key: 'user_name', value: user.displayName);
        await _storage.write(key: 'user_photo', value: user.photoURL);
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // 登出
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      await _storage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }

  // 获取存储的用户信息
  Future<Map<String, String?>> getUserInfo() async {
    return {
      'user_id': await _storage.read(key: 'user_id'),
      'user_email': await _storage.read(key: 'user_email'),
      'user_name': await _storage.read(key: 'user_name'),
      'user_photo': await _storage.read(key: 'user_photo'),
    };
  }
} 