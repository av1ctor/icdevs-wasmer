import Foundation
import CWasmer

enum MoTag: Int32 {
    case blob = 17, concat = 25, other
}

struct MoObj {
    let tag: MoTag
}

struct MoBlob {
    let tag: MoTag
    let len: Int32
}

struct MoConcat {
    let tag: MoTag
    let bytes: Int32
    let text1: Int32
    let text2: Int32
}

struct Exports {
    let memory: OpaquePointer?
    let functions: [String:OpaquePointer]
}

private func toObj(mem: UnsafeMutablePointer<Int8>) throws -> MoObj {
    let ptr = UnsafePointer<Int32>(OpaquePointer(mem));
    return MoObj(tag: MoTag(rawValue: ptr[0])!)
}

private func toBlob(mem: UnsafeMutablePointer<Int8>) -> MoBlob {
    let ptr = UnsafePointer<Int32>(OpaquePointer(mem));
    return MoBlob(tag: MoTag(rawValue: ptr[0])!, len: ptr[1])
}

private func toConcat(mem: UnsafeMutablePointer<Int8>) -> MoConcat {
    let ptr = UnsafePointer<Int32>(OpaquePointer(mem));
    return MoConcat(tag: MoTag(rawValue: ptr[0])!, bytes: ptr[1], text1: ptr[2], text2: ptr[3])
}

public class MotokoHelper {
    let engine: OpaquePointer
    let store: OpaquePointer
    var module: OpaquePointer?
    var instance: OpaquePointer?
    var exports: Exports?

    init() {
        engine = wasm_engine_new()
        store = wasm_store_new(engine)
    }

    deinit {
        if let instance = instance {
            wasm_instance_delete(instance)
        }
        if let module = module {
            wasm_module_delete(module)
        }
        wasm_store_delete(store)
        wasm_engine_delete(engine)
    }

    enum LoadError: Error {
        case invalid
    }

    func load(bytes: UnsafeBufferPointer<wasm_byte_t>) throws {
        let vec = wasm_byte_vec_t(size: bytes.count, data: UnsafeMutablePointer(mutating: bytes.baseAddress))
        module = wasm_module_new(store, withUnsafePointer(to: vec) {UnsafePointer($0)})
        if module == nil {
            throw LoadError.invalid
        }
    }

    enum InstanceError: Error {
        case invalid
    }

    func instanciate() throws {
        let config = wasi_config_new("Motoko")
        let env = wasi_env_new(store, config)
        var imports = wasm_extern_vec_t(size: 0, data: nil)

        wasi_get_imports(store, env, module, withUnsafeMutablePointer(to: &imports) {UnsafeMutablePointer($0)})

        instance = wasm_instance_new(
            store, 
            module, 
            withUnsafePointer(to: imports) {UnsafePointer($0)}, 
            nil);

        if instance == nil {
            throw InstanceError.invalid
        }

        buildExports()
    }

    func buildExports() {
        var exp = wasm_extern_vec_t();
        wasm_instance_exports(instance, withUnsafeMutablePointer(to: &exp) {UnsafeMutablePointer($0)})

        var modExps: wasm_exporttype_vec_t = wasm_exporttype_vec_t()
        wasm_module_exports(module, withUnsafeMutablePointer(to: &modExps) {UnsafeMutablePointer($0)})
        
        var memory: OpaquePointer? = nil
        var funcs: [String:OpaquePointer] = [:]

        for i in 0..<exp.size {
            switch(wasm_extern_kind(exp.data[i])) {
                case UInt8(WASM_EXTERN_FUNC.rawValue):
                    let name = getExportedName(exp: modExps, index: i)
                    funcs[name] = wasm_extern_as_func(exp.data[i])
                    break;
                case UInt8(WASM_EXTERN_MEMORY.rawValue):
                    memory = wasm_extern_as_memory(exp.data[i])
                    break;
                default:
                    break;
            }
        }

        self.exports = Exports(memory: memory, functions: funcs)
    }

