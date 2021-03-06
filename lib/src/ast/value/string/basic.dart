library toml.src.ast.value.string.basic;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/join.dart';
import 'package:toml/src/decoder/parser/util/ranges.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:quiver/core.dart';

import '../../visitor/value/string.dart';
import '../string.dart';
import 'escape.dart';

/// AST node that represents basic TOML strings.
///
///     basic-string = quotation-mark *basic-char quotation-mark
class TomlBasicString extends TomlSinglelineString {
  /// Delimiter for basic TOML strings.
  ///
  ///     quotation-mark = %x22            ; "
  static final String delimiter = '"';

  /// Parser for a basic TOML string value.
  static final Parser<TomlBasicString> parser =
      (char(delimiter) & charParser.star().join() & char(delimiter))
          .pick<String>(1)
          .map((value) => TomlBasicString(value));

  /// Parser for a single character of a basic TOML string.
  ///
  ///     basic-char = basic-unescaped / escaped
  static final Parser<String> charParser =
      (unescapedParser | TomlEscapedChar.parser).cast<String>();

  /// Parser for a single unescaped character of a basic TOML string.
  ///
  ///     basic-unescaped = wschar / %x21 / %x23-5B / %x5D-7E / non-ascii
  ///
  ///  This range excludes `%x22` which is the `quotation-mark` character `"`
  ///  and `%x5C` which is the `escape` character `\`.
  static final Parser<String> unescapedParser = (tomlWhitespaceChar |
          char(0x21) |
          range(0x23, 0x5B) |
          range(0x5D, 0x7E) |
          tomlNonAscii)
      .cast<String>();

  /// Escapes all characters of the given string that are not allowed to
  /// occur unescaped in a basic string.
  static String escape(String value) {
    var buffer = StringBuffer();
    for (var rune in value.runes) {
      TomlEscapedChar.writeEscapedChar(rune, buffer, unescapedParser);
    }
    return buffer.toString();
  }

  @override
  final String value;

  /// Creates a new basic TOML string value with the given contents.
  TomlBasicString(this.value);

  @override
  TomlStringType get stringType => TomlStringType.basic;

  @override
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor) =>
      visitor.visitBasicString(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlBasicString && value == other.value;

  @override
  int get hashCode => hash3(type, stringType, value);
}
