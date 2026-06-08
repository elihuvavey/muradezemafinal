import 'package:dio/dio.dart';
import 'package:muradezema/utils/user_prefs.dart';

Dio createDio() {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Remove any existing Authorization header that has null/empty token
      final auth = options.headers['Authorization'];
      if (auth != null && (auth.toString().contains('null') || auth.toString().endsWith('Bearer '))) {
        options.headers.remove('Authorization');
      }
      // Add valid token if available
      final token = HivePrefs.getString('token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
  ));
  return dio;
}
