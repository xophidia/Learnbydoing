-module(cha_32).
-export([create/1, reverse_create/1, test/0]).
%Write a function that returns a list of the format [1,2,..,N-1,N].
%create(3)   [1,2,3].
%Write a function that returns a list of the format [N, N-1,..,2,1].
%reverse_create(3)   [3,2,1].


create(0) -> [];
create(L) when L > 0 -> create(L-1) ++ [L].


reverse_create(0) -> [];
reverse_create(L) when L > 0 -> [L | reverse_create(L-1)].


test() ->
  [1,2,3,4,5] = create(5),
  [5,4,3,2,1] = reverse_create(5),
  ok.
