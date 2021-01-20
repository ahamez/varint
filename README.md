# Varint

![Elixir CI](https://github.com/ahamez/varint/workflows/Elixir%20CI/badge.svg) [![Coverage Status](https://coveralls.io/repos/github/ahamez/varint/badge.svg?branch=master)](https://coveralls.io/github/ahamez/varint?branch=master) ![Hex.pm](https://img.shields.io/hexpm/v/varint)

A library to compress integers using [LEB128](https://en.wikipedia.org/wiki/LEB128).

## Installation

Add `varint` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:varint, "~> x.x.x"}]
end
```

## Usage

### LEB128

```elixir
iex> Varint.LEB128.encode(300)
<<172, 2>>
```

```elixir
iex> Varint.LEB128.decode(<<172, 2>>)
{300, <<>>}
```

### Zigzag

```elixir
iex> Varint.Zigzag.encode(-2)
3
```

```elixir
iex> Varint.Zigzag.decode(3)
-2
```

You'll find detailed instructions at [hexdocs.pm](https://hexdocs.pm/varint).
