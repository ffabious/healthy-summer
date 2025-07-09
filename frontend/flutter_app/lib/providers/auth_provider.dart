import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../core/secure_storage.dart';

final authProvider = FutureProvider<UserModel?>((ref) async {
  final token = await SecureStorage.getToken();
  if (token != null) {
    return await AuthService().getUser(token);
  }
  return null;
});
