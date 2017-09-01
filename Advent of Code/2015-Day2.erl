-module(day2_2015).
-export([
  chall/1,
  chall2/1,
  open/1,
  trans/1,
  tr/2,
  work/2
  ]).

%% open file and create token

open(Filename) ->
  {ok, Bin} = file:read_file(Filename),
   S = string:lexemes(binary_to_list(Bin), "\r\n"),
   work(S,[]).

%% main part

work([], Acc) -> lists:sum(Acc);
work([H|T], Acc) ->
  Temp = string:split(H, "x", all),
  V = tr(Temp,[]),
  work(T, [chall2(V) | Acc]).

%% Split and convert String to Integer

trans([H|_]) ->
  Temp = string:split(H, "x", all),
  tr(Temp,[]).

tr([], Acc) -> lists:reverse(Acc);
tr([H|T], Acc) when is_list(H) ->
  {Int,_} = string:to_integer(H),
  tr(T, [ Int | Acc]).

%% chall part 1

chall([L,W,H]) ->
  One = 2 * lists:foldl(fun(X, Acc) -> X * Acc end, 1, [L,W]),
  Two = 2 * lists:foldl(fun(X, Acc) -> X * Acc end, 1, [W,H]),
  Three = 2 * lists:foldl(fun(X, Acc) -> X * Acc end, 1, [L,H]),
  Slack = lists:foldl(fun(X, Acc) -> X * Acc end, 1, lists:sublist(lists:sort([L,W,H]),1,2)),
  One + Two + Three + Slack.

%% chall part 2

chall2([L,W,H]) ->
  One = lists:foldl(fun(X, Acc) -> X + X + Acc end, 0, lists:sublist(lists:sort([L,W,H]),1,2)),
  Two = lists:foldl(fun(X, Acc) -> X * Acc end, 1, [L,W,H]),
  One + Two.
