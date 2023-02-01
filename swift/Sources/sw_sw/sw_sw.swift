import Foundation
import CWasmer

@main
public struct sw_sw {
    public static func main() {
        let helper = MotokoHelper();

        if let url = Bundle.main.url(forResource: "a-motoko-lib", withExtension: "wasm") {
            do {
                let data = try Data(contentsOf: url)
                data.withUnsafeBytes {(ubytes: UnsafeRawBufferPointer) in 
                    let bytes: UnsafeBufferPointer<wasm_byte_t> = ubytes.bindMemory(to: wasm_byte_t.self)

                    do {
                        try helper.load(bytes: bytes)
                        try helper.instanciate()
                        
                        let res = try helper.call(name: "greet", parms: [Int32(0), helper.stringToText(s: "v1ctor")])
                        print("Result from greet():", try helper.textToString(skewedPtr: res as! Int32))

                        print("Result from getMessage():", try helper.textToString(skewedPtr: helper.call(name: "getMessage", parms: [Int32(0)]) as! Int32))
                    }
                    catch {
                        print("Call failed")
                    }
                }
            }
            catch {
                print("Failed with exception")
            }
        }
        else {
            print("Wasm not found")
        }
    }
}
