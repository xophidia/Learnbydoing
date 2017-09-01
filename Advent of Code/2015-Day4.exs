# Day4 - Elixir
# Xophidia
# based on Mark Olson's code

defmodule Crypto do
    def md5(data) do
        Base.encode16(:erlang.md5(data), case: :lower)
    end
end

defmodule Launcher do
    def isValid(data) do
        String.match?(Crypto.md5(data), ~r/^00000/)
    end

    def exec,do: exec(0)
    def exec(i) do
        key = "ckczppom"
        IO.puts i
        unless isValid("#{key}#{i}"), do: exec(i+1)
    end
end

Launcher.exec()