    private func getExportedName(exp: wasm_exporttype_vec_t, index: Int) -> String {
        let ename = wasm_exporttype_name(exp.data[index])
        if ename != nil {
            let s: String? = String(bytes: Data(bytes: ename!.pointee.data!, count: ename!.pointee.size), encoding: .utf8)
            return s ?? ""
        }

        return ""
    }

    enum CallError: Error {
	    case invalidType
        case failed
	}

    private func toWasmVal(parm: Any, val: inout wasm_val_t) throws {
        if let arg = parm as? Int32 {
            val.kind = UInt8(WASM_I32.rawValue)
            val.of.i32 = arg
        }
        else if let arg = parm as? Int64 {
            val.kind = UInt8(WASM_I64.rawValue)
            val.of.i64 = arg
        }
        else if let arg = parm as? Float32 {
            val.kind = UInt8(WASM_F32.rawValue)
            val.of.f32 = arg
        }
        else if let arg = parm as? Float64 {
            val.kind = UInt8(WASM_F64.rawValue)
            val.of.f64 = arg
        }
        else {
            throw CallError.invalidType
        }
    }

    private func fromWasmVal(val: wasm_val_t) -> Any? {
        switch UInt32(val.kind) {
            case WASM_I32.rawValue:
                return val.of.i32
            case WASM_I64.rawValue:
                return val.of.i64
            case WASM_F32.rawValue:
                return val.of.f32
            case WASM_F64.rawValue:
                return val.of.f64
            default:
                return nil
        }
    }

    func call(name: String, parms: [Any]) throws -> Any? {
        let function = exports!.functions[name]!
        
        // alloc results
        var results = wasm_val_vec_t()
        wasm_val_vec_new_uninitialized(withUnsafeMutablePointer(to: &results) {UnsafeMutablePointer($0)}, 1)
        
        defer {
            wasm_val_vec_delete(withUnsafeMutablePointer(to: &results) {UnsafeMutablePointer($0)})
        }

        // alloc and convert arguments
        var args = wasm_val_vec_t()
        wasm_val_vec_new_uninitialized(withUnsafeMutablePointer(to: &args) {UnsafeMutablePointer($0)}, parms.count)

        defer {
            wasm_val_vec_delete(withUnsafeMutablePointer(to: &args) {UnsafeMutablePointer($0)})
        }

        for i in 0..<parms.count {
            try toWasmVal(parm: parms[i], val: &args.data[i])
        }

        // invoke function
        let trap = wasm_func_call(
            function, 
            withUnsafePointer(to: args) {UnsafePointer($0)}, 
            withUnsafeMutablePointer(to: &results) {UnsafeMutablePointer($0)})

        if trap != nil {
            throw CallError.failed
        }

        // convert results
        if results.size == 0 {
            return nil
        }
        
        return fromWasmVal(val: results.data[0])
    }

    private func allocBlob(bytes: Int32) throws -> Int32 {
        let res = try call(name: "alloc_blob", parms: [bytes])
        return res as! Int32
    }

    func textToString(skewedPtr: Int32) throws -> String {
        let ptr = skewedPtr + 1;
        let mem = wasm_memory_data(exports!.memory)!.advanced(by: Int(ptr))
        let obj = try toObj(mem: mem)
        switch(obj.tag) {
            case .blob:
                let blb = toBlob(mem: mem)
                let bytes = mem.advanced(by: 8)
                return String(bytes: Data(bytes: UnsafeRawPointer(bytes), count: Int(blb.len)), encoding: .utf8) ?? ""
            case .concat:
                let conc = toConcat(mem: mem)
                return try textToString(skewedPtr: conc.text1) + textToString(skewedPtr: conc.text2)
            default:
                return ""
        }
    }

    func stringToText(s: String) throws -> Int32 {
        let encoded: [UInt8] = Array(s.utf8)
        let skewedPtr = try allocBlob(bytes: Int32(encoded.count))
        let ptr = skewedPtr + 1

        let mem = wasm_memory_data(exports!.memory)!.advanced(by: Int(ptr + 8))
        for i in 0..<encoded.count {
            mem[i] = Int8(encoded[i])
        }

        return skewedPtr
    }
}