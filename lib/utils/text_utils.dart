/// Removes emoji (incl. flag pairs and variation selectors) and tidies spaces.
/// Used to show values saved before the app went emoji-free, e.g. "India 🇮🇳" → "India".
String stripEmoji(String input) => input
    .replaceAll(RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{FE0F}\u{200D}\u{1F1E6}-\u{1F1FF}]', unicode: true), '')
    .replaceAll(RegExp(r'\s{2,}'), ' ')
    .trim();
