# Rust Plugin

The rust plugin provides some extra niceties for using micro with
the Rust programming language. The main thing this plugin does is
run `rustfmt` or `cargo-fmt` for you automatically on save.

This plugin can run linter on save.

You can run commands anytime with ctrl e then `rustfmt`

To automatically run these when you save the file, use the following
options:

* `rust-plugin-onsave-fmt`        : Toggle format checking on/off
* `rust-plugin-rustfmt-backup`    : use rustfmt backup file
* `rust-plugin-linter-clippy`     : Use clippy as linter
* `rust-plugin-linter-cargo-check`: Use cargo check as linter
* `rust-plugin-onsave-build`      : Toggle build on/off
* `rust-plugin-tool-cargo-rustc`  : Use cargo if option is set to true or use rustc if option set to false
 
You can also press F6 (the default binding) to open a prompt to rename. 

You can bind or rebind keys to the below commands in your micro key bindings file `~/.config/micro/bindings.json`

* `rust.rustfmt`       : Format current file
* `rust.cargofmt`      : Format project code
* `rust.cargocheck`    : Check project with cargo-check
* `rust.cargoclippy`   : Check project with clippy
* `rust.rustc`         : Check current file 
* `rust.rustInfo`      : Display Info about rust-plugin in the log window

## Example of binding Keys

Bind the key `F6` to rust-plugin to run `rustfmt` command when `F6` is pressed.

Add this to your micro bindigs file `~/.config/micro/bindings.json`

```
BindKey("F6", "rust.rustfmt")
```
