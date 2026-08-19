import 'dart:math' as math;
import 'dart:typed_data';
import 'audio_engine_service.dart';

class AmbientAudioSynthesizer {
  static const int sampleRate = 22050; // High efficiency for web & mobile
  static final Map<AmbientSound, Uint8List> _cachedBuffers = {};

  /// Returns seamless loop PCM WAV bytes for the specified soundscape
  static Uint8List getWavBytesForSound(AmbientSound sound) {
    if (_cachedBuffers.containsKey(sound)) {
      return _cachedBuffers[sound]!;
    }

    final bytes = _generateWavBytes(sound);
    _cachedBuffers[sound] = bytes;
    return bytes;
  }

  static Uint8List _generateWavBytes(AmbientSound sound) {
    // 6.0 seconds seamless loop buffer
    const int durationSeconds = 6;
    const int totalSamples = sampleRate * durationSeconds;
    final int numChannels = (sound == AmbientSound.solfeggio528 || sound == AmbientSound.solfeggio432) ? 2 : 1;

    final Float32List leftChannel = Float32List(totalSamples);
    final Float32List rightChannel = Float32List(totalSamples);

    final random = math.Random(42);

    switch (sound) {
      case AmbientSound.solfeggio528:
        // 528Hz in Left ear, 532Hz in Right ear (4Hz Theta Wave binaural beat + 264Hz sub-octave)
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          // Left: 528Hz + 264Hz warm undertone
          leftChannel[i] = 0.5 * math.sin(2 * math.pi * 528.0 * t) +
                           0.25 * math.sin(2 * math.pi * 264.0 * t) +
                           0.12 * math.sin(2 * math.pi * 1056.0 * t);
          // Right: 532Hz + 266Hz warm undertone
          rightChannel[i] = 0.5 * math.sin(2 * math.pi * 532.0 * t) +
                            0.25 * math.sin(2 * math.pi * 266.0 * t) +
                            0.12 * math.sin(2 * math.pi * 1064.0 * t);
        }
        break;

      case AmbientSound.solfeggio432:
        // 432Hz in Left, 436Hz in Right (4Hz Theta binaural beat)
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          leftChannel[i] = 0.55 * math.sin(2 * math.pi * 432.0 * t) +
                           0.25 * math.sin(2 * math.pi * 216.0 * t);
          rightChannel[i] = 0.55 * math.sin(2 * math.pi * 436.0 * t) +
                            0.25 * math.sin(2 * math.pi * 218.0 * t);
        }
        break;

      case AmbientSound.ocean:
        // Sine-modulated lowpass filtered noise (simulating waves crashing & receding)
        double lastSample = 0.0;
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final swell = 0.5 + 0.5 * math.sin(2 * math.pi * 0.18 * t); // ~5.5 sec wave period
          final white = (random.nextDouble() * 2.0 - 1.0);
          // Lowpass filter
          lastSample = lastSample + 0.04 * (white - lastSample);
          final sample = lastSample * swell * 3.5;
          leftChannel[i] = sample.clamp(-1.0, 1.0);
          rightChannel[i] = sample.clamp(-1.0, 1.0);
        }
        break;

      case AmbientSound.rain:
        // Pink noise with subtle high frequency droplet texture
        double b0 = 0, b1 = 0, b2 = 0;
        for (int i = 0; i < totalSamples; i++) {
          final white = random.nextDouble() * 2.0 - 1.0;
          // Pink noise filter approximation
          b0 = 0.99886 * b0 + white * 0.0555179;
          b1 = 0.99332 * b1 + white * 0.0750759;
          b2 = 0.96900 * b2 + white * 0.1538520;
          final pink = (b0 + b1 + b2 + white * 0.5362) * 0.12;
          final droplet = (random.nextDouble() > 0.985) ? (random.nextDouble() * 0.15) : 0.0;
          final sample = (pink + droplet).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.forest:
        // Gentle rustle noise + soft harmonics
        double lastSample = 0.0;
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final white = (random.nextDouble() * 2.0 - 1.0);
          lastSample = lastSample + 0.08 * (white - lastSample);
          final wind = 0.6 + 0.4 * math.sin(2 * math.pi * 0.3 * t);
          final chirp = (math.sin(2 * math.pi * 2200 * t) * (math.sin(2 * math.pi * 1.5 * t) > 0.9 ? 0.08 : 0.0));
          final sample = (lastSample * wind * 1.8 + chirp).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.whiteNoise:
      case AmbientSound.none:
      default:
        // Gentle smooth white/pink noise
        double b0 = 0, b1 = 0;
        for (int i = 0; i < totalSamples; i++) {
          final white = random.nextDouble() * 2.0 - 1.0;
          b0 = 0.997 * b0 + white * 0.05;
          b1 = 0.985 * b1 + white * 0.11;
          final sample = ((b0 + b1) * 0.25).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;
    }

    // Convert Float32 to 16-bit PCM WAV byte structure
    final int dataSize = totalSamples * numChannels * 2;
    final int fileSize = 44 + dataSize;
    final Uint8List wavBytes = Uint8List(fileSize);
    final ByteData byteData = ByteData.view(wavBytes.buffer);

    // 1. RIFF header
    wavBytes.setRange(0, 4, 'RIFF'.codeUnits);
    byteData.setUint32(4, fileSize - 8, Endian.little);
    wavBytes.setRange(8, 12, 'WAVE'.codeUnits);

    // 2. fmt chunk
    wavBytes.setRange(12, 16, 'fmt '.codeUnits);
    byteData.setUint32(16, 16, Endian.little); // Chunk size
    byteData.setUint16(20, 1, Endian.little);  // PCM format
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * numChannels * 2, Endian.little); // Byte rate
    byteData.setUint16(32, numChannels * 2, Endian.little);              // Block align
    byteData.setUint16(34, 16, Endian.little);                           // 16 bits per sample

    // 3. data chunk
    wavBytes.setRange(36, 40, 'data'.codeUnits);
    byteData.setUint32(40, dataSize, Endian.little);

    // 4. Samples
    int offset = 44;
    for (int i = 0; i < totalSamples; i++) {
      // Left sample
      final int leftInt16 = (leftChannel[i].clamp(-1.0, 1.0) * 32767).round();
      byteData.setInt16(offset, leftInt16, Endian.little);
      offset += 2;

      if (numChannels == 2) {
        // Right sample
        final int rightInt16 = (rightChannel[i].clamp(-1.0, 1.0) * 32767).round();
        byteData.setInt16(offset, rightInt16, Endian.little);
        offset += 2;
      }
    }

    return wavBytes;
  }
}
