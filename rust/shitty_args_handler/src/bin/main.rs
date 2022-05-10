use test2::*;

fn main() {
    let mut cfg = Config::new("shit", "alright");
    cfg.add_arg(Arg::new("a", Value::Number(23), "hell nah"));
    cfg.add_arg(Arg::new("b", Value::String("hola".into()), "balls"));
    cfg.add_arg(Arg::new("thing", Value::Bool, "what th hell"));

    let parsed_args = cfg.parse_args();

    println!("final: {:?}", parsed_args);

    if let Some(v) = parsed_args.get("thing") {
        println!("Thingie! {}", v)
    }

    if let Some(v) = parsed_args.get("b") {
        println!("B! {}", v)
    }
}
