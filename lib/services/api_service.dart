import 'package:dio/dio.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../models/card_model.dart';
import '../models/investment.dart';
import '../models/user.dart';
import '../models/beneficiary.dart';
import '../models/exchange_rate.dart';
import '../models/kyc.dart';
import '../models/app_notification.dart';
import '../models/savings_goal.dart';
import '../models/savings_setting.dart';
import 'api_client.dart';

class ApiService {
  final ApiClient _api;

  ApiService(this._api);

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _api.get('/dashboard');
    return response.data['data'] ?? response.data;
  }

  Future<List<Wallet>> getWallets() async {
    final response = await _api.get('/wallets');
    final raw = response.data['data'];
    final list = raw is List ? raw : (raw['wallets'] as List? ?? []);
    return list.map((e) => Wallet.fromJson(e)).toList();
  }

  Future<Wallet> getWallet(String uuid) async {
    final response = await _api.get('/wallets/$uuid');
    return Wallet.fromJson(response.data['data']);
  }

  Future<List<Transaction>> getTransactions({String? walletId}) async {
    final response = await _api.get('/transactions', queryParameters: {
      if (walletId != null) 'wallet_id': walletId,
    });
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => Transaction.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> transfer({
    required String recipient,
    required double amount,
    required String currency,
    String? description,
  }) async {
    final response = await _api.post('/transactions/transfer', data: {
      'recipient': recipient,
      'amount': amount,
      'currency': currency,
      if (description != null) 'description': description,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> fundWallet({
    required double amount,
    required String currency,
  }) async {
    final response = await _api.post('/transactions/fund', data: {
      'amount': amount,
      'currency': currency,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> convertCurrency({
    required String from,
    required String to,
    required double amount,
  }) async {
    final response = await _api.post('/transactions/exchange', data: {
      'from': from,
      'to': to,
      'amount': amount,
    });
    return response.data;
  }

  Future<List<CardModel>> getCards() async {
    final response = await _api.get('/cards');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => CardModel.fromJson(e)).toList();
  }

  Future<CardModel> createCard(Map<String, dynamic> data) async {
    final response = await _api.post('/cards', data: data);
    return CardModel.fromJson(response.data['data']);
  }

  Future<void> freezeCard(String uuid) async {
    await _api.post('/cards/$uuid/freeze');
  }

  Future<List<ExchangeRate>> getRates() async {
    final response = await _api.get('/rates');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => ExchangeRate.fromJson(e)).toList();
  }

  Future<ExchangeRate> getRate(String from, String to) async {
    final response = await _api.get('/rates/$from/$to');
    return ExchangeRate.fromJson(response.data['data']);
  }

  Future<List<Investment>> getInvestments() async {
    final response = await _api.get('/investments');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => Investment.fromJson(e)).toList();
  }

  Future<List<Beneficiary>> getBeneficiaries() async {
    final response = await _api.get('/beneficiaries');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => Beneficiary.fromJson(e)).toList();
  }

  Future<void> addBeneficiary(Map<String, dynamic> data) async {
    await _api.post('/beneficiaries', data: data);
  }

  Future<void> deleteBeneficiary(String id) async {
    await _api.delete('/beneficiaries/$id');
  }

  Future<KycSubmission> submitKyc({
    required String documentType,
    String? frontImagePath,
    String? backImagePath,
    String? selfiePath,
  }) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
      if (frontImagePath != null)
        'front_image': await MultipartFile.fromFile(frontImagePath),
      if (backImagePath != null)
        'back_image': await MultipartFile.fromFile(backImagePath),
      if (selfiePath != null)
        'selfie_image': await MultipartFile.fromFile(selfiePath),
    });
    final response = await _api.post('/kyc/submit', data: formData);
    return KycSubmission.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getKycStatus() async {
    final response = await _api.get('/kyc/status');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await _api.get('/dashboard');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getAdminDashboard() async {
    final response = await _api.get('/admin/dashboard');
    return response.data['data'] ?? response.data;
  }

  Future<List<User>> getAdminUsers() async {
    final response = await _api.get('/admin/users');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => User.fromJson(e)).toList();
  }

  Future<List<KycSubmission>> getAdminKycQueue() async {
    final response = await _api.get('/admin/kyc');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => KycSubmission.fromJson(e)).toList();
  }

  Future<void> approveKyc(String id) async {
    await _api.post('/admin/kyc/$id/approve');
  }

  Future<void> rejectKyc(String id, {String? reason}) async {
    await _api.post('/admin/kyc/$id/reject', data: {
      if (reason != null) 'reason': reason,
    });
  }

  Future<Map<String, dynamic>> getAdminAnalytics() async {
    final response = await _api.get('/admin/analytics');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> getReferralStats() async {
    final response = await _api.get('/referrals/stats');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> claimReferralBonus() async {
    final response = await _api.post('/referrals/claim');
    return response.data;
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('/notifications');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<int> getUnreadNotificationCount() async {
    final response = await _api.get('/notifications/unread-count');
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return (data['unread_count'] as int?) ?? 0;
  }

  Future<void> markNotificationRead(int id) async {
    await _api.post('/notifications/$id/read');
  }

  Future<void> markAllNotificationsRead() async {
    await _api.post('/notifications/read-all');
  }

  // Admin notification endpoints
  Future<List<dynamic>> getAdminNotifications() async {
    final response = await _api.get('/admin/notifications');
    return (response.data['data'] as List?) ?? [];
  }

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) async {
    final response = await _api.post('/admin/notifications', data: data);
    return response.data['data'] ?? response.data;
  }

  Future<void> updateNotification(int id, Map<String, dynamic> data) async {
    await _api.put('/admin/notifications/$id', data: data);
  }

  Future<void> publishNotification(int id) async {
    await _api.post('/admin/notifications/$id/publish');
  }

  Future<void> deleteNotification(int id) async {
    await _api.delete('/admin/notifications/$id');
  }

  // ── Savings ─────────────────────────────────────────────

  Future<Map<String, dynamic>> getTotalSaved() async {
    final response = await _api.get('/savings/total-saved');
    if (response.data['success'] == true && response.data['data'] is Map) {
      return response.data['data'];
    }
    return {
      'total_saved': 0,
      'wallet_balance': 0,
      'investments_total': 0,
      'goals_total': 0,
      'growth_rate': 0,
    };
  }

  Future<Map<String, dynamic>> getWealth() async {
    final response = await _api.get('/savings/wealth');
    return response.data['data'] ?? response.data;
  }

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final response = await _api.get('/savings/goals');
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => SavingsGoal.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> createSavingsGoal(Map<String, dynamic> data) async {
    final response = await _api.post('/savings/goals', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> contributeToGoal(String uuid, double amount) async {
    final response = await _api.post('/savings/goals/$uuid/contribute', data: {
      'amount': amount,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> deleteSavingsGoal(String uuid) async {
    final response = await _api.delete('/savings/goals/$uuid');
    return response.data;
  }

  Future<Map<String, dynamic>> getSafebox() async {
    final response = await _api.get('/savings/safebox');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> createSafebox(Map<String, dynamic> data) async {
    final response = await _api.post('/savings/safebox', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> getFixedDeposits() async {
    final response = await _api.get('/savings/fixed-deposits');
    return response.data['data'] ?? response.data;
  }

  Future<Map<String, dynamic>> createFixedDeposit(Map<String, dynamic> data) async {
    final response = await _api.post('/savings/fixed-deposits', data: data);
    return response.data;
  }

  Future<SavingsSetting> getSpendSave() async {
    final response = await _api.get('/savings/spend-save');
    return SavingsSetting.fromJson(response.data['data']);
  }

  Future<SavingsSetting> updateSpendSave(Map<String, dynamic> data) async {
    final response = await _api.post('/savings/spend-save', data: data);
    return SavingsSetting.fromJson(response.data['data']);
  }
}
