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
