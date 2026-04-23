import 'package:dio/dio.dart';
import '../error/app_exceptions.dart';
import '../utils/logger.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = mapDioException(err);
    
    AppLogger.error(
      '[NETWORK ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      'Mapped to: ${appException.runtimeType}: ${appException.message}',
      err.error,
      err.stackTrace,
    );

    // Pass the mapped exception along
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appException,
      stackTrace: err.stackTrace,
    ));
  }
}
