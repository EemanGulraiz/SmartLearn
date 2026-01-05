class AppConstants {
  static const String appIdEnv = String.fromEnvironment('appId', defaultValue: 'smart-learn-v1');
  static const String firebaseConfigStr = String.fromEnvironment(
    'firebaseConfig',
    defaultValue: '{"apiKey": "AIzaSyBcdIHRdsN_CmiibGv59PGgqXSNM0CossA", "authDomain": "smart-learn-app-b3843.firebaseapp.com", "projectId": "smart-learn-app-b3843", "storageBucket": "smart-learn-app-b3843.firebasestorage.app", "messagingSenderId": "1072911140026"}'
  );
}
