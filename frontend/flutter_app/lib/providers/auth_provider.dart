import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authProvider = FutureProvider<UserModel?>((ref) async {
  final token = await AuthService.getStoredToken();
  if (token != null) {
    final authService = AuthService();
    return await authService.getUser(token);
  }
  return null;
});
