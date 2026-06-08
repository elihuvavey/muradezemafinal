import 'package:muradezema/utils/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../utils/user_prefs.dart';

class Product {
  final int id;
  final String title;
  final String image;
  final String duration;
  final String description;
  final bool isPremium;
  final String priceInLocal;
  final String priceInForeign;
  final bool isPurchased;

  Product({
    required this.id,
    required this.title,
    required this.image,
    required this.duration,
    required this.description,
    required this.isPremium,
    required this.priceInLocal,
    required this.priceInForeign,
    required this.isPurchased,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'],
        title: json['title'] ?? '',
        image: json['image'] ?? '',
        duration: json['duration'] ?? '',
        description: json['description'] ?? '',
        isPremium: json['is_premium'] == "1",
        priceInLocal: json['price_in_local'] ?? '',
        priceInForeign: json['price_in_foreign'] ?? '',
        isPurchased: json['is_purchased'] ?? false);
  }
}

class SaleItem {
  final String sales;
  final Product product;

  SaleItem({required this.sales, required this.product});

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      sales: json['sales'],
      product: Product.fromJson(json['product']),
    );
  }
}

class SaleService {
  final Dio _dio = createDio();

  Future<List<SaleItem>> fetchTopSellingAudio(String type) async {
    try {
      final response = await _dio.get('${dotenv.env['BASE_URL']}/top-selling',
          options: Options(headers: {
            
          }),
          queryParameters: {
            'type': type,
          });

      print('data top audio ${response.data}');

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((item) => SaleItem.fromJson(item))
            .toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }
}

class TopSellingProvider with ChangeNotifier {
  final SaleService _service = SaleService();
  List<SaleItem> _sales = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SaleItem> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTopSellingAudio(String type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sales = await _service.fetchTopSellingAudio(type);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
