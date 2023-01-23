var name: Text = "";

module Main {
    public func sayHello(
        name_: Text
    ): Text {
        name := name_;
        return "Hello, " # name;
    };

    public func getName(
    ): Text {
        return name;
    };
};

// note: we must call all functions that need to be "exported" or they won't get emitted
ignore Main.sayHello("");
ignore Main.getName();