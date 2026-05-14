import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/endpoint.dart';
import '../utils/user_prefs.dart';

class BankProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<Map<String, dynamic>> _banks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get banks => _banks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBanks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _dio.get(
        ApiConstants.banks,
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${HivePrefs.getString('token')}',
        }),
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> banksData = response.data['banks'] ?? [];
        _banks = banksData.map<Map<String, dynamic>>((bank) {
          if (bank['id'] == null) {
            throw Exception('Bank object missing required id field: $bank');
          }
          return {
            'id': bank['id'],
            'name': bank['name']?.toString() ?? '',
            'account_number': bank['account_number']?.toString() ?? '',
          };
        }).toList();
      } else {
        _errorMessage = 'Failed to load banks.';
      }
    } catch (e) {
      _errorMessage = 'Error loading banks.';
    }
    _isLoading = false;
    notifyListeners();
  }
}
