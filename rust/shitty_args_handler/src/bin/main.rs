use test2::*;

fn main() {
    let mut cfg = Config::new("shit", "alright");
    cfg.add_arg(Arg::new("num", Value::Number(23), "hell nah"));
    cfg.add_arg(Arg::new("str", Value::String("balls".into()), "balls"));
    cfg.add_arg(Arg::new("bool", Value::Bool, "what th hell"));

    let parsed_args = cfg.parse_args();

    println!("final: {:?}", parsed_args);

    if let Some(v) = parsed_args.get("thing") {
        println!("Thingie! {}", v)
    }

    if let Some(v) = parsed_args.get("b") {
        println!("B! {}", v)
    }
}
