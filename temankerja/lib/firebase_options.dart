import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk platform ini.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7LoqAn8Tpb7HWYCPbFlx7YMc2pEqhp_E',
    authDomain: 'inovasisumut.firebaseapp.com',
    projectId: 'inovasisumut',
    storageBucket: 'inovasisumut.firebasestorage.app',
    messagingSenderId: '727191947730',
    appId: '1:727191947730:web:583c690fa198fce97de00b',
    measurementId: 'G-EFKBQFZQ0C',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7LoqAn8Tpb7HWYCPbFlx7YMc2pEqhp_E',
    appId: '1:727191947730:android:583c690fa198fce97de00b',
    messagingSenderId: '727191947730',
    projectId: 'inovasisumut',
    storageBucket: 'inovasisumut.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC7LoqAn8Tpb7HWYCPbFlx7YMc2pEqhp_E',
    appId: '1:727191947730:ios:583c690fa198fce97de00b',
    messagingSenderId: '727191947730',
    projectId: 'inovasisumut',
    storageBucket: 'inovasisumut.firebasestorage.app',
    iosBundleId: 'com.example.temankerja',
  );
}