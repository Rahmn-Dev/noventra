import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/item_detail_screen.dart';
import 'screens/item_list_page.dart';
import 'screens/stock_in_page.dart';
import 'screens/stock_out_page.dart';
import 'screens/add_item_page.dart';
import 'screens/report_page.dart';
import 'screens/history_page.dart';

void main() {
  runApp(const ProviderScope(child: NoventraApp()));
}

class NoventraApp extends ConsumerWidget {
  const NoventraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/scan', builder: (context, state) => const ScanScreen()),
        GoRoute(path: '/item/:code', builder: (context, state) {
          final code = state.pathParameters['code']!;
          return ItemDetailScreen(itemCode: code);
        }),
        GoRoute(path: '/list', builder: (_, __) => const ItemListPage()),
        GoRoute(path: '/stock_in', builder: (_, __) => const StockInPage()),
        GoRoute(path: '/stock_out', builder: (_, __) => const StockOutPage()),
        GoRoute(path: '/add_item', builder: (_, __) => const AddItemPage()),
        GoRoute(path: '/report', builder: (_, __) => const ReportPage()),
        GoRoute(path: '/history', builder: (_, __) => const HistoryPage()),
      ],
    );
    return MaterialApp.router(
      title: 'Noventra',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
