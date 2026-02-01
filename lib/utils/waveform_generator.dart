import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

class WaveformGenerator {
  static const int _targetBars = 20; // Number of bars to display in waveform

  // Generate waveform data from recorded audio chunks (during recording)
  static List<double> generateFromChunks(List<Uint8List> chunks, {int targetBars = _targetBars}) {
    if (chunks.isEmpty) return _generateDefaultWaveform(targetBars);

    final allData = chunks.expand((chunk) => chunk).toList();
    return _processAudioData(allData, targetBars);
  }

  // Generate waveform data from saved audio file (for message bubbles)
  static Future<List<double>> generateFromFile(String filePath, {int targetBars = _targetBars}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return _generateDefaultWaveform(targetBars);

      final bytes = await file.readAsBytes();
      return _processAudioData(bytes, targetBars);
    } catch (e) {
      print('Error generating waveform from file: $e');
      return _generateDefaultWaveform(targetBars);
    }
  }

  // Process raw audio data to extract amplitude samples
  static List<double> _processAudioData(List<int> audioData, int targetBars) {
    if (audioData.isEmpty) return _generateDefaultWaveform(targetBars);

    final samples = <int>[];

    // Convert bytes to 16-bit PCM samples (assuming WAV format)
    for (int i = 44; i < audioData.length - 1; i += 2) { // Skip WAV header (44 bytes)
      if (i + 1 < audioData.length) {
        int sample = audioData[i] | (audioData[i + 1] << 8);
        if (sample >= 32768) sample -= 65536; // Convert to signed
        samples.add(sample);
      }
    }

    if (samples.isEmpty) return _generateDefaultWaveform(targetBars);

    // Calculate RMS amplitude for each segment
    final segmentSize = max(1, samples.length ~/ targetBars);
    final amplitudes = <double>[];

    for (int i = 0; i < samples.length; i += segmentSize) {
      final end = min(i + segmentSize, samples.length);
      final segment = samples.sublist(i, end);

      // Calculate RMS
      double sumSquares = 0.0;
      for (int sample in segment) {
        double normalized = sample / 32768.0;
        sumSquares += normalized * normalized;
      }
      double rms = sqrt(sumSquares / segment.length);

      // Apply silence threshold and normalization
      rms = max(0.01, min(1.0, rms)); // Minimum 1% height

      // Apply logarithmic scaling for better visual representation
      if (rms > 0) {
        rms = log(rms * 9 + 1) / log(10);
      }

      amplitudes.add(rms);
    }

    // Ensure we have exactly targetBars
    final resultAmplitudes = <double>[...amplitudes];
    while (resultAmplitudes.length < targetBars) {
      resultAmplitudes.add(0.05); // Add small default bars
    }

    if (resultAmplitudes.length > targetBars) {
      return resultAmplitudes.sublist(0, targetBars);
    }

    return resultAmplitudes;
  }

  // Generate default waveform when no audio data is available
  static List<double> _generateDefaultWaveform(int bars) {
    return List.generate(bars, (index) => 0.1 + (index % 3) * 0.2);
  }

  // Normalize waveform data to 0.0-1.0 range
  static List<double> normalizeWaveform(List<double> waveform) {
    if (waveform.isEmpty) return waveform;

    final maxAmplitude = waveform.reduce(max);
    if (maxAmplitude <= 0) return waveform;

    return waveform.map((amp) => amp / maxAmplitude).toList();
  }
}