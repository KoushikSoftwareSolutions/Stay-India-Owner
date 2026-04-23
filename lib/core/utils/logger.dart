import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void success(String message) {
    _logger.i('✅ SUCCESS: $message');
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void debug(String message) {
    _logger.d(message);
  }
  
  static void purple(String message) {
     _logger.t(message); // Using trace for special highlights
  }
}
