# Swift and Motoko integration

1. Install Wasmer on Mac OS: curl https://get.wasmer.io -sSfL | sh
2. Create a pkg-config file: wasmer config --pkg-config > /usr/local/lib/pkgconfig/wasmer.pc
3. Build using XCode

## Example code

    try helper.load(bytes: bytes)
    try helper.instanciate()
    
    ...
    
     let res = try helper.call(name: "greet", parms: [Int32(0), helper.stringToText(s: name)])
     print("Result from greet():" + try helper.textToString(skewedPtr: res as! Int32))
