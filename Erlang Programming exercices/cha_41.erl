-module(cha_41).
-export([start/0, print/1, stop/0, loop/0]).

% Write the server in Figure 4-16 that will wait in a receive loop
% until a message is sent to it. Depending on the message, it should
% either print its contents and loop again, or terminate. You want
% to hide the fact that you are dealing with a process, and access
% its services through a functional interface, which you can call from the shell.


start() ->
  register(echo, spawn(?MODULE, loop, [])),
  ok.

loop() ->
  receive
    {print, Term} ->
      io:format("~n~p", [Term]),
      loop();
    stop ->
      true;
    _ ->
      {error, message_erreur}
  end.


print(Term) ->
  echo ! {print, Term},
  ok.

stop() ->
  echo ! {self(), stop},
  ok.
