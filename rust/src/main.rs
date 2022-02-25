enum PizzaSizes {
	Galactic,
	Big,
	Medium,
	Small,
}



trait Details {
	/// Returns a String that represents the details
	/// of the object.
	fn display(&self) -> String;
}



struct Pizza {
	name: String,
	size: PizzaSizes,
	price: f32,
	quantity: u8
}

impl Pizza {
	fn new(name: &str, size: PizzaSizes, price: f32, quantity: u8) -> Pizza {
		Pizza {
			name: name.into(),
			size,
			price,
			quantity
		}
	}

	/// Get the price of the pizza depending on it's size
	fn get_unit_price(&self) -> f32 {
		let plus: f32 = match self.size {
			PizzaSizes::Galactic => 8.0,
			PizzaSizes::Big => 5.0,
			PizzaSizes::Medium => 2.0,
			PizzaSizes::Small => 0.0,
		};
		(self.price + (plus/10.0)*self.price) as f32
	}

	/// Get the total price of all the pizzas
	fn get_total_price(&self) -> f32 {
		self.get_unit_price() * self.quantity as f32
	}
}

impl Details for Pizza {
	fn display(&self) -> String {
		format!(
			"({q}) {name:20} | ({q} * ${price:<4}) = ${total}",
			q = self.quantity,
			name = self.name,
			price = self.get_unit_price(),
			total = self.get_total_price()
		)
	}
}



struct Order<'a> {
	items: &'a [Pizza],
	customer: String,
}

impl<'a> Order<'a> {
	/// Get the total price of all the ordered items
	fn get_price(&self) -> f32 {
		let mut final_price: f32 = 0.0;
		for pizza in self.items {
			final_price += pizza.get_total_price() as f32;
		}
		final_price
	}
}

impl Details for Order {
	fn display(&self) -> String {
		let mut end_str = format!("Customer: {}\nPizzas:\n", self.customer);
		for item in self.items {
			end_str.push_str(format!("  - {}\n", item.display()).as_str());
		}
		end_str.push_str(format!("{}\nTotal: ${}", "_".repeat(50), self.get_price()).as_str());

		end_str
	}
}




fn main() {
	let price: f32 = 12.0;

	let pizzas = [
		Pizza::new("BBQ", PizzaSizes::Small, price, 1),
		Pizza::new("Pepperoni", PizzaSizes::Medium, price, 2),
		Pizza::new("Hot Dog", PizzaSizes::Galactic, price, 5),
	];

	let order = Order {
		items: &pizzas,
		customer: "Joshua".into(),
	};

	println!("{}", order.display())
}
