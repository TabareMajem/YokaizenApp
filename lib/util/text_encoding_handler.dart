import 'dart:convert';

class TextEncodingHandler {
  /// Safely fixes encoding issues with text, particularly for Japanese characters
  static String fixEncoding(String text) {
    if (text.isEmpty) return text;

    try {
      // First, check if the text is already properly encoded
      // If it contains valid Unicode characters, don't modify it
      if (_isValidUnicode(text)) {
        return text;
      }

      // Try different encoding fixes
      String fixed = _tryUtf8Decode(text);
      if (_isValidUnicode(fixed)) {
        return fixed;
      }

      // If UTF-8 decode doesn't work, try rune conversion
      fixed = _tryRuneConversion(text);
      if (_isValidUnicode(fixed)) {
        return fixed;
      }

      // If all else fails, return the original text
      return text;

    } catch (e) {
      print("❌ Error in fixEncoding: $e");
      return text; // Return original text if there's any error
    }
  }

  /// Check if the text contains valid Unicode characters
  static bool _isValidUnicode(String text) {
    try {
      // Check for common encoding artifacts
      if (text.contains('�') || // Replacement character
          text.contains('\uFFFD') || // Another replacement character
          text.contains('ï¿½')) { // Common UTF-8 encoding artifact
        return false;
      }

      // Check if we can encode and decode without issues
      final encoded = utf8.encode(text);
      final decoded = utf8.decode(encoded);
      return decoded == text;
    } catch (e) {
      return false;
    }
  }

  /// Try to decode using UTF-8
  static String _tryUtf8Decode(String text) {
    try {
      // Convert string to bytes and then decode
      final bytes = text.codeUnits;
      return utf8.decode(bytes);
    } catch (e) {
      return text;
    }
  }

  /// Try rune conversion method
  static String _tryRuneConversion(String text) {
    try {
      return utf8.decode(text.runes.toList());
    } catch (e) {
      return text;
    }
  }

  /// Specifically handle OpenAI API responses
  static String handleOpenAIResponse(Map<String, dynamic> json) {
    try {
      String content = json["choices"][0]["message"]["content"].toString().trimLeft();

      // Apply encoding fix
      content = fixEncoding(content);

      // Additional cleanup for OpenAI responses
      content = _cleanupOpenAIResponse(content);

      return content;
    } catch (e) {
      print("❌ Error handling OpenAI response: $e");
      return "";
    }
  }

  /// Clean up common OpenAI response artifacts
  static String _cleanupOpenAIResponse(String content) {
    // Remove any null bytes
    content = content.replaceAll('\u0000', '');

    // Remove any control characters except newlines and tabs
    content = content.replaceAll(RegExp(r'[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]'), '');

    // Normalize whitespace
    content = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    return content;
  }

  /// Test if Japanese characters are displaying correctly
  static bool isJapaneseTextValid(String text) {
    // Check for Japanese character ranges
    final japaneseRegex = RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FAF]');

    if (!japaneseRegex.hasMatch(text)) {
      return true; // Not Japanese text, so it's "valid" in terms of encoding
    }

    // If it contains Japanese characters, check for encoding artifacts
    return !text.contains('�') &&
        !text.contains('\uFFFD') &&
        !text.contains('ï¿½');
  }
}