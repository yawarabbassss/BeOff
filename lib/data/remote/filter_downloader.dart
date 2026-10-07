import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/logger.dart';
import '../../domain/models/filter_list_meta.dart';

class FilterDownloader {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
    ),
  );

  /// Downloads or loads filter list rules.
  /// If network update fails, falls back gracefully to local cached file or bundled asset.
  Future<List<String>> loadFilterRules(FilterListMeta meta) async {
    try {
      final cacheFile = await _getLocalCacheFile(meta.id);

      // If cached file exists, read from cache first
      if (await cacheFile.exists()) {
        final content = await cacheFile.readAsString();
        return _extractRulesFromContent(content);
      }

      // If no cache, load bundled asset
      if (meta.localAssetPath.isNotEmpty) {
        final assetContent = await rootBundle.loadString(meta.localAssetPath);
        return _extractRulesFromContent(assetContent);
      }
    } catch (e) {
      AppLogger.warn('Error reading local filter asset for ${meta.id}: $e');
    }

    return [];
  }

  /// Downloads fresh filter list from remote URL and updates local cache
  Future<int> updateFilterList(FilterListMeta meta) async {
    if (meta.url.isEmpty) return meta.ruleCount;

    try {
      AppLogger.info('Updating filter list: ${meta.name} from ${meta.url}', 'FilterDownloader');
      final response = await _dio.get<String>(meta.url);

      if (response.statusCode == 200 && response.data != null) {
        final content = response.data!;
        final rules = _extractRulesFromContent(content);

        // Cache to device storage
        final cacheFile = await _getLocalCacheFile(meta.id);
        await cacheFile.writeAsString(content, flush: true);

        AppLogger.info('Filter list ${meta.id} updated with ${rules.length} rules.', 'FilterDownloader');
        return rules.length;
      }
    } catch (e) {
      AppLogger.warn('Failed to download update for ${meta.id}, retaining cached version: $e');
    }

    return meta.ruleCount;
  }

  List<String> _extractRulesFromContent(String content) {
    return content
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('!') && !line.startsWith('#'))
        .toList();
  }

  Future<File> _getLocalCacheFile(String listId) async {
    final dir = await getApplicationDocumentsDirectory();
    final filterDir = Directory('${dir.path}/filters');
    if (!await filterDir.exists()) {
      await filterDir.create(recursive: true);
    }
    return File('${filterDir.path}/$listId.txt');
  }
}
