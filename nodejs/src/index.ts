import fs from "fs";
import {MoHelper} from './motoko-helper';

(async () => {
    const helper = new MoHelper();
    
    const wasm = fs.readFileSync("./a-motoko-lib.wasm")
    if(!await helper.load(wasm)) {
        console.error("Invalid file");
        return;
    };

    if(!helper.instanciate()) {
        console.error("Invalid module");
        return;
    }

    {
        const result = helper.call('greet', 0, helper.stringToText("v1ctor"));
        console.log(`greet() = "${helper.textToString(result)}"`);
    }

    {
        const result = helper.call('getMessage', 0);
        console.log(`getMessage() = "${helper.textToString(result)}"`);
    }

    
})();