import java.util.function.Consumer;

interface IPerson {
	public String getId();

	public void setId(String id);

	public String getName();

	public void setName(String name);

	public String getSurname();

	public void setSurname(String surname);

	public boolean isActive();
}

public abstract class Person implements IPerson {
	protected String id, name, surname;
	protected boolean active = true;

	Person(String id, String name, String surname, boolean active) {
		this.id = id;
		this.name = name;
		this.surname = surname;
		this.active = active;
	}

	public String toString() {
		return "Person [" + id + ", name=" + name + ", surname=" + surname + ", active=" + active + "]";
	}

	protected Consumer<String> printMsg = s -> {
		System.out.println(this.name + ", " + this.surname + " " + s);
	};

	public boolean subscribe(boolean showInfo) {
		boolean valueBefore = this.active;

		if (showInfo) {
			if (valueBefore)
				this.printMsg.accept("already subscribed.");
			else
				this.printMsg.accept("subscribed.");
		}

		this.active = true;
		return !valueBefore;
	}

	public boolean unsubscribe(boolean showInfo) {
		boolean valueBefore = this.active;

		if (showInfo) {
			if (!valueBefore)
				this.printMsg.accept("already unsuscribed.");
			else
				this.printMsg.accept("unsuscribed.");
		}

		this.active = false;
		return valueBefore;
	}

	// -------------- getters and setters --------------

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getSurname() {
		return surname;
	}

	public void setSurname(String surname) {
		this.surname = surname;
	}

	public boolean isActive() {
		return active;
	}
}