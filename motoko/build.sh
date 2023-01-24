#!/bin/bash
~/.cache/dfinity/versions/0.12.0/moc -wasi-system-api a-motoko-lib.mo
~/wabt/bin/wasm2wat a-motoko-lib.wasm |
    sed '/(start $link_start.1)/i (export "alloc_blob" (func $alloc_blob)) (export "getMessage" (func $getMessage)) (export "greet" (func $greet))' >temp0.wat
~/wabt/bin/wat2wasm temp0.wat -o a-motoko-lib.wasm
rm temp0.wat
~/binaryen/bin/wasm2js a-motoko-lib.wasm |
    sed "s/import \* as wasi_unstable from 'wasi_unstable';/const wasi_unstable = {fd_write: (a1, a2, a3, a4) => 0};/" |
    sed 's/"memory": Object.create(Object.prototype, {/"memory": ({/' >a-motoko-lib.js
cp a-motoko-lib.wasm ../nodejs
cp a-motoko-lib.wasm ../csharp
cp a-motoko-lib.js ../react-native
