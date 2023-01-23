using System;
using System.Text;
using WasmerSharp;

namespace CsharpWasmer {
    public class MoHelper {
        Instance instance;

        private unsafe byte* GetBaseMem() {
            var memory = instance.Exports.First(e => e.Kind.Equals(ImportExportKind.Memory)).GetMemory();
            return (byte*)memory.Data.ToPointer();
        }

        public enum MoTag {
            BLOB = 17,
            CONCAT = 25,
        }

        struct MoObj {
            public MoTag tag;
        }

        struct MoBlob {
            public MoTag tag;
            public uint len;
        }

        struct MoConcat {
            public MoTag tag;
            public uint bytes;
            public uint text1;
            public uint text2;
        }

        public MoHelper(Instance instance) {
            this.instance = instance;
        }

        private static unsafe MoObj ToObj(uint* arr) {
            return new MoObj() { 
                tag = (MoTag)arr[0] 
            };
        }

        private static unsafe MoBlob ToBlob(uint* arr) {
            return new MoBlob() { 
                tag = (MoTag)arr[0],
                len = arr[1],
            };
        }

        private static unsafe MoConcat ToConcat(uint* arr) {
            return new MoConcat() { 
                tag = (MoTag)arr[0],
                bytes = arr[1],
                text1 = arr[2],
                text2 = arr[3],
            };
        }

        public unsafe string TextToString(
            uint skewedPtr
        ) {
            var ptr = GetBaseMem() + skewedPtr + 1;
            var obj = ToObj((uint*)ptr);
            switch(obj.tag) {
                case MoTag.BLOB:
                    var blob = ToBlob((uint*)ptr);
                    return Encoding.UTF8.GetString(ptr + sizeof(MoBlob), (int)blob.len);
                case MoTag.CONCAT:
                    var concat = ToConcat((uint*)ptr);
                    return TextToString(concat.text1) + TextToString(concat.text2);
                default:
                    return "";
            }
        }

        public unsafe uint StringToText(
            string s
        ) {
            var encoded = Encoding.UTF8.GetBytes(s);

            var res = instance.Call("alloc_blob", encoded.Length);
            if(res == null || res.Length == 0) { 
                return 0;
            }
            var skewedPtr = (uint)(int)res[0];

            var ptr = GetBaseMem() + skewedPtr + 1 + sizeof(MoBlob);
            for (var i = 0; i < encoded.Length; i++) {
                *ptr = encoded[i];
                ++ptr;
            }

            return skewedPtr;
        }
    }
}
