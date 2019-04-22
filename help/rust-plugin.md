# Rust Plugin

The rust plugin provides some extra niceties for using micro with
the Rust programming language. The main thing this plugin does is
run `rustfmt` or `cargo-fmt` for you automatically on save.

This plugin can run linter on save.

You can run commands anytime with ctrl e then `rustfmt`

To automatically run these when you save the file, use the following
options:

* `rust-plugin-onsave-fmt`: Toggle format checking on/off
* `rust-plugin-rustfmt-backup` use rustfmt backup file
* `rust-plugin-linter-clippy`:  use clippy as linter
* `rust-plugin-linter-cargo-check`: use cargo check as linter
* `rust-plugin-onsave-build`: Toggle build on/off
* `rust-plugin-tool-cargo-rustc`: use cargo if set to true or rustc if set to false
 
You can also press F6 (the default binding) to open a prompt to rename. 

You can rebind keys to the below commands in your `~/.config/micro/bindings.json` file

`rust.rustfmt`
`rust.cargofmt`
`rust.cargocheck`
`rust.cargoclippy`
