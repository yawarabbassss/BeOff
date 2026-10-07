import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/filter_list_meta.dart';
import '../../providers/filter_list_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';

class FilterHubScreen extends StatelessWidget {
  const FilterHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filterProvider = context.watch<FilterListProvider>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: const CustomAppBar(
        title: 'Filter Lists & Rules',
        subtitle: 'Manage community-tested blocking rules',
      ),
      body: filterProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Total Rule Summary Card
                CustomCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Filter Rules',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat.decimalPattern().format(filterProvider.totalRuleCount),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 26),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Community & Security Filter Lists',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                ...filterProvider.filterLists.map((list) {
                  final isUpdating = list.status == FilterListStatus.downloading;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CustomCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  list.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Switch(
                                value: list.isEnabled,
                                onChanged: (val) => filterProvider.toggleList(list.id, val),
                                activeColor: Colors.black,
                                activeTrackColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            list.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  StatusBadge(
                                    text: '${NumberFormat.compact().format(list.ruleCount)} rules',
                                    type: BadgeType.neutral,
                                  ),
                                  const SizedBox(width: 8),
                                  if (list.lastUpdatedAt != null)
                                    Text(
                                      'Updated ${dateFormat.format(list.lastUpdatedAt!)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                                    ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: isUpdating ? null : () => filterProvider.updateList(list.id),
                                icon: isUpdating
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.sync_rounded, size: 16),
                                label: Text(isUpdating ? 'Updating...' : 'Update'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
