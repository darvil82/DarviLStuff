package messaging;

import java.util.ArrayList;
import java.util.function.Consumer;

import utils.Pair;


public class MessagesBus<TMsgTypeEnum extends Enum<TMsgTypeEnum>> {
	private final ArrayList<Pair<Consumer<Message<TMsgTypeEnum>>, TMsgTypeEnum>> listeners = new ArrayList<>();

	@SuppressWarnings("unchecked cast")
	public <TMsg extends Message<TMsgTypeEnum>> void addListener(Consumer<TMsg> callback, TMsgTypeEnum type) {
		this.listeners.add(new Pair<>((Consumer<Message<TMsgTypeEnum>>) callback, type)); // probably a bit hacky
	}

	public void sendMessage(Message<TMsgTypeEnum> msg) {
		this.listeners.stream().filter((l) -> msg.type == l.second).forEach((l) -> l.first.accept(msg));
	}

	public void sendMessages(Message<TMsgTypeEnum>[] msgs) {
		for (var msg : msgs) {
			this.sendMessage(msg);
		}
	}
}
