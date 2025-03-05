import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:xauusd_signal_app/providers/signal_provider.dart';
import 'package:xauusd_signal_app/providers/theme_provider.dart';
import 'package:xauusd_signal_app/widgets/price_chart.dart'; // Ensure this import is correct
import 'package:xauusd_signal_app/widgets/signal_card.dart';
import 'package:xauusd_signal_app/widgets/signal_history.dart';
import 'package:xauusd_signal_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signalProvider = Provider.of<SignalProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: theme.primaryColor,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'XAUUSD Signal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Current price and refresh button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Price',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        signalProvider.priceData.isNotEmpty
                            ? '\$${signalProvider.priceData.first.close.toStringAsFixed(2)}'
                            : 'Loading...',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: signalProvider.isLoading
                        ? null
                        : () => signalProvider.fetchData(),
                    icon: signalProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(signalProvider.isLoading ? 'Updating' : 'Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            
            // Last updated time
            if (signalProvider.priceData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last updated: ${DateFormat('MMM dd, yyyy HH:mm').format(signalProvider.priceData.first.datetime)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'SIGNALS'),
                Tab(text: 'CHART'),
              ],
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              indicatorColor: theme.primaryColor,
            ),
            
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Signals tab
                  signalProvider.isLoading && signalProvider.signals.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : signalProvider.error.isNotEmpty
                          ? Center(
                              child: Text(
                                'Error: ${signalProvider.error}',
                                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : signalProvider.signals.isEmpty
                              ? Center(
                                  child: Text(
                                    'No signals available yet.\nPull to refresh.',
                                    style: theme.textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: signalProvider.fetchData,
                                  child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      // Latest signal
                                      if (signalProvider.latestSignal != null)
                                        SignalCard(
                                          signal: signalProvider.latestSignal!,
                                          isLatest: true,
                                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Signal history
                                      Text(
                                        'Signal History',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SignalHistory(
                                        signals: signalProvider.signals.skip(1).toList(),
                                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                                    ],
                                  ),
                                ),
                  
                  // Chart tab
                  signalProvider.isLoading && signalProvider.priceData.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : signalProvider.error.isNotEmpty
                          ? Center(
                              child: Text(
                                'Error: ${signalProvider.error}',
                                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : signalProvider.priceData.isEmpty
                              ? Center(
                                  child: Text(
                                    'No price data available yet.\nPull to refresh.',
                                    style: theme.textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: signalProvider.fetchData,
                                  child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      PriceChart( // Ensure this is used as a widget
                                        priceData: signalProvider.priceData,
                                        signals: signalProvider.signals,
                                      ),
                                    ],
                                  ),
                                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

