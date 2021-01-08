library toml.src.encoder.pretty_printer;

import 'package:toml/src/ast.dart';

/// A visitor for TOML AST nodes that converts them to a TOML formatted string.
///
/// To pretty print an AST node, call the corresponding `visit*` method.
/// To get the TOML formatted string of the visited AST node call the
/// [toString] method of the pretty printer.
class TomlPrettyPrinter extends TomlVisitor<void>
    with
        TomlExpressionVisitor<void>,
        TomlKeyVisitor<void>,
        TomlSimpleKeyVisitor<void>,
        TomlValueVisitor<void>,
        TomlStringVisitor<void> {
  /// Buffer for constructing the TOML formatted string.
  final StringBuffer _buffer;

  /// Creates a new pretty printer for TOML AST nodes.
  TomlPrettyPrinter() : _buffer = StringBuffer();

  @override
  String toString() => _buffer.toString();

  // --------------------------------------------------------------------------
  // Utility Methods
  // --------------------------------------------------------------------------

  /// Writes the given [token] into the [_buffer] and optionally adds
  /// whitespace [before] and [after] the token.
  void _writeToken(String token, {bool before = false, bool after = false}) {
    if (before) {
      _buffer.write(' ');
    }
    _buffer.write(token);
    if (after) {
      _buffer.write(' ');
    }
  }

  /// Writes a newline sequence into the [_buffer].
  void _writeNewline() {
    _buffer.writeln();
  }

  /// Runs the given function for writing [nodes] of type [T] to the [_buffer]
  /// for every noder of the given iterable and separated the nodes by running
  /// the given separator function.
  void _separatedBy<T>(
    Iterable<T> nodes, {
    void Function(T node) write,
    void Function(T node) writeSeparator,
  }) {
    if (nodes.isNotEmpty) {
      write(nodes.first);
      for (var node in nodes.skip(1)) {
        writeSeparator(node);
        write(node);
      }
    }
  }

  // --------------------------------------------------------------------------
  // Documents
  // --------------------------------------------------------------------------

  @override
  void visitDocument(TomlDocument document) {
    _separatedBy(
      document.expressions,
      write: visitExpression,
      writeSeparator: (TomlExpression next) {
        // All expresissions are are on a line by themselves but there is an
        // additional blank line before every table header (except if it is
        // the very first expression of the document).
        if (next is TomlTable) _writeNewline();
        _writeNewline();
      },
    );
    // There should be a newline at the end of every file.
    _writeNewline();
  }

  // --------------------------------------------------------------------------
  // Expressions
  // --------------------------------------------------------------------------

  @override
  void visitKeyValuePair(TomlKeyValuePair pair) {
    visitSimpleKey(pair.key);
    _writeToken(TomlKeyValuePair.separator, before: true, after: true);
    visitValue(pair.value);
  }

  @override
  void visitStandardTable(TomlStandardTable table) {
    _writeToken(TomlStandardTable.openingDelimiter);
    visitKey(table.name);
    _writeToken(TomlStandardTable.closingDelimiter);
  }

  @override
  void visitArrayTable(TomlArrayTable table) {
    _writeToken(TomlArrayTable.openingDelimiter);
    visitKey(table.name);
    _writeToken(TomlArrayTable.closingDelimiter);
  }

  // --------------------------------------------------------------------------
  // Keys
  // --------------------------------------------------------------------------

  @override
  void visitKey(TomlKey key) {
    _separatedBy(
      key.parts,
      write: visitSimpleKey,
      writeSeparator: (_) => _writeToken(TomlKey.separator),
    );
  }

  @override
  void visitQuotedKey(TomlQuotedKey key) {
    visitString(key.string);
  }

  @override
  void visitUnquotedKey(TomlUnquotedKey key) {
    _buffer.write(key.name);
  }

  // --------------------------------------------------------------------------
  // Values
  // --------------------------------------------------------------------------

  @override
  void visitArray(TomlArray array) {
    _writeToken(TomlArray.openingDelimiter);
    _separatedBy(
      array.items,
      write: visitValue,
      writeSeparator: (_) =>
          _writeToken(TomlInlineTable.separator, after: true),
    );
    _writeToken(TomlArray.closingDelimiter);
  }

  @override
  void visitBoolean(TomlBoolean boolean) {
    _writeToken(boolean.value.toString());
  }

  @override
  void visitDateTime(TomlDateTime datetime) {
    _writeToken(datetime.value.toIso8601String());
  }

  @override
  void visitFloat(TomlFloat float) {
    _writeToken(float.value.toString());
    if (float.value is int) _writeToken('.0');
  }

  @override
  void visitInlineTable(TomlInlineTable inlineTable) {
    _writeToken(TomlInlineTable.openingDelimiter, after: true);
    _separatedBy(
      inlineTable.pairs,
      write: visitKeyValuePair,
      writeSeparator: (_) =>
          _writeToken(TomlInlineTable.separator, after: true),
    );
    _writeToken(TomlInlineTable.closingDelimiter, before: true);
  }

  @override
  void visitInteger(TomlInteger integer) {
    _writeToken(integer.value.toString());
  }

  // --------------------------------------------------------------------------
  // Strings
  // --------------------------------------------------------------------------

  @override
  void visitBasicString(TomlBasicString string) {
    _writeToken(TomlBasicString.delimiter);
    _writeToken(TomlBasicString.escape(string.value));
    _writeToken(TomlBasicString.delimiter);
  }

  @override
  void visitLiteralString(TomlLiteralString string) {
    _writeToken(TomlLiteralString.delimiter);
    _writeToken(string.value);
    _writeToken(TomlLiteralString.delimiter);
  }

  @override
  void visitMultilineBasicString(TomlMultilineBasicString string) {
    _writeToken(TomlMultilineBasicString.delimiter);
    _writeNewline();
    _writeToken(TomlMultilineBasicString.escape(string.value));
    _writeToken(TomlMultilineBasicString.delimiter);
  }

  @override
  void visitMultilineLiteralString(TomlMultilineLiteralString string) {
    _writeToken(TomlMultilineLiteralString.delimiter);
    _writeNewline();
    _writeToken(string.value);
    _writeToken(TomlMultilineLiteralString.delimiter);
  }
}
