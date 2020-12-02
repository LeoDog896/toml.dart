// Copyright (c) 2015 Justin Andresen. All rights reserved.
// This software may be modified and distributed under the terms
// of the MIT license. See the LICENSE file for details.

library toml.src.parser.util.whitespace;

import 'package:petitparser/petitparser.dart';

import 'package:toml/src/parser/util/join.dart';
import 'package:toml/src/parser/util/ranges.dart';

/// Parser for TOML whitespace.
///
///     ws = *wschar
final Parser<String> tomlWhitespace = tomlWhitespaceChar.star().join();

/// Parser for a single TOML whitepsace character.
///     wschar =  %x20  ; Space
///     wschar =/ %x09  ; Horizontal tab
final Parser<String> tomlWhitespaceChar =
    (char(' ') | char('\t')).cast<String>();

/// Parser for a TOML newline.
///
///     newline =  %x0A     ; LF
///     newline =/ %x0D.0A  ; CRLF
final Parser tomlNewline = char('\n') | char('\r') & char('\n');

/// A regular expression for [tomlNewline].
final RegExp tomlNewlinePattern = RegExp('\n|\r\n');

/// Parser for a TOML comment.
///
///     comment-start-symbol = %x23 ; #
///     comment = comment-start-symbol *non-eol
final Parser tomlComment = char('#') & tomlNonEol.star();

/// Parser for arbitrarily many [tomlWhitespaceChar]s, [tomlNewline]s and
/// [tomlComment]s.
///
///     ws-comment-newline = *( wschar / [ comment ] newline )
final Parser tomlWhitespaceCommentNewline =
    (tomlWhitespaceChar | tomlComment.optional() & tomlNewline).star();
