class AppConstants {
  // API
  static const String baseUrl = 'https://api.example.com';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyLocale = 'locale';
  static const String keyTheme = 'theme';

  // Notification Channels
  static const String defaultNotificationChannel = 'default_channel';
  static const String defaultNotificationChannelName = 'Default Channel';

  //Collections names
  static const String users = 'users';
  static const String items = 'items';
  static const String moderateUsers = 'moderateUsers';
  static const String moderateSales = 'moderateSales';

  //Remote config names
  static const String adminEmails = 'admin_emails';

  // Private constructor
  AppConstants._();
}
