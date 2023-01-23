#!/bin/bash
~/.cache/dfinity/versions/0.12.0/moc -wasi-system-api a-motoko-lib.mo
~/wabt/bin/wasm2wat a-motoko-lib.wasm -o temp.wat
sed '/(start $link_start.1)/i (export "alloc_blob" (func $alloc_blob)) (export "getMessage" (func $getMessage)) (export "greet" (func $greet))' temp.wat >a-motoko-lib.wat
rm temp.wat
~/wabt/bin/wat2wasm a-motoko-lib.wat -o a-motoko-lib.wasm
rm a-motoko-lib.wat
cp a-motoko-lib.wasm ../nodejs
cp a-motoko-lib.wasm ../csharp
