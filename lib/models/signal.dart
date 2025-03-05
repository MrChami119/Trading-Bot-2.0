import 'package:flutter/material.dart';

enum SignalType { buy, sell }

enum ConfidenceLevel { low, medium, high }

class Signal {
  final SignalType type;
  final ConfidenceLevel confidence;
  final double price;
  final DateTime timestamp;
  final String reason;
  
  Signal({
    required this.type,
    required this.confidence,
    required this.price,
    required this.timestamp,
    required this.reason,
  });
  
  String get typeString => type == SignalType.buy ? 'BUY' : 'SELL';
  
  String get confidenceString {
    switch (confidence) {
      case ConfidenceLevel.low:
        return 'Low';
      case ConfidenceLevel.medium:
        return 'Medium';
      case ConfidenceLevel.high:
        return 'High';
      default:
        return 'Unknown';
    }
  }
  
  Color get typeColor {
    return type == SignalType.buy 
        ? const Color(0xFF2ECC71) // Green for buy
        : const Color(0xFFE74C3C); // Red for sell
  }
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'confidence': confidence.toString(),
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
    };
  }
}

