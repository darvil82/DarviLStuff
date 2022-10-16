package testing;

import messaging.*;

enum Types {
	Type1,
	Type2,
	Type3,
	Type4
}

class MyMsg extends Message<Types> {
	public String thing;

	public MyMsg(String thing) {
		super(Types.Type1);
		this.thing = thing;
	}
}

class MyOtherMsg extends Message<Types> {
	public int value;

	public MyOtherMsg(int thing) {
		super(Types.Type3);
		this.value = thing;
	}
}

public class Testing {

	public static void main(String[] args) {
		var bus = new MessagesBus<Types>();
		bus.addListener((MyMsg x) -> System.out.println("type1: " + x.thing), Types.Type1);
		bus.addListener(Testing::handleType2, Types.Type2);
		bus.addListener(Testing::handleType3, Types.Type3);
		bus.addListener((x) -> System.out.println("type4: " + x), Types.Type4);

		// sending messages
		bus.sendMessage(new MyMsg("que tal?"));
		bus.sendMessage(new Message<>(Types.Type2) {});
		bus.sendMessage(new MyOtherMsg(1453));
		bus.sendMessage(new Message<>(Types.Type4) {});
	}

	private static void handleType2(Message<Types> msg) {
		System.out.println("type2: " + msg);
	}

	private static void handleType3(MyOtherMsg msg) {
		System.out.println(msg.value >= 10 ? "value is bigger!" : "value isn't bigger");
	}
}

