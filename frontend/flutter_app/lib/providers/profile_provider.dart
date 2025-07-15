import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';
import '../core/secure_storage.dart';

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  final token = await SecureStorage.getToken();
  return await AuthService().getProfile(token ?? '');
});
