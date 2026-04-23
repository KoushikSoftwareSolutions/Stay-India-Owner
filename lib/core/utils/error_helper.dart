import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class ErrorHelper {
  static String toFriendlyMessage(dynamic error) {
    if (error is SocketException) {
      return "No internet connection. Please check your network.";
    }
    
    if (error is TimeoutException) {
      return "Request timed out. Please try again.";
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "The server took too long to respond. Please try again.";
        case DioExceptionType.connectionError:
          return "Cannot connect to the server. Check your internet.";
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          if (data is Map && data['message'] != null) {
            return data['message'].toString();
          }
          return "Server returned an error (${error.response?.statusCode}).";
        case DioExceptionType.cancel:
          return "Request was cancelled.";
        default:
          return "A network error occurred. Please try again.";
      }
    }
    
    if (error is FormatException) {
      return "Server communication error.";
    }

    final String errorStr = error.toString().toLowerCase();

    if (errorStr.contains("401") || errorStr.contains("unauthorized")) {
      return "Session expired. Please login again.";
    }
    
    if (errorStr.contains("403") || errorStr.contains("forbidden")) {
      return "You do not have permission for this action.";
    }

    if (errorStr.startsWith("exception: ")) {
      return errorStr.replaceFirst("exception: ", "");
    }

    // Mask very technical or long errors
    if (errorStr.length > 60 || errorStr.contains("null check") || errorStr.contains("type error")) {
      return "An unexpected error occurred. Please try again.";
    }

    return error.toString();
  }
}
