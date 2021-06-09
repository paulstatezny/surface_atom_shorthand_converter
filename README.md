# SurfaceAtomShorthandConverter

A tool for converting [Surface](https://hex.pm/packages/surface) `< 0.4`
"shorthand atom syntax" into standard non-deprecated atom syntax.

This:

```html
<SomeComponent atom_prop="warning">
```

is turned into this:

```html
<SomeComponent atom_prop={{ :warning }}>
```

## Usage

**You must have Surface version `0.4.*` installed as the mix task relies on the warnings it generates.**

Install the package by adding the following to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:surface_atom_shorthand_converter, "~> 0.1.0",
     github: "paulstatezny/surface_atom_shorthand_converter", ref: "master"},
  ]
end
```

Then, in the project root, run:

```
mix surface.convert_atom_string_shorthand
```

### How it works

The mix task does the following:

1. Runs `mix compile --force --warnings-as-errors`.
1. Reads and parses `stderr` to find Surface code in the deprecated style.
1. Updates the code according to each warning.

### Rare caveat

If you have any macros that generate Surface code, the warnings will not
contain the correct line number and the mix task will not be able to repair
them.


## License

Copyright (c) 2021, Paul Statezny.

This source code is licensed under the [MIT License](LICENSE.md).
