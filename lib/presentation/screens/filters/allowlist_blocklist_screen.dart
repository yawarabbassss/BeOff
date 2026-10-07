import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/block_entry.dart';
import '../../providers/filter_list_provider.dart';
import '../../widgets/confirmation_modal.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';

class AllowlistBlocklistScreen extends StatefulWidget {
  const AllowlistBlocklistScreen({super.key});

  @override
  State<AllowlistBlocklistScreen> createState() => _AllowlistBlocklistScreenState();
}

class _AllowlistBlocklistScreenState extends State<AllowlistBlocklistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddDialog(BuildContext context, {required bool isAllowlist}) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isAllowlist ? 'Allow Website / Domain' : 'Block Website / Domain',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAllowlist
                  ? 'Traffic to this domain will bypass all ad/tracker filters.'
                  : 'All network requests to this domain will be sinkholed locally.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. example.com',
                prefixIcon: Icon(
                  isAllowlist ? Icons.check_circle_outline : Icons.block,
                  color: isAllowlist ? AppColors.primary : AppColors.danger,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAllowlist ? AppColors.primary : AppColors.danger,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final domain = textController.text.trim();
              if (domain.isNotEmpty) {
                final provider = context.read<FilterListProvider>();
                if (isAllowlist) {
                  provider.addAllowlistDomain(domain);
                } else {
                  provider.addBlocklistDomain(domain);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add Rule'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FilterListProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: CustomAppBar(
        title: 'Allow & Block Rules',
        subtitle: 'Custom domain rules configured by you',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 26, color: AppColors.primary),
            onPressed: () => _showAddDialog(
              context,
              isAllowlist: _tabController.index == 0,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search custom rules...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textMutedDark),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryDark,
            tabs: [
              Tab(text: 'Allowlist (${provider.allowlist.length})'),
              Tab(text: 'Custom Blocklist (${provider.blocklist.length})'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(provider.allowlist, isAllowlist: true),
                _buildList(provider.blocklist, isAllowlist: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Rule', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showAddDialog(
          context,
          isAllowlist: _tabController.index == 0,
        ),
      ),
    );
  }

  Widget _buildList(List<BlockEntry> entries, {required bool isAllowlist}) {
    final filtered = entries
        .where((e) => e.domain.toLowerCase().contains(_searchQuery))
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAllowlist ? Icons.check_circle_outline : Icons.block,
              size: 48,
              color: AppColors.textMutedDark,
            ),
            const SizedBox(height: 12),
            Text(
              isAllowlist ? 'No allowlisted domains' : 'No custom blocked domains',
              style: const TextStyle(fontSize: 15, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 4),
            Text(
              isAllowlist
                  ? 'Add domains that should bypass filtering'
                  : 'Add domains you want BeOff to strictly block',
              style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: filtered.length,
      itemBuilder: (ctx, idx) {
        final entry = filtered[idx];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CustomCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isAllowlist ? Icons.check_circle_rounded : Icons.block_flipped,
                  size: 20,
                  color: isAllowlist ? AppColors.primary : AppColors.danger,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.domain,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Added ${entry.addedAt.toIso8601String().split('T').first}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  onPressed: () async {
                    final confirm = await ConfirmationModal.show(
                      context,
                      title: 'Delete Rule',
                      message: 'Are you sure you want to remove ${entry.domain}?',
                      confirmText: 'Remove',
                      isDangerous: true,
                    );
                    if (confirm == true && mounted) {
                      context.read<FilterListProvider>().removeDomain(entry.domain);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
