// File generated manually for MoodBridge Firebase project
// Project: moodbridge-app
// Account: xgirl2510@gmail.com

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
        return windows;
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
    apiKey: 'AIzaSyAHeSPRS-FqQHV8Xhu4P9scdlEAElta76Y',
    appId: '1:209388970065:web:947838188dfae3e1519870',
    messagingSenderId: '209388970065',
    projectId: 'moodbridge-app',
    authDomain: 'moodbridge-app.firebaseapp.com',
    storageBucket: 'moodbridge-app.firebasestorage.app',
    measurementId: 'G-3R4JSKLH2S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAHeSPRS-FqQHV8Xhu4P9scdlEAElta76Y',
    appId: '1:209388970065:android:3bb64eb20b1ddb55519870',
    messagingSenderId: '209388970065',
    projectId: 'moodbridge-app',
    storageBucket: 'moodbridge-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAHeSPRS-FqQHV8Xhu4P9scdlEAElta76Y',
    appId: '1:209388970065:ios:cb56c37b08500681519870',
    messagingSenderId: '209388970065',
    projectId: 'moodbridge-app',
    storageBucket: 'moodbridge-app.firebasestorage.app',
    iosBundleId: 'com.moodbridge.moodbridge',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAHeSPRS-FqQHV8Xhu4P9scdlEAElta76Y',
    appId: '1:209388970065:ios:cb56c37b08500681519870',
    messagingSenderId: '209388970065',
    projectId: 'moodbridge-app',
    storageBucket: 'moodbridge-app.firebasestorage.app',
    iosBundleId: 'com.moodbridge.moodbridge',
  );

  // Windows app not yet registered in Firebase Console
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAHeSPRS-FqQHV8Xhu4P9scdlEAElta76Y',
    appId: '1:209388970065:web:947838188dfae3e1519870',
    messagingSenderId: '209388970065',
    projectId: 'moodbridge-app',
    authDomain: 'moodbridge-app.firebaseapp.com',
    storageBucket: 'moodbridge-app.firebasestorage.app',
    measurementId: 'G-3R4JSKLH2S',
  );
}
