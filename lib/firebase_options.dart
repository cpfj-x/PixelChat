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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCIZfZW8fb1ocwrb9bJeDyiXzsWaujAjOE',
    appId: '1:803502615276:web:abcdef1234567890',
    messagingSenderId: '803502615276',
    projectId: 'pixelchat-78f6b',
    authDomain: 'pixelchat-78f6b.firebaseapp.com',
    storageBucket: 'pixelchat-78f6b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIZfZW8fb1ocwrb9bJeDyiXzsWaujAjOE',
    appId: '1:803502615276:android:b6697fcb68889782e013c9',
    messagingSenderId: '803502615276',
    projectId: 'pixelchat-78f6b',
    storageBucket: 'pixelchat-78f6b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIZfZW8fb1ocwrb9bJeDyiXzsWaujAjOE',
    appId: '1:803502615276:ios:abcdef1234567890',
    messagingSenderId: '803502615276',
    projectId: 'pixelchat-78f6b',
    storageBucket: 'pixelchat-78f6b.firebasestorage.app',
    iosBundleId: 'com.example.pixelchat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCIZfZW8fb1ocwrb9bJeDyiXzsWaujAjOE',
    appId: '1:803502615276:macos:abcdef1234567890',
    messagingSenderId: '803502615276',
    projectId: 'pixelchat-78f6b',
    storageBucket: 'pixelchat-78f6b.firebasestorage.app',
    iosBundleId: 'com.example.pixelchat',
  );
}
