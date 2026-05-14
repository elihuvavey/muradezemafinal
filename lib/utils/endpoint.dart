import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? "";

  static String get login => '$baseUrl/login';
  static String get register => '$baseUrl/register';
  static String get updateProfile => '$baseUrl/update_profile';
  static String get deleteAccount => '$baseUrl/delete_account';
  static String get podcasts => "$baseUrl/audio/episodes";
  static String get seasons => "$baseUrl/seasons/";
  static String get seasonEpisodes => "$baseUrl/season-episodes/";
  static String get videosUrl => "$baseUrl/podcast_main/episodes";
  static String get orderUrl => "$baseUrl/santimpay/purchase";
  static String get paypalUrl => "$baseUrl/paypal/purchase";
  static String get cbeUrl => "$baseUrl/cbe/purchase";
  static String get banks => "$baseUrl/localbank/banks";
  static String get purchase => "$baseUrl/localbank/purchase";
  static String get pendingPayments => "$baseUrl/localbank/pending-payments";
  static String get confirmPayment => "$baseUrl/localbank/confirm-payment";


}
