# libfive-d

D bindings and an idiomatic wrapper of [libfive](https://github.com/libfive/libfive/tree/master),
a library and set of tools for solid modeling, especially suited for parametric
and procedural design.

<!-- TODO: Upstream these bindings to subprojects/libfive/libfive/stdlib -->

## Development

### Windows

1. Install [Chocolatey](https://chocolatey.org/install)
2. Install GNU make:
    ```sh
    choco install -y make
    ```
3. Build the [libfive dependency](https://github.com/libfive/libfive/tree/master#windows-vs2019):
    ```sh
    make libfive
    ```
