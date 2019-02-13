# Rust Plugin

The rust plugin provides some extra niceties for using micro with
the Rust programming language. The main thing this plugin does is
run `rustfmt` or `cargo-fmt` for you automatically. 

Runs linter for you.

You can run

```
> rustfmt
```

To automatically run these when you save the file, use the following
options:

* `rust-plugin-rustfmt`: run rustfmt on file saved. Default value: `on`
* `rust-plugin-backup`: run rustfmt on file saved and backup old file. Default value: `off`
* `rust-plugin-cargofmt`: run cargo-fmt on project. Default value: `off`
* `rust-plugin-rustclippy`: run cargo-clippy on project. Default value: `off`

You can also press F6 (the default binding) to open a prompt to rename. 

You can rebind this in your `bindings.json` file with the action's below

`rust.rustfmt`
`rust.cargofmt`
`rust.cargocheck`
`rust.cargoclippy`
