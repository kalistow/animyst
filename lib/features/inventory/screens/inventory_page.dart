import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui'; // Glassmorphism

import '../../../core/models/user_card.dart';
import '../../../core/enums/enums.dart'; // Rarity
import '../controllers/inventory_controller.dart';
import '../widgets/inventory_card_item.dart';
import '../widgets/card_sell_dialog.dart';
import '../../../core/providers/auth_provider.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryControllerProvider);
    final selectionState = ref.watch(inventorySelectionProvider);
    final isSelectionMode = selectionState.isSelectionMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('NEURAL ARCHIVE'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: Icon(isSelectionMode ? Icons.close : Icons.edit, 
              color: isSelectionMode ? Colors.redAccent : Colors.white),
            label: Text(
              isSelectionMode ? 'CANCEL' : 'MANAGE',
              style: TextStyle(
                color: isSelectionMode ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
            onPressed: () {
              ref.read(inventorySelectionProvider.notifier).toggleSelectionMode();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: inventoryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          data: (cards) {
            if (cards.isEmpty) {
              return const Center(child: Text("Archive Empty", style: TextStyle(color: Colors.white54, letterSpacing: 2)));
            }

            return SafeArea(
              child: CustomScrollView(
                slivers: [
                   _buildRaritySection(context, cards, Rarity.ultraRare, "ULTRA RARE", Colors.amber),
                   _buildRaritySection(context, cards, Rarity.superRare, "SUPER RARE", Colors.purple),
                   _buildRaritySection(context, cards, Rarity.rare, "RARE", Colors.blue),
                   _buildRaritySection(context, cards, Rarity.elite, "ELITE", Colors.green),
                   _buildRaritySection(context, cards, Rarity.normal, "NORMAL", Colors.grey),
                   const SliverPadding(padding: EdgeInsets.only(bottom: 100)), // Space for FAB
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: isSelectionMode ? _buildBottomAction(selectionState.selectedIds) : null,
    );
  }

  Widget _buildRaritySection(BuildContext context, List<UserCard> allCards, Rarity rarity, String title, Color color) {
    // Filter cards by rarity
    final cards = allCards.where((c) => c.card?.rarity == rarity).toList();
    
    if (cards.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverMainAxisGroup(
       slivers: [
         // Header
         SliverToBoxAdapter(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
             child: Row(
               children: [
                 Container(width: 4, height: 24, color: color),
                 const SizedBox(width: 8),
                 Text(
                   title,
                   style: TextStyle(
                     color: color, 
                     fontWeight: FontWeight.bold, 
                     letterSpacing: 1.5,
                     fontSize: 16,
                     shadows: [BoxShadow(color: color, blurRadius: 10)]
                   ),
                 ),
                 const Spacer(),
                 // Select All Button if in Selection Mode
                 Consumer(builder: (context, ref, child) {
                    final selState = ref.watch(inventorySelectionProvider);
                    if (selState.isSelectionMode) {
                      return TextButton(
                        onPressed: () {
                           ref.read(inventorySelectionProvider.notifier).selectAllByRarity(allCards, rarity);
                        },
                        child: Text("Select All", style: TextStyle(color: color.withOpacity(0.8), fontSize: 12)),
                      );
                    }
                    return const SizedBox.shrink();
                 }),
               ],
             ),
           ),
          ),

         // --- COLLECTION OBJECTIVE (ULTRA RARE ONLY) ---
         if (rarity == Rarity.ultraRare)
           SliverToBoxAdapter(
             child: Consumer(
               builder: (ctx, ref, _) {
                 final hasClaimedFuture = ref.read(inventoryControllerProvider.notifier).hasClaimedUrReward();
                 
                 return FutureBuilder<bool>(
                   future: hasClaimedFuture,
                   builder: (context, snapshot) {
                     final claimed = snapshot.data ?? false;
                     final uniqueCount = cards.length;
                     final target = 5;
                     final progress = (uniqueCount / target).clamp(0.0, 1.0);
                     final canClaim = uniqueCount >= target && !claimed;
                     
                     return Container(
                       margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                       padding: const EdgeInsets.all(16),
                       decoration: BoxDecoration(
                         gradient: LinearGradient(
                           colors: claimed 
                             ? [Colors.green.withOpacity(0.2), Colors.black]
                             : [Colors.amber.withOpacity(0.2), Colors.black],
                         ),
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(
                           color: claimed ? Colors.green : Colors.amber, 
                           width: 1
                         ),
                       ),
                       child: Row(
                         children: [
                           // Icon & Text
                           Container(
                             padding: const EdgeInsets.all(8),
                             decoration: BoxDecoration(
                               color: Colors.black45,
                               shape: BoxShape.circle,
                               border: Border.all(color: claimed ? Colors.green : Colors.amber),
                             ),
                             child: Icon(
                               claimed ? Icons.check : Icons.military_tech,
                               color: claimed ? Colors.green : Colors.amber,
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                  Text(
                                   claimed ? "COLLECTION COMPLETED" : "COLLECT 5 ULTRA RARE",
                                   style: const TextStyle(
                                     color: Colors.white, 
                                     fontWeight: FontWeight.bold,
                                     fontSize: 14
                                   ),
                                 ),
                                 const SizedBox(height: 8),
                                 if (!claimed)
                                   ClipRRect(
                                     borderRadius: BorderRadius.circular(4),
                                     child: LinearProgressIndicator(
                                       value: progress,
                                       backgroundColor: Colors.white10,
                                       valueColor: const AlwaysStoppedAnimation(Colors.amber),
                                       minHeight: 6,
                                     ),
                                   ),
                                 if (!claimed)
                                   Padding(
                                     padding: const EdgeInsets.only(top: 4),
                                     child: Text(
                                       "$uniqueCount / $target Collected",
                                       style: const TextStyle(color: Colors.amberAccent, fontSize: 10),
                                     ),
                                   ),
                               ],
                             ),
                           ),
                           const SizedBox(width: 16),
                           
                           // Claim Button (or Checkmark)
                           if (claimed)
                             const Chip(
                               label: Text("CLAIMED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                               backgroundColor: Colors.green,
                               labelPadding: EdgeInsets.symmetric(horizontal: 4),
                             )
                           else
                             ElevatedButton(
                               onPressed: canClaim 
                                   ? () async {
                                       final success = await ref.read(inventoryControllerProvider.notifier).claimUrReward();
                                       if (success && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("🎉 REWARD CLAIMED: 1000 GEMS!")),
                                          );
                                          // Rebuild logic will happen due to profile refresh
                                          // To force UI update immediately on this widget, we might strictly need setState or Stream
                                          // But profile refresh should trigger inventory refresh if structured correctly.
                                          // For now, simple Snackbar is enough affirmation.
                                          (context as Element).markNeedsBuild(); // Quick dirty refresh
                                       }
                                     } 
                                   : null,
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: canClaim ? Colors.amber : Colors.grey[800],
                                 foregroundColor: canClaim ? Colors.black : Colors.white24,
                               ),
                               child: const Text("SECRET GIFT"),
                             ),
                         ],
                       ),
                     );
                   },
                 );
               },
             ),
           ),



         // --- DUST EXCHANGE (ULTRA RARE ONLY) ---
         if (rarity == Rarity.ultraRare)
           SliverToBoxAdapter(
             child: Consumer(
               builder: (ctx, ref, _) {
                 final profile = ref.watch(currentProfileProvider);
                 final dust = profile?.dust ?? 0;
                 final canExchange = dust >= 250;

                 return Container(
                   margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   decoration: BoxDecoration(
                     gradient: LinearGradient(colors: [Colors.cyan.withOpacity(0.1), Colors.purple.withOpacity(0.1)]),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                   ),
                   child: Row(
                     children: [
                        const Icon(Icons.cached, color: Colors.cyanAccent),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("MATTER CONVERSION", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                              SizedBox(height: 2),
                              Text("250 DUST  ➔  100 GEMS", style: TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canExchange 
                            ? () async {
                              final success = await ref.read(inventoryControllerProvider.notifier).exchangeDustForGems(250, 100);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Conversion Successful! +100 Gems"), backgroundColor: Colors.cyan));
                              }
                            } 
                            : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan.withOpacity(0.2),
                            foregroundColor: Colors.cyanAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("CONVERT"),
                        )
                     ],
                   ),
                 );
               }
             )
           ),

         // Grid
         SliverPadding(
           padding: const EdgeInsets.symmetric(horizontal: 16),
           sliver: SliverGrid(
             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
               crossAxisCount: 3,
               childAspectRatio: 0.7,
               crossAxisSpacing: 10,
               mainAxisSpacing: 10,
             ),
             delegate: SliverChildBuilderDelegate(
               (context, index) {
                 final userCard = cards[index];
                 return Consumer(
                   builder: (context, ref, child) {
                     final selState = ref.watch(inventorySelectionProvider);
                     final isSelected = selState.selectedIds.contains(userCard.id);
                     final isMode = selState.isSelectionMode;

                     return InventoryCardItem(
                       userCard: userCard,
                       isSelectionMode: isMode,
                       isSelected: isSelected,
                       onTap: () {
                         if (isMode) {
                           ref.read(inventorySelectionProvider.notifier).toggleCardSelection(userCard.id);
                         } else {
                           // Open Details (Normal Mode)
                           _showCardDetails(context, userCard);
                         }
                       },
                     ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.2, end: 0);
                   },
                 );
               },
               childCount: cards.length,
             ),
           ),
         ),
       ],
    );
  }

  Widget _buildBottomAction(Set<String> selectedIds) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Text(
              '${selectedIds.length} ITEMS SELECTED',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedIds.isEmpty 
                  ? null 
                  : () => _performBulkSell(selectedIds),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('SELL'),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms);
  }

  void _showCardDetails(BuildContext context, UserCard userCard) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => CardSellDialog(userCard: userCard),
    );
  }

  Future<void> _performBulkSell(Set<String> ids) async {
    final count = ids.length;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bulk Recycle'),
        content: Text('Are you sure you want to recycle $count items? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Recycle All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dust = await ref.read(inventoryControllerProvider.notifier).sellSelectedCards(ids);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
             content: Text('♻️ Recycled $count items for $dust Dust!'),
             backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}