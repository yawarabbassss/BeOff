import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/statistics_repository.dart';
import '../../domain/models/protection_stats.dart';

class StatisticsProvider extends ChangeNotifier {
  final StatisticsRepository _statsRepo;

  ProtectionStats _todayStats = ProtectionStats(date: DateTime.now());
  List<ProtectionStats> _weeklyStats = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  StatisticsProvider(this._statsRepo) {
    loadStats();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) => refreshStats());
  }

  ProtectionStats get todayStats => _todayStats;
  List<ProtectionStats> get weeklyStats => _weeklyStats;
  bool get isLoading => _isLoading;

  Future<void> loadStats() async {
    _isLoading = true;
    notifyListeners();

    _todayStats = await _statsRepo.getTodayStats();
    _weeklyStats = await _statsRepo.getWeeklyStats();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshStats() async {
    _todayStats = await _statsRepo.getTodayStats();
    notifyListeners();
  }

  Future<void> resetStatistics() async {
    await _statsRepo.resetAllStats();
    _todayStats = ProtectionStats(date: DateTime.now());
    _weeklyStats = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
