import 'package:dio/dio.dart';
import 'dart:developer';

import 'package:flutter/material.dart';

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseHeader: true,
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Map<String, dynamic>> get(String url,
      {Map<String, String>? headers}) async {
    log('GET Request: $url');
    try {
      final response = await _dio.get(
        url,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String url,
      {dynamic data, Map<String, String>? headers}) async {
    debugPrint('POST Request: $url, Data: $data');
    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(String url,
      {dynamic data, Map<String, String>? headers}) async {
    log('PUT Request: $url, Data: $data');
    try {
      final response = await _dio.put(
        url,
        data: data,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String url,
      {Map<String, String>? headers}) async {
    log('DELETE Request: $url');
    try {
      final response = await _dio.delete(
        url,
        options: Options(headers: headers),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    log('Response (${response.statusCode}): ${response.data}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      log('Unexpected status code: ${response.statusCode}',
          error: response.statusMessage);
      return {
        'success': false,
        'error': 'Unexpected status code: ${response.statusCode}'
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioException) {
      log('DioException: ${error.message}', error: error);
      return {
        'success': false,
        'error': error.response?.data ?? error.message,
      };
    } else {
      log('Unknown error: $error', error: error);
      return {'success': false, 'error': 'An unknown error occurred'};
    }
  }
}
