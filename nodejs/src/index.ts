import fs from "fs";
import {init, WASI} from '@wasmer/wasi';
import {MoHelper} from './motoko-helper';

/*
const mainFile = mo.file('main.mo');
mainFile.write(`
    var name: Text = "";

    module Main {
        public func sayHello(name_: Text): Text {
            name := name_;
            return "Hello, " # name;
        };

        public func getName(): Text {
            return name;
        };
    };

    ignore Main.sayHello("Joe");
    ignore Main.getName();
`);

const mainResult = mainFile.wasm('wasi');

fs.writeFile("./main.wasm", mainResult.wasm, () => null);
*/

(async () => {
    await init();

    const wasi = new WASI({});

    const module = await WebAssembly.compile(fs.readFileSync("./a-motoko-lib.wasm"));
    const instance = wasi.instantiate(module, {});
    wasi.start(instance);

    const exports = instance.exports as any;

    const helper = new MoHelper(exports);

    {
        const result = exports.sayHello(0, helper.stringToText("v1ctor"));
        console.log(`sayHello() = "${helper.textToString(result)}"`);
    }

    {
        const result = exports.getName(0);
        console.log(`getName() = "${helper.textToString(result)}"`);
    }

    
})();