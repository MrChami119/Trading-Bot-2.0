import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xauusd_signal_app/models/price_data.dart';
import 'package:xauusd_signal_app/models/signal.dart';

class SignalProvider extends ChangeNotifier {
  final String _apiKey = 'PclETNLBK4cNhTCkHxYXrZAAQkbzFPAn'; // Your FMP API key
  List<PriceData> _priceData = [];
  List<Signal> _signals = [];
  bool _isLoading = false;
  String _error = '';
  Timer? _refreshTimer;

  List<PriceData> get priceData => _priceData;
  List<Signal> get signals => _signals;
  bool get isLoading => _isLoading;
  String get error => _error;

  Signal? get latestSignal => _signals.isNotEmpty ? _signals.first : null;

  SignalProvider() {
    fetchData();
    // Set up timer to refresh data every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Fetch XAU/USD hourly data from Financial Modeling Prep
      final response = await http.get(
        Uri.parse(
            'https://financialmodelingprep.com/api/v3/historical-chart/1hour/XAUUSD?apikey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          _priceData = data.map((item) {
            return PriceData(
              datetime: DateTime.parse(item['date']),
              open: item['open']?.toDouble() ?? 0.0,
              high: item['high']?.toDouble() ?? 0.0,
              low: item['low']?.toDouble() ?? 0.0,
              close: item['close']?.toDouble() ?? 0.0,
              volume: item['volume']?.toDouble() ?? 0.0,
            );
          }).toList();

          // Generate signals based on the price data
          _generateSignals();
        } else {
          _error = 'No data available from API';
        }
      } else {
        _error = 'Failed to fetch data: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _generateSignals() {
    if (_priceData.isEmpty) return;

    // Extract price data for technical analysis
    final List<double> closes = _priceData.map((e) => e.close).toList();
    final List<double> highs = _priceData.map((e) => e.high).toList();
    final List<double> lows = _priceData.map((e) => e.low).toList();
    final List<double> volumes = _priceData.map((e) => e.volume).toList();

    // Calculate technical indicators
    final ema9 = _calculateEMA(closes, 9);
    final ema21 = _calculateEMA(closes, 21);
    final rsi14 = _calculateRSI(closes, 14);
    final macd = _calculateMACD(closes, 12, 26, 9);
    final bb = _calculateBollingerBands(closes, 20, 2);

    // Clear previous signals
    _signals.clear();

    // Generate signals based on multiple indicators
    for (int i = 1; i < _priceData.length - 1; i++) {
      bool isBuySignal = false;
      bool isSellSignal = false;
      double signalStrength = 0;
      String reason = '';

      // EMA crossover
      if (i >= 21) {
        if (ema9[i - 1] < ema21[i - 1] && ema9[i] > ema21[i]) {
          isBuySignal = true;
          signalStrength += 0.3;
          reason += 'EMA9 crossed above EMA21. ';
        } else if (ema9[i - 1] > ema21[i - 1] && ema9[i] < ema21[i]) {
          isSellSignal = true;
          signalStrength += 0.3;
          reason += 'EMA9 crossed below EMA21. ';
        }
      }

      // RSI conditions
      if (i >= 14) {
        if (rsi14[i] < 30) {
          isBuySignal = true;
          signalStrength += 0.2;
          reason += 'RSI oversold (${rsi14[i].toStringAsFixed(2)}). ';
        } else if (rsi14[i] > 70) {
          isSellSignal = true;
          signalStrength += 0.2;
          reason += 'RSI overbought (${rsi14[i].toStringAsFixed(2)}). ';
        }
      }

      // MACD crossover
      if (i >= 33) {
        if (macd['macd']![i - 1] < macd['signal']![i - 1] &&
            macd['macd']![i] > macd['signal']![i]) {
          isBuySignal = true;
          signalStrength += 0.25;
          reason += 'MACD crossed above signal line. ';
        } else if (macd['macd']![i - 1] > macd['signal']![i - 1] &&
            macd['macd']![i] < macd['signal']![i]) {
          isSellSignal = true;
          signalStrength += 0.25;
          reason += 'MACD crossed below signal line. ';
        }
      }

      // Bollinger Bands
      if (i >= 20) {
        if (closes[i] <= bb['lower']![i] &&
            closes[i - 1] > bb['lower']![i - 1]) {
          isBuySignal = true;
          signalStrength += 0.15;
          reason += 'Price touched lower Bollinger Band. ';
        } else if (closes[i] >= bb['upper']![i] &&
            closes[i - 1] < bb['upper']![i - 1]) {
          isSellSignal = true;
          signalStrength += 0.15;
          reason += 'Price touched upper Bollinger Band. ';
        }
      }

      // Sharp price movements
      double priceChange = ((closes[i] - closes[i - 1]) / closes[i - 1]) * 100;
      if (priceChange > 0.5) {
        isBuySignal = true;
        signalStrength += 0.1;
        reason += 'Sharp price increase (${priceChange.toStringAsFixed(2)}%). ';
      } else if (priceChange < -0.5) {
        isSellSignal = true;
        signalStrength += 0.1;
        reason += 'Sharp price decrease (${priceChange.toStringAsFixed(2)}%). ';
      }

      // Volume confirmation
      if (volumes[i] > volumes[i - 1] * 1.5) {
        signalStrength += 0.1;
        reason += 'Volume spike confirmed. ';
      }

      // Only add signal if it's strong enough and there's a clear direction
      if ((isBuySignal && !isSellSignal) || (!isBuySignal && isSellSignal)) {
        if (signalStrength >= 0.4) {
          SignalType type = isBuySignal ? SignalType.buy : SignalType.sell;

          // Adjust confidence level based on signal strength
          ConfidenceLevel confidence = ConfidenceLevel.medium;
          if (signalStrength >= 0.7) {
            confidence = ConfidenceLevel.high;
          } else if (signalStrength < 0.5) {
            confidence = ConfidenceLevel.low;
          }

          _signals.add(Signal(
            type: type,
            confidence: confidence,
            price: _priceData[i].close,
            timestamp: _priceData[i].datetime,
            reason: reason.trim(),
          ));
        }
      }
    }

    // Sort signals by timestamp (newest first)
    _signals.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    notifyListeners();
  }

  // Helper methods for technical indicators (unchanged)
  List<double> _calculateEMA(List<double> data, int period) {
    List<double> ema = List.filled(data.length, 0);
    double multiplier = 2 / (period + 1);

    // Calculate SMA for the first EMA value
    double sum = 0;
    for (int i = 0; i < period; i++) {
      sum += data[i];
    }
    ema[period - 1] = sum / period;

    // Calculate EMA
    for (int i = period; i < data.length; i++) {
      ema[i] = (data[i] - ema[i - 1]) * multiplier + ema[i - 1];
    }

    return ema;
  }

  List<double> _calculateRSI(List<double> data, int period) {
    List<double> rsi = List.filled(data.length, 0);
    List<double> gains = List.filled(data.length, 0);
    List<double> losses = List.filled(data.length, 0);

    for (int i = 1; i < data.length; i++) {
      double difference = data[i] - data[i - 1];
      gains[i] = max(difference, 0);
      losses[i] = max(-difference, 0);
    }

    double avgGain =
        gains.sublist(1, period + 1).reduce((a, b) => a + b) / period;
    double avgLoss =
        losses.sublist(1, period + 1).reduce((a, b) => a + b) / period;

    for (int i = period; i < data.length; i++) {
      avgGain = (avgGain * (period - 1) + gains[i]) / period;
      avgLoss = (avgLoss * (period - 1) + losses[i]) / period;

      double rs = avgGain / avgLoss;
      rsi[i] = 100 - (100 / (1 + rs));
    }

    return rsi;
  }

  Map<String, List<double>> _calculateMACD(
      List<double> data, int fastPeriod, int slowPeriod, int signalPeriod) {
    List<double> fastEMA = _calculateEMA(data, fastPeriod);
    List<double> slowEMA = _calculateEMA(data, slowPeriod);
    List<double> macd = List.filled(data.length, 0);

    for (int i = 0; i < data.length; i++) {
      macd[i] = fastEMA[i] - slowEMA[i];
    }

    List<double> signal = _calculateEMA(macd, signalPeriod);
    List<double> histogram = List.filled(data.length, 0);

    for (int i = 0; i < data.length; i++) {
      histogram[i] = macd[i] - signal[i];
    }

    return {
      'macd': macd,
      'signal': signal,
      'histogram': histogram,
    };
  }

  Map<String, List<double>> _calculateBollingerBands(
      List<double> data, int period, double stdDev) {
    List<double> sma = List.filled(data.length, 0);
    List<double> upper = List.filled(data.length, 0);
    List<double> lower = List.filled(data.length, 0);

    for (int i = period - 1; i < data.length; i++) {
      double sum = 0;
      for (int j = 0; j < period; j++) {
        sum += data[i - j];
      }
      sma[i] = sum / period;

      double sumSquaredDiff = 0;
      for (int j = 0; j < period; j++) {
        sumSquaredDiff += pow(data[i - j] - sma[i], 2);
      }
      double standardDeviation = sqrt(sumSquaredDiff / period);

      upper[i] = sma[i] + (stdDev * standardDeviation);
      lower[i] = sma[i] - (stdDev * standardDeviation);
    }

    return {
      'upper': upper,
      'middle': sma,
      'lower': lower,
    };
  }
}