import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xauusd_signal_app/models/signal.dart';

class SignalCard extends StatelessWidget {
  final Signal signal;
  final bool isLatest;
  
  const SignalCard({
    Key? key,
    required this.signal,
    this.isLatest = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: isLatest ? 4 : 1,
      shadowColor: isLatest ? signal.typeColor.withOpacity(0.3) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isLatest
            ? BorderSide(color: signal.typeColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Signal header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: signal.typeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        signal.typeString,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.dividerColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            signal.confidence == ConfidenceLevel.high
                                ? Icons.sentiment_very_satisfied
                                : signal.confidence == ConfidenceLevel.medium
                                    ? Icons.sentiment_satisfied
                                    : Icons.sentiment_neutral,
                            size: 16,
                            color: signal.confidence == ConfidenceLevel.high
                                ? Colors.green
                                : signal.confidence == ConfidenceLevel.medium
                                    ? Colors.amber
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            signal.confidenceString,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isLatest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'LATEST',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Price and time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${signal.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, HH:mm').format(signal.timestamp),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
            
            if (isLatest) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Signal reasoning
              Text(
                'Signal Analysis',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                signal.reason,
                style: theme.textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 16),
              
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement action (e.g., set alert, save signal)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Signal saved'),
                        backgroundColor: signal.typeColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signal.typeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    signal.type == SignalType.buy ? 'TRACK BUY SIGNAL' : 'TRACK SELL SIGNAL',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

