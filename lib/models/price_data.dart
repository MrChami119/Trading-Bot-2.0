class PriceData {
  final DateTime datetime;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  
  PriceData({
    required this.datetime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'datetime': datetime.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }
  
  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      datetime: DateTime.parse(json['datetime']),
      open: json['open'],
      high: json['high'],
      low: json['low'],
      close: json['close'],
      volume: json['volume'],
    );
  }
}

