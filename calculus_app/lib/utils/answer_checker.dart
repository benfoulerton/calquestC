/// Compares user-typed answers to expected values, tolerantly.
///
/// The JSON-stored answers are a mix of:
///   - bare numbers ("5", "1/3", "26/3", "0.368")
///   - simple expressions ("y = e^(2t)", "x² + 3x + C", "(0, 0)")
///   - words ("yes", "diverges")
///
/// We can't symbolically equate two expressions in the general case, so we
/// take a pragmatic approach: normalise both sides, then check
///   - exact match, or
///   - numerical equality (within tolerance) when both sides parse as numbers
///     (including simple fractions like "p/q").
class AnswerChecker {
  /// Returns true when [user] is plausibly equivalent to [expected].
  static bool isCorrect(String user, String expected) {
    final u = _normalise(user);
    final e = _normalise(expected);
    if (u.isEmpty) return false;
    if (u == e) return true;

    // Try numerical comparison.
    final un = _toDouble(u);
    final en = _toDouble(e);
    if (un != null && en != null) {
      final scale = en.abs() < 1 ? 1.0 : en.abs();
      return (un - en).abs() / scale < 0.02; // within 2%
    }

    // Drop trailing "+ C" for indefinite integrals — accept either form.
    final uNoC = _stripPlusC(u);
    final eNoC = _stripPlusC(e);
    if (uNoC == eNoC && uNoC.isNotEmpty) return true;

    return false;
  }

  /// Lower-cases, removes whitespace, normalises Unicode minus/multiply/etc.
  static String _normalise(String s) {
    return s
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('\u2212', '-') // unicode minus
        .replaceAll('\u00d7', '*') // ×
        .replaceAll('\u00b7', '*') // ·
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('⁴', '^4')
        .replaceAll('⁵', '^5');
  }

  static String _stripPlusC(String s) {
    if (s.endsWith('+c')) return s.substring(0, s.length - 2);
    if (s.endsWith('-c')) return s.substring(0, s.length - 2);
    return s;
  }

  /// Tries to convert to a double. Handles bare numbers and simple fractions
  /// "a/b". Returns null otherwise.
  static double? _toDouble(String s) {
    final direct = double.tryParse(s);
    if (direct != null) return direct;

    // Fraction "a/b" with a, b numeric.
    final m = RegExp(r'^(-?[0-9.]+)/(-?[0-9.]+)$').firstMatch(s);
    if (m != null) {
      final a = double.tryParse(m.group(1)!);
      final b = double.tryParse(m.group(2)!);
      if (a != null && b != null && b != 0) return a / b;
    }
    return null;
  }
}
