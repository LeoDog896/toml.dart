library toml.src.ast.value.float;

import 'package:petitparser/petitparser.dart';
import 'package:quiver/core.dart';

import '../value.dart';
import '../visitor/value.dart';

/// AST node that represents a TOML floating point number.
///
///     float = float-int-part ( exp / frac [ exp ] )
///     float =/ special-float
///
///     float-int-part = dec-int
///     frac = decimal-point zero-prefixable-int
///     decimal-point = %x2E               ; .
///     zero-prefixable-int = DIGIT *( DIGIT / underscore DIGIT )
///
///     exp = "e" float-exp-part
///     float-exp-part = [ minus / plus ] zero-prefixable-int
///
///     special-float = [ minus / plus ] ( inf / nan )
///     inf = %x69.6e.66  ; inf
///     nan = %x6e.61.6e  ; nan
///
/// TODO The special values `inf` and `nan` were added in TOML 0.5.0 and are
/// not supported yet.
///
/// TODO Leading zeros in exponent were allowed in TOML 1.0.0-rc.1 and are not
/// supported yet.
class TomlFloat extends TomlValue<double> {
  /// Parser for a TOML floating point value.
  static final Parser<TomlFloat> parser = (() {
    var digits = digit().plus().separatedBy(char('_'));
    var decimal = anyOf('+-').optional() & (char('0') | digits);
    var exp = anyOf('eE') & anyOf('+-').optional() & digits;
    var frac = char('.') & digits;
    var float = decimal & (exp | frac & exp.optional());
    return float
        .flatten()
        .map((str) => TomlFloat(double.parse(str.replaceAll('_', ''))));
  })();

  @override
  final double value;

  /// Creates a new floating point value.
  TomlFloat(this.value);

  @override
  TomlType get type => TomlType.float;

  @override
  T acceptValueVisitor<T>(TomlValueVisitor<T> visitor) =>
      visitor.visitFloat(this);

  @override
  bool operator ==(dynamic other) => other is TomlFloat && value == other.value;

  @override
  int get hashCode => hash2(type, value);
}
