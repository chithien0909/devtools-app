import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ColorService {
  const ColorService();

  String rgbToHex(int r, int g, int b) {
    final rr = r.clamp(0, 255);
    final gg = g.clamp(0, 255);
    final bb = b.clamp(0, 255);
    return '#${rr.toRadixString(16).padLeft(2, '0')}${gg.toRadixString(16).padLeft(2, '0')}${bb.toRadixString(16).padLeft(2, '0')}';
  }

  List<int> hexToRgb(String hex) {
    final cleaned = hex.replaceAll('#', '');
    final r = int.parse(cleaned.substring(0, 2), radix: 16);
    final g = int.parse(cleaned.substring(2, 4), radix: 16);
    final b = int.parse(cleaned.substring(4, 6), radix: 16);
    return [r, g, b];
  }

  List<double> rgbToHsl(int r, int g, int b) {
    final rn = r / 255.0;
    final gn = g / 255.0;
    final bn = b / 255.0;
    final maxv = max(rn, max(gn, bn));
    final minv = min(rn, min(gn, bn));
    double h = 0, s = 0;
    final l = (maxv + minv) / 2.0;
    if (maxv != minv) {
      final d = maxv - minv;
      s = l > 0.5 ? d / (2.0 - maxv - minv) : d / (maxv + minv);
      if (maxv == rn) {
        h = (gn - bn) / d + (gn < bn ? 6 : 0);
      } else if (maxv == gn) {
        h = (bn - rn) / d + 2;
      } else {
        h = (rn - gn) / d + 4;
      }
      h /= 6;
    }
    return [h * 360, s * 100, l * 100];
  }

  List<int> hslToRgb(double h, double s, double l) {
    double convert(double p, double q, double t) {
      if (t < 0) t += 1;
      if (t > 1) t -= 1;
      if (t < 1 / 6) return p + (q - p) * 6 * t;
      if (t < 1 / 2) return q;
      if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
      return p;
    }

    h /= 360;
    s /= 100;
    l /= 100;

    double r, g, b;
    if (s == 0) {
      r = g = b = l;
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = convert(p, q, h + 1 / 3);
      g = convert(p, q, h);
      b = convert(p, q, h - 1 / 3);
    }
    return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
  }

  Future<List<int>> dominantColorsFromBytes(
    Uint8List bytes, {
    int paletteSize = 5,
    int sampleStride = 4,
    int maxIterations = 12,
  }) async {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const FormatException('Unable to decode image bytes');
    }

    final stride = sampleStride.clamp(1, 12);
    final samples = <_ColorPoint>[];
    for (var y = 0; y < image.height; y += stride) {
      for (var x = 0; x < image.width; x += stride) {
        final pixel = image.getPixel(x, y);
        samples.add(
          _ColorPoint(
            pixel.r.toDouble(),
            pixel.g.toDouble(),
            pixel.b.toDouble(),
          ),
        );
      }
    }

    if (samples.isEmpty) {
      final pixel = image.getPixel(0, 0);
      return [
        (pixel.r.toInt() << 16) | (pixel.g.toInt() << 8) | pixel.b.toInt(),
      ];
    }

    final cappedPalette = paletteSize.clamp(1, min(samples.length, 12).toInt());
    final clusters = _initializeClusters(samples, cappedPalette);

    for (var iteration = 0; iteration < maxIterations; iteration++) {
      for (final cluster in clusters) {
        cluster.members.clear();
      }
      for (final sample in samples) {
        _nearestCluster(sample, clusters).members.add(sample);
      }

      var changed = false;
      final random = Random(42 + iteration);
      for (final cluster in clusters) {
        if (cluster.members.isEmpty) {
          cluster.center = samples[random.nextInt(samples.length)];
          changed = true;
          continue;
        }
        final newCenter = _average(cluster.members);
        if (!cluster.center.isCloseTo(newCenter)) {
          cluster.center = newCenter;
          changed = true;
        }
      }

      if (!changed) break;
    }

    final distinct = <int>{};
    for (final cluster in clusters) {
      distinct.add(cluster.center.toRgbInt());
    }

    return distinct.take(cappedPalette).toList();
  }

  List<_Cluster> _initializeClusters(List<_ColorPoint> samples, int k) {
    final step = max(samples.length ~/ k, 1);
    final clusters = <_Cluster>[];
    for (var i = 0; i < k; i++) {
      final index = min(i * step, samples.length - 1);
      clusters.add(_Cluster(center: samples[index]));
    }
    return clusters;
  }

  _Cluster _nearestCluster(_ColorPoint point, List<_Cluster> clusters) {
    _Cluster best = clusters.first;
    var bestDistance = double.infinity;
    for (final cluster in clusters) {
      final distance = point.distanceTo(cluster.center);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = cluster;
      }
    }
    return best;
  }

  _ColorPoint _average(List<_ColorPoint> points) {
    var sumR = 0.0, sumG = 0.0, sumB = 0.0;
    for (final point in points) {
      sumR += point.r;
      sumG += point.g;
      sumB += point.b;
    }
    final divisor = points.length.toDouble();
    return _ColorPoint(sumR / divisor, sumG / divisor, sumB / divisor);
  }
}

class _ColorPoint {
  const _ColorPoint(this.r, this.g, this.b);

  final double r;
  final double g;
  final double b;

  double distanceTo(_ColorPoint other) {
    final dr = r - other.r;
    final dg = g - other.g;
    final db = b - other.b;
    return (dr * dr) + (dg * dg) + (db * db);
  }

  bool isCloseTo(_ColorPoint other, {double epsilon = 1.0}) {
    return (r - other.r).abs() <= epsilon &&
        (g - other.g).abs() <= epsilon &&
        (b - other.b).abs() <= epsilon;
  }

  int toRgbInt() {
    final rr = r.round().clamp(0, 255);
    final gg = g.round().clamp(0, 255);
    final bb = b.round().clamp(0, 255);
    return (rr << 16) | (gg << 8) | bb;
  }
}

class _Cluster {
  _Cluster({required this.center});

  _ColorPoint center;
  final List<_ColorPoint> members = [];
}
