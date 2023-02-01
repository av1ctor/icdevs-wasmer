//
//  ContentView.swift
//  sf_ws
//
//  Created by andré victor on 30/01/23.
//

import SwiftUI
import CWasmer

struct ContentView: View {
    @State private var name = ""
    @State private var showingAlert = false
    @State private var alertText = ""
    private let helper = MotokoHelper()
    
    init() {
        if let url = Bundle.main.url(forResource: "a-motoko-lib", withExtension: "wasm") {
            do {
                let data = try Data(contentsOf: url)
                data.withUnsafeBytes {(ubytes: UnsafeRawBufferPointer) in
                    let bytes: UnsafeBufferPointer<wasm_byte_t> = ubytes.bindMemory(to: wasm_byte_t.self)

                    do {
                        try helper.load(bytes: bytes)
                        try helper.instanciate()
                        
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
    
    func greet() {
        do {
            let res = try helper.call(name: "greet", parms: [Int32(0), helper.stringToText(s: name)])
            alertText = try "Result from greet():" + helper.textToString(skewedPtr: res as! Int32)
            showingAlert = true
        }
        catch {
            print("Call to greet() failed")
        }
    }
    
    func getMessage() {
        do {
            alertText = try "Result from getMessage():" + helper.textToString(skewedPtr: helper.call(name: "getMessage", parms: [Int32(0)]) as! Int32)
            showingAlert = true
        }
        catch {
            print("Call to getMessage() failed")
        }
    }
    
    var body: some View {
        VStack {
            TextField("Your name", text: $name)
            Button(action: greet) {
                Text("greet()")
            }
            Button(action: getMessage) {
                Text("getMessage()")
            }
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Result"), message: Text(alertText))
        }
      }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
