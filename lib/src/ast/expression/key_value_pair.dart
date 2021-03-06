library toml.src.ast.expression.key_value_pair;

import 'package:petitparser/petitparser.dart';
import 'package:toml/src/decoder/parser/util/whitespace.dart';
import 'package:quiver/core.dart';

import '../expression.dart';
import '../key.dart';
import '../value.dart';
import '../visitor/expression.dart';

/// A TOML expression AST node that represents a key/value pair.
///
///     keyval = key keyval-sep val
class TomlKeyValuePair extends TomlExpression {
  /// The separator between the key and value.
  ///
  ///     keyval-sep = ws %x3D ws ; =
  static final String separator = '=';

  /// Parser for a TOML key/value pair.
  static final Parser<TomlKeyValuePair> parser = (TomlKey.parser &
          tomlWhitespace &
          char(separator) &
          tomlWhitespace &
          TomlValue.parser)
      .permute([0, 4]).map((List pair) => TomlKeyValuePair(
            pair[0] as TomlKey,
            pair[1] as TomlValue,
          ));

  /// The AST node that represents the key of the key/value pair.
  final TomlKey key;

  /// The AST node that represents the value of the key/value pair.
  final TomlValue value;

  /// Creates a new key/value pair.
  TomlKeyValuePair(this.key, this.value);

  @override
  T acceptExpressionVisitor<T>(TomlExpressionVisitor<T> visitor) =>
      visitor.visitKeyValuePair(this);

  @override
  bool operator ==(dynamic other) =>
      other is TomlKeyValuePair && key == other.key && value == other.value;

  @override
  int get hashCode => hash2(key, value);
}
