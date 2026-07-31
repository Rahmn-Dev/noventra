import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/item_provider.dart';
import '../models/item.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _todayIn = 0;
  int _todayOut = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final txs = await ref.read(itemProvider.notifier).getAllTransactionsForDashboard();
    final now = DateTime.now();
    int tIn = 0;
    int tOut = 0;
    for (var tx in txs) {
      if (tx.timestamp.year == now.year && tx.timestamp.month == now.month && tx.timestamp.day == now.day) {
        if (tx.delta > 0) tIn += tx.delta;
        if (tx.delta < 0) tOut += tx.delta.abs();
      }
    }
    if (mounted) {
      setState(() {
        _todayIn = tIn;
        _todayOut = tOut;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We can call _loadDashboardData() when items change, or just rely on Riverpod state
    // For simplicity, whenever build is called (e.g., coming back), we refresh the stats
    _loadDashboardData();
    
    final items = ref.watch(itemProvider);
    final totalItems = items.length;
    final totalStock = items.fold<int>(0, (sum, i) => sum + i.stock);
    
    // Low stock items (top 3)
    final lowStockItems = items.where((i) => i.stock <= 5).toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
    final topLowStock = lowStockItems.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Noventra - Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Riwayat Transaksi',
            onPressed: () => context.go('/history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard('Total Items', totalItems.toString(), Colors.teal.shade300, Icons.inventory_2),
                _buildStatCard('Total Stock', totalStock.toString(), Colors.orange.shade300, Icons.stacked_bar_chart),
                _buildStatCard('Masuk Hari Ini', '+$_todayIn', Colors.green.shade400, Icons.arrow_downward),
                _buildStatCard('Keluar Hari Ini', '-$_todayOut', Colors.red.shade400, Icons.arrow_upward),
              ],
            ),
            const SizedBox(height: 24),
            
            // Low Stock Warning
            if (topLowStock.isNotEmpty) ...[
              const Text('⚠️ Peringatan Stok Menipis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 8),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: topLowStock.map((item) => ListTile(
                    leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    title: Text(item.name),
                    trailing: Text('${item.stock} pcs', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    onTap: () => context.go('/item/${item.code}'),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text('Menu Utama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            _buildActionCard(
              title: 'Daftar Barang',
              icon: Icons.list_alt,
              color: Colors.blue.shade600,
              onTap: () => context.go('/list'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Barang Masuk',
              icon: Icons.add_box,
              color: Colors.green.shade600,
              onTap: () => context.go('/stock_in'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Barang Keluar',
              icon: Icons.remove_circle,
              color: Colors.red.shade600,
              onTap: () => context.go('/stock_out'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Input Barang Baru',
              icon: Icons.create_new_folder,
              color: Colors.purple.shade600,
              onTap: () => context.go('/add_item'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Report Barang',
              icon: Icons.picture_as_pdf,
              color: Colors.deepOrange.shade600,
              onTap: () => context.go('/report'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Barang'),
        onPressed: () => context.go('/scan'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: color.withValues(alpha: 0.4),
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, color.withValues(alpha: 0.05)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

