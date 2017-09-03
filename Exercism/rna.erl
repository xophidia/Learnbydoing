-module(rna).
-export([calcul/1, to_rna/2, to_rna/1]).

to_rna(L) -> to_rna(L,[]).
to_rna([], Acc) -> lists:reverse(Acc);
to_rna([H|T], Acc)->
  to_rna(T, [calcul(H)|Acc]).


calcul(L) ->
  case L of
    71 -> 67;
    67 -> 71;
    84 -> 65;
    65 -> 85;
    _ -> io:format("erreur")
  end.

% rna:to_rna("ACGTGGTCTTAA").
% "UGCACCAGAAUU"
