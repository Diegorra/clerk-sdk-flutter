import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Rich text with tappable Terms / Privacy links (same copy as sign-up flow).
class LegalAcceptanceRichText extends StatelessWidget {
  /// Creates [LegalAcceptanceRichText].
  const LegalAcceptanceRichText({super.key});

  List<TextSpan> _subSpans(
    String text,
    String target,
    String? url,
    ClerkThemeExtension themeExtension,
  ) {
    if (url case String url when url.isNotEmpty) {
      final segments = text.split(target);
      final spans = [TextSpan(text: segments.first)];
      final recognizer = TapGestureRecognizer()
        ..onTap = () => launchUrlString(url);

      for (final segmentText in segments.skip(1)) {
        spans.add(
          TextSpan(
            text: target,
            style: TextStyle(color: themeExtension.colors.link),
            recognizer: recognizer,
          ),
        );
        if (segmentText.isNotEmpty) {
          spans.add(TextSpan(text: segmentText));
        }
      }

      return spans;
    }

    return [TextSpan(text: text)];
  }

  List<InlineSpan> _spans(BuildContext context) {
    final authState = ClerkAuth.of(context, listen: false);
    final display = authState.env.display;
    final l10ns = authState.localizationsOf(context);
    final themeExtension = ClerkAuth.themeExtensionOf(context);
    final spans = _subSpans(
      l10ns.acceptTerms,
      l10ns.termsOfService,
      display.termsUrl,
      themeExtension,
    );

    return [
      for (final span in spans) //
        if (span.text case String text when span.recognizer == null) //
          ..._subSpans(
            text,
            l10ns.privacyPolicy,
            display.privacyPolicyUrl,
            themeExtension,
          )
        else //
          span,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension = ClerkAuth.themeExtensionOf(context);
    return Text.rich(
      TextSpan(children: _spans(context)),
      maxLines: 2,
      style: themeExtension.styles.subheading,
    );
  }
}
