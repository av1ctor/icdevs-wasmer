var lastMessage: Text = "";

module Main {
    public func greet(
        x: Text
    ): Text {
        lastMessage := "Hello, " # x;
        return lastMessage;
    };

    public func getMessage(
    ): Text {
        return lastMessage;
    };
};

// note: we must call all functions that need to be "exported" or they won't get emitted
ignore Main.greet("");
ignore Main.getMessage();