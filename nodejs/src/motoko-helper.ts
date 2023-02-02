import {init, WASI} from '@wasmer/wasi';

export enum MoTag {
    BLOB = 17,
    CONCAT = 25,
}

export interface MoObj {
    tag: MoTag;
}

export interface MoBlob {
    tag: MoTag;
    len: number;
}

export interface MoConcat {
    tag: MoTag;
    bytes: number;
    text1: number;
    text2: number;
}

const utf8Decoder = new TextDecoder("utf8");
const utf8Encoder = new TextEncoder();

function toObj(
    arr: Uint32Array
): MoObj {
    return {
        tag: arr[0],
    };
}

function toBlob(
    arr: Uint32Array
): MoBlob {
    return {
        tag: arr[0],
        len: arr[1],
    };
}

function toConcat(
    arr: Uint32Array
): MoConcat {
    return {
        tag: arr[0],
        bytes: arr[1],
        text1: arr[2],
        text2: arr[3],
    };
}

export class MoHelper {
    wasi?: WASI;
    module?: WebAssembly.Module;
    instance?: WebAssembly.Instance;
    memory: WebAssembly.Memory = {} as any;
    allocBlob: (bytes: number) => number = () => 0;
    
    constructor() {
    }

    async load(
        wasm: Buffer
    ): Promise<boolean> {
        await init();

        this.wasi = new WASI({});
    
        this.module = await WebAssembly.compile(wasm);

        return !!this.module;
    }

    instanciate(
    ): boolean {
        this.instance = this.wasi?.instantiate(this.module, {});
        if(!this.instance) {
            return false;
        }
        this.wasi?.start(this.instance);
        this.memory = this.instance.exports.memory as any;
        this.allocBlob = this.instance?.exports.alloc_blob as any;
        return true;
    }

    call(name: string, ...args: any[]): any {
        const func = this.instance?.exports[name] as any;
        return func(...args);
    }

    textToString(
        skewedPtr: number
    ): string {
        const ptr = skewedPtr + 1;
        const arr = new Uint32Array(this.memory.buffer, ptr);
        const obj = toObj(arr);
        switch(obj.tag) {
            case MoTag.BLOB:
                const blob = toBlob(arr);
                const bytes = new Uint8Array(this.memory.buffer, ptr + 8, blob.len);
                return utf8Decoder.decode(bytes);
            case MoTag.CONCAT:
                const concat = toConcat(arr);
                return this.textToString(concat.text1) + this.textToString(concat.text2);
            default:
                return "";
        }
    }

    stringToText(
        s: string
    ): number {
        const encoded = utf8Encoder.encode(s);
        
        const skewedPtr = this.allocBlob(encoded.length);
        const ptr = skewedPtr + 1;
        
        const bytes = new Uint8Array(this.memory.buffer, ptr + 8);
        for(let i = 0; i < encoded.length; i++) {
            bytes[i] = encoded[i];
        }
        
        return skewedPtr;
    }
}
