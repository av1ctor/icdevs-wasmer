1. Install WABT (https://github.com/WebAssembly/wabt/releases/) to ~/wabt (or build it if the GLIBC is different, see the readme at https://github.com/WebAssembly/wabt)
2. Install Bynarien (https://github.com/WebAssembly/binaryen/releases) to ~/binaryen
3. Run build.sh

Notes:
1. moc (the Motoko compiler) must be invoked with the -wasi-system-api option
2. It's not possible to load an actor with Wasmer due the imported functions that are needed (from the IC replica) and because Wasmer only loads WASI modules when at least a WASI function is imported
3. There's no way at moment to force moc to emit all public functions when they are not used, so they have to be called at the main block or moc will skip them
