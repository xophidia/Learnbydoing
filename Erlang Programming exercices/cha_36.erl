-module(cha_36).
-export([quicksort/1, test/0, merge/2, mergesort/1, len/1]).
-author("xophidia").

% Quicksort
% The head of the list is taken as the pivot; the list is then split according
% to those elements smaller than the pivot and the rest. These two lists are then
% recursively sorted by quicksort, and joined together, with the pivot between them.

quicksort([]) -> [];
quicksort([H|T]) ->
  quicksort([X || X <- T, X =< H])
   ++ [H] ++
   quicksort([X || X <- T, X > H]).


% Merge sort
% The list is split into two lists of (almost) equal length. These are then sorted
% separately and their results merged in order.
len([])-> 0;
len([_|T]) -> 1 + len(T).
mergesort([]) -> [];
mergesort([X]) -> [X];
mergesort(L) ->
  {Left, Right} = lists:split(trunc(len(L)/2), L),
  merge(mergesort(Left), mergesort(Right)).

merge([], Right) -> Right;
merge(Left, []) -> Left;
merge([H | T] = Left, [Hb | Tb] = Right) ->
  case H =< Hb of
    true -> [H | merge(T, Right)];
    false -> [Hb | merge(Left, Tb)]
  end.


test() ->
  [1,2,3,4,5] = quicksort([4,1,3,2,5]),
  [1,2,3,4,5] = mergesort([4,1,3,2,5]),
  ok.
