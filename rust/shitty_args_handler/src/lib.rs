use std::{self, collections::HashMap, fmt::Display};

#[derive(Debug)]
pub enum Value {
    String(String),
    Number(usize),
    Bool,
    Help,
}

impl Display for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Value::String(s) => write!(f, "{}", s),
            Value::Number(n) => write!(f, "{}", n),
            Value::Bool => write!(f, "true"),
            Value::Help => write!(f, "help"),
        }
    }
}

#[derive(Debug)]
pub struct Arg {
    name: String,
    default: Value,
    description: String,
}

impl Arg {
    pub fn new(name: &str, default: Value, description: &str) -> Self {
        Self {
            name: name.into(),
            default,
            description: description.into(),
        }
    }
}

pub struct Config {
    title: Option<String>,
    description: Option<String>,
    args: Vec<Arg>,
}

type ParsedArgs = HashMap<String, Value>;

impl Config {
    pub fn new(title: &str, description: &str) -> Self {
        Self {
            title: Some(title.into()),
            description: Some(description.into()),
            args: vec![Arg::new("help", Value::Help, "Display the help")],
        }
    }

    pub fn add_arg(&mut self, arg: Arg) {
        self.args.push(arg);
    }

    pub fn remove_arg(&mut self, name: &str) {
        self.args.retain(|arg| arg.name != name);
    }

    pub fn print_help(&self) {
        println!(
            "{title}: {desc}",
            title = self.title.as_ref().unwrap(),
            desc = self.description.as_ref().unwrap(),
        );

        for arg in &self.args {
            println!("  -{name}: {desc}", name = arg.name, desc = arg.description);
        }
    }

    pub fn parse_args(&self) -> ParsedArgs {
        // we skip the first one because, well, its not very useful here
        let input_args: Vec<String> = std::env::args().into_iter().skip(1).collect();
        let mut parsed_args = ParsedArgs::new();

        let mut do_skip = 0;

        for (index, argv) in input_args.iter().enumerate() {
            if do_skip >= 1 {
                do_skip -= 1;
                continue;
            }

            let matched_arg = self
                .args
                .iter()
                .filter(|arg| &format!("-{}", arg.name) == argv)
                .nth(0);

            if let Some(arg) = matched_arg {
                match arg.default {
                    Value::Bool => {
                        parsed_args.insert(argv[1..].to_string(), Value::Bool);
                        continue;
                    }
                    Value::Help => {
                        self.print_help();
                        std::process::exit(0);
                    }
                    _ => {}
                }

                if let Some(next_arg) = input_args.get(index + 1) {
                    do_skip = 1;

                    parsed_args.insert(argv[1..].to_string(), {
                        if let Ok(good) = parse_arg_value(&next_arg, &arg.default) {
                            good
                        } else {
                            println!(
                                "Invalid value '{}' for the type of the '{}' argument.",
                                next_arg, arg.name
                            );
                            continue;
                        }
                    });
                }
            } else {
                println!("Unknown parameter: {}", argv);
            }
        }

        parsed_args
    }
}

fn parse_arg_value<'a>(argv: &'a str, value: &Value) -> Result<Value, &'a str> {
    match value {
        Value::String(_) => Ok(Value::String(argv.into())),
        Value::Number(_) => {
            let x = argv.parse();
            if let Ok(good) = x {
                Ok(Value::Number(good))
            } else {
                Err("Invalid Number value")
            }
        }
        Value::Bool => Ok(Value::Bool),
        Value::Help => Ok(Value::Help),
    }
}
