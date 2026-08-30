import 'dart:math' as math;
import 'dart:typed_data';
import 'audio_engine_service.dart';

class AmbientAudioSynthesizer {
  static const int sampleRate = 22050;
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
    const int durationSeconds = 6;
    const int totalSamples = sampleRate * durationSeconds;
    final int numChannels = (sound == AmbientSound.solfeggio528 ||
        sound == AmbientSound.solfeggio432 ||
        sound == AmbientSound.solfeggio639 ||
        sound == AmbientSound.solfeggio852 ||
        sound == AmbientSound.binauralTheta ||
        sound == AmbientSound.windChimes ||
        sound == AmbientSound.nightCrickets)
        ? 2
        : 1;

    final Float32List leftChannel = Float32List(totalSamples);
    final Float32List rightChannel = Float32List(totalSamples);

    final random = math.Random(42);

    switch (sound) {
      case AmbientSound.solfeggio528:
        // Soft, peaceful 528Hz healing singing bowl chord with 4Hz binaural pulse
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final envelope = 0.5 + 0.5 * math.sin(2 * math.pi * 0.25 * t);
          leftChannel[i] = (0.22 * math.sin(2 * math.pi * 528.0 * t) +
                            0.12 * math.sin(2 * math.pi * 264.0 * t) +
                            0.05 * math.sin(2 * math.pi * 1056.0 * t)) * envelope;
          rightChannel[i] = (0.22 * math.sin(2 * math.pi * 532.0 * t) +
                             0.12 * math.sin(2 * math.pi * 266.0 * t) +
                             0.05 * math.sin(2 * math.pi * 1064.0 * t)) * envelope;
        }
        break;

