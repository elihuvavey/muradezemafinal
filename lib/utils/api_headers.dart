import 'package:muradezema/utils/user_prefs.dart';

Map<String, String> authHeaders() {
  final token = HivePrefs.getString('token');
  if (token != null && token.isNotEmpty) {
    return {'Authorization': 'Bearer $token'};
  }
  return {};
}
