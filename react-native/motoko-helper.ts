/* eslint-disable prettier/prettier */
import { TextEncoder, TextDecoder } from 'text-decoding';

type Memory = {
  buffer: {
    get: () => ArrayBuffer;
  };
};

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

const utf8Decoder = new TextDecoder('utf-8');
const utf8Encoder = new TextEncoder();

function toObj(arr: Uint32Array): MoObj {
  return {
    tag: arr[0],
  };
}

function toBlob(arr: Uint32Array): MoBlob {
  return {
    tag: arr[0],
    len: arr[1],
  };
}

function toConcat(arr: Uint32Array): MoConcat {
  return {
    tag: arr[0],
    bytes: arr[1],
    text1: arr[2],
    text2: arr[3],
  };
}

export class MoHelper {
  memory: Memory;
  allocBlob: (bytes: number) => number;

  constructor(exports: any) {
    this.memory = exports.memory;
    this.allocBlob = exports.alloc_blob;
  }

  textToString(skewedPtr: number): string {
    const ptr = skewedPtr + 1;
    const arr = new Uint32Array(this.memory.buffer.get(), ptr);
    const obj = toObj(arr);
    switch (obj.tag) {
      case MoTag.BLOB:
        const blob = toBlob(arr);
        const bytes = new Uint8Array(this.memory.buffer.get(), ptr + 8, blob.len);
        return utf8Decoder.decode(bytes);
      case MoTag.CONCAT:
        const concat = toConcat(arr);
        return (
          this.textToString(concat.text1) + this.textToString(concat.text2)
        );
      default:
        return '';
    }
  }

  stringToText(s: string): number {
    const encoded = utf8Encoder.encode(s);

    const skewedPtr = this.allocBlob(encoded.length);
    const ptr = skewedPtr + 1;

    const bytes = new Uint8Array(this.memory.buffer.get(), ptr + 8);
    for (let i = 0; i < encoded.length; i++) {
      bytes[i] = encoded[i];
    }

    return skewedPtr;
  }
}
