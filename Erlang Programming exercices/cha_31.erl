-module(cha_31).
-export([sum/1, sum/2, test/0]).


%Write a function sum/1 which, given a positive integer N, will return the sum of all the integers
%between 1 and N.

%Write a function sum/2 which, given two integers N and M, where N =< M, will return the sum
%of the interval between N and M. If N > M, you want your process to terminate abnormally.

sum(1) -> 1;
sum(N) when N > 1 -> N + sum(N - 1).


sum(N,N) -> N;
sum(N,M) when N =< M ->
  N + sum(N + 1, M);
sum(N,M) when N > M ->
  erlang:error("Valeurs incorrectes").

test() ->
  15 = sum(5),
  15 = sum(1,5),
  15 = sum(15,15),
  ok.
