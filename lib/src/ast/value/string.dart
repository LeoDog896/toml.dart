// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.string;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value.dart';
import 'package:toml/src/ast/value/string/basic.dart';
import 'package:toml/src/ast/value/string/literal.dart';
import 'package:toml/src/ast/value/string/ml_basic.dart';
import 'package:toml/src/ast/value/string/ml_literal.dart';
import 'package:toml/src/ast/visitor/value/string.dart';
import 'package:toml/src/ast/visitor/value.dart';

/// Base class for AST nodes that represent a TOML strings.
///
///     string = ml-basic-string
///            / basic-string
///            / ml-literal-string
///            / literal-string
abstract class TomlString extends TomlValue<String> {
  /// Parser for a TOML string value.
  static final Parser<TomlString> parser = (TomlMultilineBasicString.parser |
          TomlBasicString.parser |
          TomlMultilineLiteralString.parser |
          TomlLiteralString.parser)
      .cast<TomlString>();

  @override
  TomlType get type => TomlType.string;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitString(this);

  /// Invokes the correct `visit*` method for this string value of the given
  /// visitor.
  T acceptStringVisitor<T>(TomlStringVisitor<T> visitor);
}

/// Base class for AST nodes that represent non-multiline TOML strings (i.e.,
/// literal and basic strings).
///
/// This class is used such that quoted keys can restrict the type of the
/// string on type level.
abstract class TomlSinglelineString extends TomlString {
  /// Parser for a singleline TOML string value.
  static final Parser<TomlSinglelineString> parser =
      (TomlBasicString.parser | TomlLiteralString.parser)
          .cast<TomlSinglelineString>();
}

/// Base class for AST nodes that represent multiline TOML strings.
///
/// This class exists only for the sake of consistency with
/// [TomlSinglelineString].
abstract class TomlMultilineString extends TomlString {
  /// Parser for a multiline TOML string value.
  static final Parser<TomlMultilineString> parser =
      (TomlMultilineBasicString.parser | TomlMultilineLiteralString.parser)
          .cast<TomlMultilineString>();
}
