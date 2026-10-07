import 'package:flutter/foundation.dart';
import '../../data/repositories/filter_repository.dart';
import '../../domain/models/block_entry.dart';
import '../../domain/models/filter_list_meta.dart';
import '../../engines/protection_manager.dart';

class FilterListProvider extends ChangeNotifier {
  final FilterRepository _filterRepo;
  final ProtectionManager _protectionManager;

  List<FilterListMeta> _filterLists = [];
  List<BlockEntry> _allowlist = [];
  List<BlockEntry> _blocklist = [];
  bool _isLoading = false;

  FilterListProvider(this._filterRepo, this._protectionManager) {
    loadAll();
  }

  List<FilterListMeta> get filterLists => _filterLists;
  List<BlockEntry> get allowlist => _allowlist;
  List<BlockEntry> get blocklist => _blocklist;
  bool get isLoading => _isLoading;

  int get totalRuleCount =>
      _filterLists.where((l) => l.isEnabled).fold(0, (sum, l) => sum + l.ruleCount);

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    _filterLists = await _filterRepo.loadFilterLists();
    _allowlist = await _filterRepo.getAllowlist();
    _blocklist = await _filterRepo.getBlocklist();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleList(String listId, bool enabled) async {
    _filterLists = _filterLists.map((l) {
      if (l.id == listId) {
        return l.copyWith(isEnabled: enabled);
      }
      return l;
    }).toList();

    await _filterRepo.saveFilterLists(_filterLists);
    await _protectionManager.initialize();
    notifyListeners();
  }

  Future<void> updateList(String listId) async {
    final index = _filterLists.indexWhere((l) => l.id == listId);
    if (index == -1) return;

    _filterLists[index] = _filterLists[index].copyWith(status: FilterListStatus.downloading);
    notifyListeners();

    final updated = await _filterRepo.updateList(_filterLists[index]);
    _filterLists[index] = updated;
    await _protectionManager.initialize();
    notifyListeners();
  }

  Future<void> addAllowlistDomain(String domain) async {
    await _protectionManager.allowDomain(domain);
    _allowlist = await _filterRepo.getAllowlist();
    _blocklist = await _filterRepo.getBlocklist();
    notifyListeners();
  }

  Future<void> addBlocklistDomain(String domain) async {
    await _protectionManager.blockDomain(domain);
    _allowlist = await _filterRepo.getAllowlist();
    _blocklist = await _filterRepo.getBlocklist();
    notifyListeners();
  }

  Future<void> removeDomain(String domain) async {
    await _protectionManager.removeDomainRule(domain);
    _allowlist = await _filterRepo.getAllowlist();
    _blocklist = await _filterRepo.getBlocklist();
    notifyListeners();
  }
}
