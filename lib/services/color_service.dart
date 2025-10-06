import 'dart:math';
import 'dart:typed_data';


class ColorService {
  const ColorService();

  String rgbToHex(int r, int g, int b) {
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);
    return '#'+ r.toRadixString(16).padLeft(2, '0') + g.toRadixString(16).padLeft(2, '0') + b.toRadixString(16).padLeft(2, '0');
  }

  List<int> hexToRgb(String hex) {
    final h = hex.replaceAll('#', '');
    final r = int.parse(h.substring(0, 2), radix: 16);
    final g = int.parse(h.substring(2, 4), radix: 16);
    final b = int.parse(h.substring(4, 6), radix: 16);
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
    h /= 360; s /= 100; l /= 100;
    double r, g, b;
    if (s == 0) {
      r = g = b = l;
    } else {
      double hue2rgb(double p, double q, double t) {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1/6) return p + (q - p) * 6 * t;
        if (t < 1/2) return q;
        if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
        return p;
      }
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = hue2rgb(p, q, h + 1/3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1/3);
    }
    return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
  }

  Future<List<int>> dominantColorsFromBytes(Uint8List bytes, {int sample = 4}) async {
    // Simplified placeholder: return empty until a stable pixel API is chosen.
    return [];
  }
}
