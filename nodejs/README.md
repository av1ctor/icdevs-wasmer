# NodeJS and Motoko integration

1. Run: npm init
2. Run: npm run start

## Example code

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
