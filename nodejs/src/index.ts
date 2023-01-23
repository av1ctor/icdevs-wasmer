import fs from "fs";
import {init, WASI} from '@wasmer/wasi';
import {MoHelper} from './motoko-helper';

(async () => {
    await init();

    const wasi = new WASI({});

    const module = await WebAssembly.compile(fs.readFileSync("./a-motoko-lib.wasm"));
    const instance = wasi.instantiate(module, {});
    wasi.start(instance);

    const exports = instance.exports as any;

    const helper = new MoHelper(exports);

    {
        const result = exports.greet(0, helper.stringToText("v1ctor"));
        console.log(`greet() = "${helper.textToString(result)}"`);
    }

    {
        const result = exports.getMessage(0);
        console.log(`getMessage() = "${helper.textToString(result)}"`);
    }

    
})();