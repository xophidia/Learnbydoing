-module(cha_34).
-export([new/0, destroy/1, write/3, delete/2, read/2, test/0, match/2]).
-author([xophidia]).

% Write a module db.erl that creates a database and is able to store, retrieve, and delete elements in it.
% The destroy/1 function will delete the database.
% Considering that Erlang has garbage collection, you do not need to do anything. Had the db module
% stored everything on file, however, you would delete the file. We are including the destroy function
% to make the interface consistent. You may not use the lists library module, and you have to implement
% all the recursive functions yourself.

% Hint: use lists and tuples as your main data structures. When testing your program, remember that Erlang variables are single-assignment:
% Interface:
% db:new()
% db:destroy(Db)
% db:write(Key, Element, Db)
% db:delete(Key, Db)
% db:read(Key, Db)
% db:match(Element, Db)

% Example:
% 1> c(db). {ok,db}
% 2> Db = db:new().
% []
% 3> Db1 = db:write(francesco, london, Db). [{francesco,london}]
% 4> Db2 = db:write(lelle, stockholm, Db1). [{lelle,stockholm},{francesco,london}]
% 5> db:read(francesco, Db2).
% {ok,london}
% 6> Db3 = db:write(joern, stockholm, Db2).
% [{joern,stockholm},{lelle,stockholm},{francesco,london}]
% 7> db:read(ola, Db3).
% {error,instance}
% 8> db:match(stockholm, Db3).
% [joern,lelle]
% 9> Db4 = db:delete(lelle, Db3).
% [{joern,stockholm},{francesco,london}]
% 10> db:match(stockholm, Db4).
% [joern]


new() -> [].
destroy([_|_]) -> [].
write(Key, Element, Db) -> [{Key, Element}| delete(Key,Db)].

delete(Key, [{Key,_}|T]) -> T;
delete(Key, [H|T]) -> [H|delete(Key, T)];
delete(_,[]) -> [].

read(Key, [{Key, Value}|_]) -> {ok, Value};
read(Key, [{_,_}|T]) -> read(Key, T);
read(_, []) -> {error, instance}.

match(Element, [{Key,Element}|T]) -> [Key | match(Element, T)];
match(Element, [{_,_}|T]) -> match(Element, T);
match(_, []) -> [].


test() ->
  [] = Db = cha_34:new(),
  [{francesco, london}] = Db1 = cha_34:write(francesco, london, Db),
  [{lelle, stockholm}, {francesco, london}] = Db2 = cha_34:write(lelle, stockholm, Db1),
  {ok, london} = cha_34:read(francesco, Db2),
  [{joern, stockholm}, {lelle, stockholm}, {francesco, london}] = Db3 = cha_34:write(joern, stockholm, Db2),
  {error, instance} = cha_34:read(ola, Db3),
  [joern, lelle] = cha_34:match(stockholm, Db3),
  [{joern, stockholm}, {francesco, london}] = Db4 = cha_34:delete(lelle, Db3),
  [{francesco, prague}, {joern, stockholm}] = cha_34:write(francesco, prague, Db4),
  [joern] = cha_34:match(stockholm, Db4),
  ok.
