using System.Text;
using WasmerSharp;

namespace CsharpWasmer {
    public class MoHelper {
        Module? module;
        Instance? instance;

        private unsafe byte* GetBaseMem() {
            var memory = instance?.Exports.First(e => e.Kind.Equals(ImportExportKind.Memory)).GetMemory();
            if(memory == null) {
                return null;
            }
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
            public int len;
        }

        struct MoConcat {
            public MoTag tag;
            public int bytes;
            public int text1;
            public int text2;
        }

        public MoHelper() {
        }

        delegate int FdWriteDel (InstanceContext ctx, int p0, int p1, int p2, int p3);
        private static int FdWrite(InstanceContext ctx, int p0, int p1, int p2, int p3) {
            return 0;
        }

        public bool Load(byte[] wasm) {
            module = Module.Create(wasm);
            if(module == null) {
                return false;
            }

            return true;
        }

        public bool Instanciate() {
            var import = new Import("wasi_unstable", "fd_write", new ImportFunction((FdWriteDel)(FdWrite)));

            instance = module?.Instatiate(import);
            if(instance == null) {
                return false;
            }

            return true;
        }

        public object[] Call(
            String name, 
            params object[] args
        ) {
            return instance?.Call(name, args) ?? Array.Empty<object>();
        }

        private static unsafe MoObj ToObj(int* arr) {
            return new MoObj() { 
                tag = (MoTag)arr[0] 
            };
        }

        private static unsafe MoBlob ToBlob(int* arr) {
            return new MoBlob() { 
                tag = (MoTag)arr[0],
                len = arr[1],
            };
        }

        private static unsafe MoConcat ToConcat(int* arr) {
            return new MoConcat() { 
                tag = (MoTag)arr[0],
                bytes = arr[1],
                text1 = arr[2],
                text2 = arr[3],
            };
        }

        public unsafe string TextToString(
            int skewedPtr
        ) {
            var ptr = GetBaseMem() + skewedPtr + 1;
            var obj = ToObj((int*)ptr);
            switch(obj.tag) {
                case MoTag.BLOB:
                    var blob = ToBlob((int*)ptr);
                    return Encoding.UTF8.GetString(ptr + sizeof(MoBlob), blob.len);
                case MoTag.CONCAT:
                    var concat = ToConcat((int*)ptr);
                    return TextToString(concat.text1) + TextToString(concat.text2);
                default:
                    return "";
            }
        }

        public unsafe int StringToText(
            string s
        ) {
            var encoded = Encoding.UTF8.GetBytes(s);

            var res = instance?.Call("alloc_blob", encoded.Length);
            if(res == null || res.Length == 0) { 
                return 0;
            }
            var skewedPtr = (int)res[0];

            var ptr = GetBaseMem() + skewedPtr + 1 + sizeof(MoBlob);
            for (var i = 0; i < encoded.Length; i++) {
                *ptr = encoded[i];
                ++ptr;
            }

            return skewedPtr;
        }
    }
}
