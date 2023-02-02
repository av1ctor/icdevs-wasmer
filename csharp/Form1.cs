using WasmerSharp;

namespace CsharpWasmer
{
    public partial class Form1 : Form
    {
        public MoHelper helper;
        
        public Form1()
        {
            InitializeComponent();

            helper = new MoHelper();

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
        }

        private void button1_Click(object sender, EventArgs e) {
            var res = helper.Call("greet", 0, helper.StringToText(this.textBox1.Text));
            if(res != null && res.Length > 0) {
                MessageBox.Show(helper.TextToString((int)res[0]), "greet() result");
            }
        }

        private void button2_Click(object sender, EventArgs e) {
            var res = helper.Call("getMessage", (int)0);
            if(res != null && res.Length > 0) {
                MessageBox.Show(helper.TextToString((int)res[0]), "getMessage() result");
            }
        }
    }
}