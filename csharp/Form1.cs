using WasmerSharp;

namespace CsharpWasmer
{
    public partial class Form1 : Form
    {
        public Instance instance;
        public MoHelper helper;
        
        delegate int FdWriteDel (InstanceContext ctx, int p0, int p1, int p2, int p3);
        private static int FdWrite(InstanceContext ctx, int p0, int p1, int p2, int p3) {
            return 0;
        }

        public Form1()
        {
            InitializeComponent();

            var wasm = File.ReadAllBytes("a-motoko-lib.wasm");

            var module = Module.Create(wasm);
            if(module == null) {
                return;
            }

            var functionImport = new Import("wasi_unstable", "fd_write", new ImportFunction((FdWriteDel)(FdWrite)));

            instance = module.Instatiate(functionImport);
            if(instance == null) {
                return;
            }

            helper = new MoHelper(instance);
        }

        private void button1_Click(object sender, EventArgs e) {
            var res = instance.Call("greet", (int)0, (int)helper.StringToText(this.textBox1.Text));
            if(res != null && res.Length > 0) {
                this.textBox2.Text = $"greet() = {helper.TextToString((uint)(int)res[0])}";
            }
            else { 
                this.textBox2.Text = "null";
            }
        }

        private void button2_Click(object sender, EventArgs e) {
            var res = instance.Call("getMessage", (int)0);
            if(res != null && res.Length > 0) {
                this.textBox2.Text = $"getMessage() = {helper.TextToString((uint)(int)res[0])}";
            }
            else { 
                this.textBox2.Text = "null";
            }
        }
    }
}