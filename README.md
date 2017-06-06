# Varint

A library to compress integers using LEB128.

## Installation

  1. Add `varint` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:varint, "~> 1.0.0"}]
    end
    ```

  2. Ensure `varint` is started before your application:

    ```elixir
    def application do
      [applications: [:varint]]
    end
    ```

## Usage

### LEB128

Comes with a unsigned and signed compression

#### ULEB128

```elixir
iex> Varint.ULEB128.encode(300)
<<172, 2>>

iex> Varint.ULEB128.decode(<<172, 2>>)
{300, <<>>}
```

#### SLEB128

```elixir
iex> Varint.SLEB128.encode(-129)
<<255, 126>>

iex> Varint.SLEB128.decode(<<255, 126>>)
{-129, <<>>}
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
