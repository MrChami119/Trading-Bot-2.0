import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xauusd_signal_app/models/signal.dart';

class SignalHistory extends StatelessWidget {
  final List<Signal> signals;
  
  const SignalHistory({
    Key? key,
    required this.signals,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (signals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No previous signals available',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: signals.length,
      itemBuilder: (context, index) {
        final signal = signals[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.dividerColor.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: signal.typeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                signal.type == SignalType.buy
                    ? Icons.trending_up
                    : Icons.trending_down,
                color: signal.typeColor,
              ),
            ),
            title: Row(
              children: [
                Text(
                  signal.typeString,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: signal.typeColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
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
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '\$${signal.price.toStringAsFixed(2)} • ${DateFormat('MMM dd, HH:mm').format(signal.timestamp)}',
                style: theme.textTheme.bodySmall,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: signal.typeColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            signal.type == SignalType.buy
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: signal.typeColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${signal.typeString} Signal',
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Price', '\$${signal.price.toStringAsFixed(2)}'),
                        _buildInfoRow('Time', DateFormat('MMM dd, yyyy HH:mm').format(signal.timestamp)),
                        _buildInfoRow('Confidence', signal.confidenceString),
                        const SizedBox(height: 16),
                        Text(
                          'Signal Analysis',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(signal.reason),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

