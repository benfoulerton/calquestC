import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Renders math content. Our JSON stores math in Unicode (∫, ∂, π, x²),
/// not LaTeX. We display it in a serif font that handles those glyphs well
/// and inflates size for readability.
///
/// If [tryLatex] is true and the content looks like LaTeX (contains backslashes
/// or `^{`), we try to render via flutter_math_fork; otherwise (or on parse
/// failure) we fall back to text.
class MathText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight weight;
  final Color? color;
  final bool tryLatex;
  final TextAlign textAlign;

  const MathText(
    this.text, {
    super.key,
    this.fontSize = 16,
    this.weight = FontWeight.w500,
    this.color,
    this.tryLatex = false,
    this.textAlign = TextAlign.start,
  });

  bool get _looksLikeLatex =>
      text.contains(r'\') || text.contains('^{') || text.contains('_{');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedColor = color ??
        (isDark ? AppColors.textStrongDark : AppColors.textStrong);

    if (tryLatex && _looksLikeLatex) {
      try {
        return Math.tex(
          text,
          textStyle: TextStyle(fontSize: fontSize, color: resolvedColor),
          mathStyle: MathStyle.text,
          onErrorFallback: (e) => _plainText(resolvedColor),
        );
      } catch (_) {
        return _plainText(resolvedColor);
      }
    }
    return _plainText(resolvedColor);
  }

  Widget _plainText(Color resolvedColor) {
    // Use Roboto Mono for formulas — it makes Unicode math read like equations.
    return Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.robotoMono(
        fontSize: fontSize,
        fontWeight: weight,
        color: resolvedColor,
        height: 1.45,
      ),
    );
  }
}
