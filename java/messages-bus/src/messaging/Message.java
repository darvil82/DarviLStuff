package messaging;

public abstract class Message<TMsgTypeEnum extends Enum<TMsgTypeEnum>> {
	final protected TMsgTypeEnum type;

	public Message(TMsgTypeEnum msgType) {
		this.type = msgType;
	}

	public TMsgTypeEnum getType() {
		return type;
	}

	public String toString() {
		return "Message(" + this.type + ")";
	}
}
