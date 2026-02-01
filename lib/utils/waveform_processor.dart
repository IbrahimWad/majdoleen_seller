import 'dart:math';
import 'dart:typed_data';

class WaveformProcessor {
  static const int _sampleRate = 44100;
  static const double _silenceThreshold = 0.01; // Adjust based on testing
  static const int _smoothingWindow = 3; // Number of samples to average

  // Store recent amplitude values for smoothing
  final List<double> _recentAmplitudes = [];
  double _maxAmplitude = 0.0;

  // Process raw audio data and return normalized amplitude (0.0 to 1.0)
  double processAudioData(Uint8List data) {
    if (data.isEmpty) return 0.0;

    // Convert bytes to 16-bit PCM samples (assuming 16-bit audio)
    final samples = <int>[];
    for (int i = 0; i < data.length - 1; i += 2) {
      // Convert little-endian 16-bit
      int sample = data[i] | (data[i + 1] << 8);
      if (sample >= 32768) sample -= 65536; // Convert to signed
      samples.add(sample);
    }

    if (samples.isEmpty) return 0.0;

    // Calculate RMS (Root Mean Square) for better amplitude representation
    double sumSquares = 0.0;
    for (int sample in samples) {
      double normalizedSample = sample / 32768.0; // Normalize to -1.0 to 1.0
      sumSquares += normalizedSample * normalizedSample;
    }
    double rms = sqrt(sumSquares / samples.length);

    // Apply silence threshold
    if (rms < _silenceThreshold) {
      rms = 0.0;
    }

    // Add to recent amplitudes for smoothing
    _recentAmplitudes.add(rms);
    if (_recentAmplitudes.length > _smoothingWindow) {
      _recentAmplitudes.removeAt(0);
    }

    // Calculate smoothed amplitude
    double smoothedAmplitude = _recentAmplitudes.reduce((a, b) => a + b) / _recentAmplitudes.length;

    // Update max amplitude for normalization
    if (smoothedAmplitude > _maxAmplitude) {
      _maxAmplitude = smoothedAmplitude;
    }

    // Normalize to 0.0-1.0 range, with a minimum floor for visibility
    double normalizedAmplitude = _maxAmplitude > 0 ? smoothedAmplitude / _maxAmplitude : 0.0;

    // Apply a minimum height for very quiet sounds and ensure some visual feedback
    normalizedAmplitude = max(0.05, min(1.0, normalizedAmplitude));

    // Apply logarithmic scaling for better visual representation (like human hearing)
    if (normalizedAmplitude > 0) {
      normalizedAmplitude = log(normalizedAmplitude * 9 + 1) / log(10);
    }

    return normalizedAmplitude;
  }

  // Reset the processor state (useful for new recordings)
  void reset() {
    _recentAmplitudes.clear();
    _maxAmplitude = 0.0;
  }

  // Get the current max amplitude for reference
  double get maxAmplitude => _maxAmplitude;
}