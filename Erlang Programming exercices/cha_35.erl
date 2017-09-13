-module(cha_35).
-export([filter/2, test/0, reverse/1, concatenate/1]).
-author("xophidia").

% Write a function that, given a list of integers and an integer, will return all integers smaller than or equal to that integer.
% Example:
% filter([1,2,3,4,5], 3)   [1,2,3].
% Write a function that, given a list, will reverse the order of the elements.
% Example:
% reverse([1,2,3])   [3,2,1].
% Write a function that, given a list of lists, will concatenate them.
% Example:
% concatenate([[1,2,3], [], [4, five]])   [1,2,3,4,five].
% Hint: you will have to use a help function and concatenate the lists in several steps.
% Write a function that, given a list of nested lists, will return a flat list.
% Example:
% flatten([[1,[2,[3],[]]], [[[4]]], [5,6]])   [1,2,3,4,5,6]. Hint: use concatenate to solve flatten.

filter([H|T],A) when H =< A ->
  [H|filter(T, A)];
filter(_,_) -> [].

reverse([H|T]) ->
  reverse(T) ++ [H];
reverse([]) -> [].

concatenate([]) -> [];
concatenate([H|T]) ->
  H ++ concatenate(T).

% flatten

test() ->
  [1,2,3] = filter([1,2,3,4,5], 3),
  [3,2,1] = reverse([1,2,3]),
  [1,2,3,4,five] = concatenate([[1,2,3], [], [4, five]]),
  ok.