      case AmbientSound.solfeggio432:
        // Warm 432Hz deep meditative drone
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final envelope = 0.5 + 0.5 * math.sin(2 * math.pi * 0.2 * t);
          leftChannel[i] = (0.25 * math.sin(2 * math.pi * 432.0 * t) +
                            0.12 * math.sin(2 * math.pi * 216.0 * t)) * envelope;
          rightChannel[i] = (0.25 * math.sin(2 * math.pi * 436.0 * t) +
                             0.12 * math.sin(2 * math.pi * 218.0 * t)) * envelope;
        }
        break;

      case AmbientSound.solfeggio639:
        // Harmonic 639Hz Heart Chakra resonance (Love, Compassion & Abundance)
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final envelope = 0.5 + 0.5 * math.sin(2 * math.pi * 0.22 * t);
          leftChannel[i] = (0.22 * math.sin(2 * math.pi * 639.0 * t) +
                            0.10 * math.sin(2 * math.pi * 319.5 * t) +
                            0.04 * math.sin(2 * math.pi * 1278.0 * t)) * envelope;
          rightChannel[i] = (0.22 * math.sin(2 * math.pi * 644.0 * t) +
                             0.10 * math.sin(2 * math.pi * 322.0 * t) +
                             0.04 * math.sin(2 * math.pi * 1288.0 * t)) * envelope;
        }
        break;

      case AmbientSound.solfeggio852:
        // Pure 852Hz Intuition & Awakening crystal tone
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final envelope = 0.55 + 0.45 * math.sin(2 * math.pi * 0.16 * t);
          leftChannel[i] = (0.20 * math.sin(2 * math.pi * 852.0 * t) +
                            0.08 * math.sin(2 * math.pi * 426.0 * t)) * envelope;
          rightChannel[i] = (0.20 * math.sin(2 * math.pi * 856.0 * t) +
                             0.08 * math.sin(2 * math.pi * 428.0 * t)) * envelope;
        }
        break;

      case AmbientSound.binauralTheta:
        // 6Hz Theta Waves (Left 216Hz, Right 222Hz) for Deep Focus & Flow State
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final sub = 0.08 * math.sin(2 * math.pi * 108.0 * t);
          leftChannel[i] = (0.22 * math.sin(2 * math.pi * 216.0 * t) + sub).clamp(-1.0, 1.0);
          rightChannel[i] = (0.22 * math.sin(2 * math.pi * 222.0 * t) + sub).clamp(-1.0, 1.0);
        }
        break;

      case AmbientSound.fireplace:
        // Warm crackling hearth with low flame rumble and spark snaps
        double rumble = 0.0;
        for (int i = 0; i < totalSamples; i++) {
          final white = random.nextDouble() * 2.0 - 1.0;
          rumble = 0.98 * rumble + white * 0.04;
          final isCrackle = random.nextDouble() > 0.9985;
          final crackle = isCrackle ? (random.nextDouble() * 0.45 - 0.22) : 0.0;
          final sample = (rumble * 1.8 + crackle).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.windChimes:
        // Gentle pentatonic singing chimes drifting in soft breeze
        final List<double> chimeFreqs = [528.0, 660.0, 792.0, 990.0, 1188.0];
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final breeze = 0.4 + 0.6 * math.sin(2 * math.pi * 0.2 * t);
          double chimeSum = 0.0;
          for (int c = 0; c < chimeFreqs.length; c++) {
            final phase = c * 1.25;
            final hit = math.pow(0.5 + 0.5 * math.sin(2 * math.pi * 0.35 * t + phase), 6).toDouble();
            chimeSum += 0.06 * hit * math.sin(2 * math.pi * chimeFreqs[c] * t);
          }
          final sample = (chimeSum * breeze * 1.6).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.nightCrickets:
        // Tranquil night atmosphere with gentle rhythmic crickets
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final chirpPulse = math.pow(math.max(0.0, math.sin(2 * math.pi * 4.5 * t)), 8.0).toDouble();
          final cricketWave = math.sin(2 * math.pi * 4500.0 * t) * chirpPulse * 0.16;
          final airRumble = 0.03 * math.sin(2 * math.pi * 120.0 * t);
          final sample = (cricketWave + airRumble).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.ocean:
        // Soft soothing ocean surf
        double lastSample = 0.0;
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final swell = 0.4 + 0.6 * math.sin(2 * math.pi * 0.18 * t);
          final white = (random.nextDouble() * 2.0 - 1.0);
          lastSample = lastSample + 0.03 * (white - lastSample);
          final sample = (lastSample * swell * 2.2).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.rain:
        // Gentle soothing rain shower
        double b0 = 0, b1 = 0, b2 = 0;
        for (int i = 0; i < totalSamples; i++) {
          final white = random.nextDouble() * 2.0 - 1.0;
          b0 = 0.99886 * b0 + white * 0.0555179;
          b1 = 0.99332 * b1 + white * 0.0750759;
          b2 = 0.96900 * b2 + white * 0.1538520;
          final pink = (b0 + b1 + b2 + white * 0.5362) * 0.09;
          final droplet = (random.nextDouble() > 0.99) ? (random.nextDouble() * 0.08) : 0.0;
          final sample = (pink + droplet).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.forest:
        // Calming woodland breeze
        double lastSample = 0.0;
        for (int i = 0; i < totalSamples; i++) {
          final t = i / sampleRate;
          final white = (random.nextDouble() * 2.0 - 1.0);
          lastSample = lastSample + 0.06 * (white - lastSample);
          final wind = 0.5 + 0.5 * math.sin(2 * math.pi * 0.3 * t);
          final sample = (lastSample * wind * 1.5).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;

      case AmbientSound.whiteNoise:
      case AmbientSound.none:
      default:
        double b0 = 0, b1 = 0;
        for (int i = 0; i < totalSamples; i++) {
          final white = random.nextDouble() * 2.0 - 1.0;
          b0 = 0.997 * b0 + white * 0.04;
          b1 = 0.985 * b1 + white * 0.08;
          final sample = ((b0 + b1) * 0.18).clamp(-1.0, 1.0);
          leftChannel[i] = sample;
          rightChannel[i] = sample;
        }
        break;
    }

    // Seamless loop windowing (smooth 50ms cosine fade at start/end)
    const int fadeSamples = 1102;
    for (int i = 0; i < fadeSamples; i++) {
      final fade = 0.5 - 0.5 * math.cos(math.pi * i / fadeSamples);
      leftChannel[i] *= fade;
      leftChannel[totalSamples - 1 - i] *= fade;
      if (numChannels == 2) {
        rightChannel[i] *= fade;
        rightChannel[totalSamples - 1 - i] *= fade;
      }
    }

    // Convert Float32 to 16-bit PCM WAV bytes
    final int dataSize = totalSamples * numChannels * 2;
    final int fileSize = 44 + dataSize;
    final Uint8List wavBytes = Uint8List(fileSize);
    final ByteData byteData = ByteData.view(wavBytes.buffer);

    wavBytes.setRange(0, 4, 'RIFF'.codeUnits);
    byteData.setUint32(4, fileSize - 8, Endian.little);
    wavBytes.setRange(8, 12, 'WAVE'.codeUnits);

    wavBytes.setRange(12, 16, 'fmt '.codeUnits);
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * numChannels * 2, Endian.little);
    byteData.setUint16(32, numChannels * 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);

    wavBytes.setRange(36, 40, 'data'.codeUnits);
    byteData.setUint32(40, dataSize, Endian.little);

    int offset = 44;
    for (int i = 0; i < totalSamples; i++) {
      final int leftInt16 = (leftChannel[i].clamp(-1.0, 1.0) * 32767).round();
      byteData.setInt16(offset, leftInt16, Endian.little);
      offset += 2;

      if (numChannels == 2) {
        final int rightInt16 = (rightChannel[i].clamp(-1.0, 1.0) * 32767).round();
        byteData.setInt16(offset, rightInt16, Endian.little);
        offset += 2;
      }
    }

    return wavBytes;
  }
}
