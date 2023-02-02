# C# and Motoko integration

1. Install the .Net Wasmer binding at https://github.com/migueldeicaza/WasmerSharp
2. Build using Visual Studio 22

## Example code

    var wasm = File.ReadAllBytes("a-motoko-lib.wasm");
    if(wasm == null) {
        MessageBox.Show("File not found");
        return;
    }

    if(!helper.Load(wasm)) {
        MessageBox.Show("Invalid wasm file");
        return;
    }

    if(!helper.Instanciate()) {
        MessageBox.Show("Invalid module");
        return;
    }
  
    var res = helper.Call("greet", 0, helper.StringToText(this.textBox1.Text));
    if(res != null && res.Length > 0) {
        MessageBox.Show(helper.TextToString((int)res[0]), "greet() result");
    }
