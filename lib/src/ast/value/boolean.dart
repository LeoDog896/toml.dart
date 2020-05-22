// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.ast.value.boolean;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/ast/value.dart';

/// AST node that represents a boolean TOML value.
///
///     boolean = true / false
///
///     true    = %x74.72.75.65     ; true
///     false   = %x66.61.6C.73.65  ; false
class TomlBoolean extends TomlValue<bool> {
  /// Parser for a boolean TOML value.
  static final Parser<TomlBoolean> parser =
      (string('true').map((_) => kTrue) | string('false').map((_) => kFalse))
          .cast<TomlBoolean>();

  /// The boolean TOML value `true`.
  static final TomlBoolean kTrue = new TomlBoolean(true);

  /// The boolean TOML value `false`.
  static final TomlBoolean kFalse = new TomlBoolean(false);

  @override
  final bool value;

  /// Creates a new boolean value.
  TomlBoolean(this.value);

  @override
  TomlType get type => TomlType.boolean;
}