library toml.src.ast.value.table;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

import '../expression/key_value_pair.dart';
import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML inline table.
///
///     inline-table =
///         inline-table-open [ inline-table-keyvals ] inline-table-close
///
///     inline-table-keyvals = keyval [ inline-table-sep inline-table-keyvals ]
class TomlInlineTable extends TomlValue {
  /// The opening delimiter of inline tables.
  ///
  ///     inline-table-open  = %x7B ws     ; {
  static final String openingDelimiter = '{';

  /// The separator for the key/value pairs in inline tables.
  ///
  ///     inline-table-sep   = ws %x2C ws  ; , Comma
  static final String separator = ',';

  /// The closing delimiter of inline tables.
  ///
  ///     inline-table-close = ws %x7D     ; }
  static final String closingDelimiter = '}';

  /// Parser for a TOML inline-table.
  ///
  /// Trailing commas are currently not allowed.
  /// See https://github.com/toml-lang/toml/pull/235#issuecomment-73578529
  static final Parser<TomlInlineTable> parser = (char(openingDelimiter) &
          tomlWhitespace &
          (TomlKeyValuePair.parser.separatedBy<TomlKeyValuePair>(
            tomlWhitespace & char(separator) & tomlWhitespace,
            includeSeparators: false,
            optionalSeparatorAtEnd: false,
          )).optional(<TomlKeyValuePair>[]) &
          tomlWhitespace &
          char(closingDelimiter))
      .pick<List<TomlKeyValuePair>>(2)
      .map((List<TomlKeyValuePair> pairs) => TomlInlineTable(pairs));

  /// The key/value pairs of the inline table.
  final List<TomlKeyValuePair> pairs;

  /// Creates a new inline table.
  TomlInlineTable(Iterable<TomlKeyValuePair> pairs)
      : pairs = List.from(pairs, growable: false);

  @override
  TomlType get type => TomlType.table;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitInlineTable(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlInlineTable && listsEqual(pairs, other.pairs);

  @override
  int get hashCode => hashObjects(<dynamic>[type].followedBy(pairs));
}
