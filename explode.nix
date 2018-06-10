#
# Nix expression - explode a string
#
#
# Copyright 2018, Philippe Gregoire <pg@pgregoire.xyz>
#
# Permission to use, copy, modify, and/or distribute this software for
# any purpose with or without fee is hereby granted, provided that the
# above copyright notice and this permission notice appear in all
# copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
# DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
# PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
# TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#

pat: str:
let
    inherit (builtins) filter foldl' map stringLength substring;

    len = stringLength pat;
    max = stringLength str;

    explode' = i: x: y:
        if i >= max
        then y ++ [x]
        else if pat == (substring i len str)
             then explode' (i + 1) [] (y ++ [x])
             else explode' (i + 1) (x ++ [(substring i 1 str)]) y;

    implode = xs:
        foldl' (a: b: a + b) "" xs;
        
in
    if 0 == len
    then map (i: substring i 1 str) (builtins.genList (i: i) max)
    else map (e: implode e) (filter (e: [] != e) (explode' 0 [] []))
