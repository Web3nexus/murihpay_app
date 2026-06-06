import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/glass_card.dart';
import '../../providers.dart';

final _giftCardCatalogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final client = ref.read(apiClientProvider);
  final raw = await client.get('/giftcards/catalog');
  return (raw.data['data'] as List? ?? []).cast<Map<String, dynamic>>();
});

class GiftCardsScreen extends ConsumerWidget {
  const GiftCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogAsync = ref.watch(_giftCardCatalogProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Gift Cards'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Gift Cards', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('Send the perfect gift', style: TextStyle(
                          fontSize: 13, color: Colors.white.withAlpha(200))),
                      ],
                    ),
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Popular Brands', style: AppTypography.h4),
            const SizedBox(height: 12),
            catalogAsync.when(
              data: (items) => items.isEmpty
                  ? _emptyBrands()
                  : _buildGrid(items),
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, __) => _emptyBrands(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyBrands() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.card_giftcard_rounded, size: 48, color: AppColors.lightGray.withAlpha(100)),
          const SizedBox(height: 12),
          Text('No gift cards available', style: AppTypography.body.copyWith(color: AppColors.lightGray)),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final name = item['name']?.toString() ?? 'Brand';
        final minP = item['min_price'] ?? item['range'] ?? '\$5';
        final icon = item['icon']?.toString() ?? '';
        return GlassCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.card_giftcard, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(name, style: AppTypography.bodySemibold.copyWith(fontSize: 12),
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(minP.toString(),
                style: AppTypography.caption.copyWith(color: AppColors.charcoalGray)),
            ],
          ),
        );
      },
    );
  }
}
