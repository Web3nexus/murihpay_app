import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_client.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(apiClientProvider));
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
