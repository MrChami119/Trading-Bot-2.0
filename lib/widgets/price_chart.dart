import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'package:intl/intl.dart';
import 'package:xauusd_signal_app/models/price_data.dart';
import 'package:xauusd_signal_app/models/signal.dart';
import 'package:xauusd_signal_app/providers/theme_provider.dart';

class PriceChart extends StatefulWidget {
  final List<PriceData> priceData;
  final List<Signal> signals;
  
  const PriceChart({
    Key? key,
    required this.priceData,
    required this.signals,
  }) : super(key: key);

  @override
  State<PriceChart> createState() => _PriceChartState();
}

class _PriceChartState extends State<PriceChart> {
  bool _showEMA9 = true;
  bool _showEMA21 = true;
  bool _showSignals = true;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Convert price data to candle format
    final candles = widget.priceData.map((data) {
      return Candle(
        date: data.datetime,
        high: data.high,
        low: data.low,
        open: data.open,
        close: data.close,
        volume: data.volume,
      );
    }).toList();
    
    // Reverse the list to show oldest data first (required by the chart)
    final reversedCandles = candles.reversed.toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart controls
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip(
              label: 'EMA 9',
              selected: _showEMA9,
              onSelected: (value) {
                setState(() {
                  _showEMA9 = value;
                });
              },
            ),
            _buildFilterChip(
              label: 'EMA 21',
              selected: _showEMA21,
              onSelected: (value) {
                setState(() {
                  _showEMA21 = value;
                });
              },
            ),
            _buildFilterChip(
              label: 'Signals',
              selected: _showSignals,
              onSelected: (value) {
                setState(() {
                  _showSignals = value;
                });
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Chart
        Container(
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.2),
            ),
          ),
          child: Candlesticks(
            candles: reversedCandles,
            // Remove the 'indicators' parameter as it's not supported in this version
            actions: [
              ToolBarAction(
                onPressed: () {},
                child: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Signal markers on chart
        if (_showSignals && widget.signals.isNotEmpty) ...[
          Text(
            'Signal Markers',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Signal legend
          Row(
            children: [
              _buildSignalLegendItem(
                color: ThemeProvider.accentGreen,
                label: 'Buy Signal',
              ),
              const SizedBox(width: 16),
              _buildSignalLegendItem(
                color: ThemeProvider.accentRed,
                label: 'Sell Signal',
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Signal list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.signals.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final signal = widget.signals[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: signal.typeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    signal.type == SignalType.buy
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: signal.typeColor,
                  ),
                ),
                title: Text(
                  '${signal.typeString} at \$${signal.price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(signal.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    signal.confidenceString,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: theme.primaryColor.withOpacity(0.2),
      checkmarkColor: theme.primaryColor,
      labelStyle: TextStyle(
        color: selected ? theme.primaryColor : theme.textTheme.bodyMedium?.color,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
  
  Widget _buildSignalLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

