import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/app_colors.dart';
import '../utils/waveform_processor.dart';
import '../utils/waveform_generator.dart';

class MessageComposer extends StatefulWidget {
  final Function(String) onSendText;
  final Function(String, Duration, List<double>) onSendVoice; // Updated to include waveform data
  final String currentUserId;
  final String currentUserName;

  const MessageComposer({
    super.key,
    required this.onSendText,
    required this.onSendVoice,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _textController = TextEditingController();
  AudioRecorder? _audioRecorder; // Made nullable to allow recreation
  final WaveformProcessor _waveformProcessor = WaveformProcessor();
  bool _isRecording = false;
  bool _isRecordingLocked = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  String? _recordingPath;
  List<double> _waveformData = []; // Current display data (last 30 bars)
  List<double> _completeWaveformData = []; // Complete waveform for the entire recording
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  List<Uint8List> _recordedChunks = [];

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  void _initializeRecorder() {
    _audioRecorder = AudioRecorder();
  }

  void _startRecording() async {
    // Ensure recorder is properly initialized
    if (_audioRecorder == null) {
      _initializeRecorder();
    }

    final recorder = _audioRecorder!;
    if (!await recorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission required')),
      );
      return;
    }

    final directory = await getApplicationDocumentsDirectory();
    _recordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

    // Reset waveform processor and recorded chunks for new recording
    _waveformProcessor.reset();
    _recordedChunks.clear();
    _completeWaveformData.clear();

    // Start real-time audio stream processing (this handles both waveform and recording)
    _startAudioStreamProcessing();

    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
      _waveformData = [];
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });
  }

  void _startAudioStreamProcessing() async {
    final recorder = _audioRecorder;
    if (recorder == null) return;

    try {
      // Start the audio stream for real-time processing
      final stream = await recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 44100,
        numChannels: 1,
      ));

      _audioStreamSubscription = stream.listen((data) {
        if (!_isRecording) return;

        // Store chunk for file saving
        _recordedChunks.add(data);

        // Process the audio data to get amplitude
        double amplitude = _waveformProcessor.processAudioData(data);

        // Add to complete waveform data (for message storage)
        _completeWaveformData.add(amplitude);

        setState(() {
          // Update display waveform (keep only last 30 bars for performance)
          _waveformData.add(amplitude);
          if (_waveformData.length > 30) {
            _waveformData.removeAt(0);
          }
        });
      });
    } catch (e) {
      debugPrint('Error starting audio stream: $e');
    }
  }

  void _stopRecording() async {
    _recordingTimer?.cancel();
    _audioStreamSubscription?.cancel();

    // Save recorded chunks to WAV file
    if (_recordedChunks.isNotEmpty && _recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        final pcmData = _recordedChunks.expand((chunk) => chunk).toList();

        // Create WAV file with proper header
        final wavData = _createWavFile(pcmData, 44100, 1, 16);
        await file.writeAsBytes(wavData);

        // Normalize complete waveform data to exactly 20 bars for message bubble
        final normalizedWaveformData = _normalizeWaveformToBars(_completeWaveformData, 20);

        final duration = Duration(seconds: _recordingDuration);
        widget.onSendVoice(_recordingPath!, duration, normalizedWaveformData);
      } catch (e) {
        debugPrint('Error saving recording: $e');
      }
    }

    // Reset recorder state completely
    await _resetRecorder();

    setState(() {
      _isRecording = false;
      _isRecordingLocked = false;
      _recordingDuration = 0;
      _recordedChunks.clear();
      _waveformData = [];
      _completeWaveformData.clear();
    });
  }

  // Create a WAV file from PCM data
  List<int> _createWavFile(List<int> pcmData, int sampleRate, int channels, int bitsPerSample) {
    final int byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final int blockAlign = channels * bitsPerSample ~/ 8;
    final int dataSize = pcmData.length;
    final int fileSize = 36 + dataSize;

    final List<int> header = [];

    // RIFF header
    header.addAll('RIFF'.codeUnits);
    header.addAll(_int32ToBytes(fileSize));
    header.addAll('WAVE'.codeUnits);

    // Format chunk
    header.addAll('fmt '.codeUnits);
    header.addAll(_int32ToBytes(16)); // Chunk size
    header.addAll(_int16ToBytes(1)); // Audio format (PCM)
    header.addAll(_int16ToBytes(channels));
    header.addAll(_int32ToBytes(sampleRate));
    header.addAll(_int32ToBytes(byteRate));
    header.addAll(_int16ToBytes(blockAlign));
    header.addAll(_int16ToBytes(bitsPerSample));

    // Data chunk
    header.addAll('data'.codeUnits);
    header.addAll(_int32ToBytes(dataSize));
    header.addAll(pcmData);

    return header;
  }

  List<int> _int16ToBytes(int value) {
    return [value & 0xFF, (value >> 8) & 0xFF];
  }

  List<int> _int32ToBytes(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  // Normalize waveform data to exactly the specified number of bars
  List<double> _normalizeWaveformToBars(List<double> waveformData, int targetBars) {
    if (waveformData.isEmpty) {
      // Return default waveform if no data
      return List.generate(targetBars, (index) => 0.1 + (index % 3) * 0.2);
    }

    if (waveformData.length == targetBars) {
      return List.from(waveformData);
    }

    if (waveformData.length < targetBars) {
      // Pad with average values if we have fewer bars
      final avgAmplitude = waveformData.reduce((a, b) => a + b) / waveformData.length;
      final result = List<double>.from(waveformData);
      while (result.length < targetBars) {
        result.add(avgAmplitude);
      }
      return result;
    }

    // Downsample to target bars by averaging segments
    final segmentSize = waveformData.length / targetBars;
    final result = <double>[];

    for (int i = 0; i < targetBars; i++) {
      final start = (i * segmentSize).floor();
      final end = ((i + 1) * segmentSize).ceil();
      final segment = waveformData.sublist(start, end.clamp(0, waveformData.length));
      final avg = segment.isEmpty ? 0.0 : segment.reduce((a, b) => a + b) / segment.length;
      result.add(avg);
    }

    return result;
  }

  Future<void> _resetRecorder() async {
    // Cancel any existing subscription
    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;

    // Dispose of current recorder
    await _audioRecorder?.dispose();
    _audioRecorder = null;

    // Reinitialize recorder for next use
    _initializeRecorder();
  }

  void _cancelRecording() {
    _recordingTimer?.cancel();
    _audioStreamSubscription?.cancel();

    // Reset recorder state completely
    _resetRecorder();

    setState(() {
      _isRecording = false;
      _isRecordingLocked = false;
      _recordingDuration = 0;
      _waveformData = [];
      _recordedChunks.clear();
      _completeWaveformData.clear();
    });
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendText(text);
      _textController.clear();
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textController.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRecording && !_isRecordingLocked)
              _buildRecordingIndicator(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: kSurfaceColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: null,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onLongPressStart: hasText ? null : (_) => _startRecording(),
                  onLongPressEnd: hasText ? null : (_) => _stopRecording(),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: hasText ? kBrandColor : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: hasText ? _sendTextMessage : null,
                      icon: Icon(
                        hasText ? Icons.send : Icons.mic,
                        color: hasText ? Colors.white : kBrandColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kDangerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kDangerColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: kDangerColor),
              const SizedBox(width: 12),
              Text(
                'Recording... ${_formatDuration(_recordingDuration)}',
                style: TextStyle(
                  color: kDangerColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _cancelRecording,
                icon: Icon(Icons.close, color: kDangerColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Dynamic waveform visualization
          Container(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _waveformData.length > 0 ? _waveformData.length : 20,
                (index) {
                  double height = _waveformData.isNotEmpty
                      ? _waveformData[index] * 30 // Max height of 30
                      : 4.0; // Default small height when no data

                  return Container(
                    width: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: 3,
                        height: height,
                        decoration: BoxDecoration(
                          color: kDangerColor,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _recordingTimer?.cancel();
    _audioStreamSubscription?.cancel();
    _audioRecorder?.dispose();
    super.dispose();
  }
}