-module(cha_33).
-export([print/1, print_even/1]).
%Write a function that prints out the integers between 1 and N. Hint: use io:format("Number:~p~n",[N]).
%Write a function that prints out the even integers between 1 and N.


print(0) -> ok;
print(N) when N >= 1 ->
  io:format("Number:~p~n",[N]),
  print(N-1);
print(_) -> erlang:error("mauvaise saisie").



print_even(N) when N >= 1 ->
  case (N rem 2) == 0 of
    true -> io:format("Number:~p~n",[N]);
    false -> io:format("")
  end,
  print_even(N-1);

print_even(0) -> io:format("Number:0");
print_even(_) -> erlang:error("mauvaise saisie").
