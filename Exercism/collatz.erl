-module(collatz).
-export([collatz/2, collatz/1]).

%% http://exercism.io/exercises/erlang/collatz-conjecture
%% Xophidia - 2017

collatz(X) -> collatz(X,0).

collatz(X, Acc) when X rem 2 =:= 0 andalso X > 1 ->
  collatz(trunc(X / 2), Acc + 1);
collatz(X, Acc) when X rem 2 =/= 0 andalso X > 1 ->
  collatz(trunc(X * 3 + 1), Acc + 1);
collatz(X, Acc) when X =:= 1 -> io:format("~nRésultat => ~p", [Acc]).

%collatz:collatz(1000000).
%Résultat => 152
%collatz:collatz(12).
%Résultat => 9
