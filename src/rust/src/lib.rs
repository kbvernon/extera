use extendr_api::prelude::*;
use serde_json::Value;
use std::fs;
use std::io::BufWriter;
use tera::{Context, Tera};

#[derive(Debug)]
#[extendr]
struct RustExTera(Tera);

#[extendr]
impl RustExTera {
    fn default() -> RustExTera {
        let tera = Tera::default();
        RustExTera(tera)
    }

    fn new(dir: &str) -> RustExTera {
        let tera = match Tera::new(dir) {
            Ok(t) => t,
            Err(e) => throw_r_error(&format!("{}", e)),
        };

        RustExTera(tera)
    }

    fn add_string_templates(&mut self, templates: List) -> Rbool {
        let mut template_tuples: Vec<(&str, &str)> = vec![];

        for (name, content) in templates.iter() {
            template_tuples.push((name, &content.as_str().unwrap()))
        }

        match self.0.add_raw_templates(template_tuples) {
            Ok(_) => Rbool::true_value(),
            Err(e) => throw_r_error(&format!("{}", e)),
        }
    }

    fn add_file_templates(&mut self, templates: List) -> Rbool {
        let mut template_tuples: Vec<(&str, Option<&str>)> = vec![];

        for (name, content) in templates.iter() {
            let template_name = if name.is_empty() { None } else { Some(name) };
            template_tuples.push((&content.as_str().unwrap(), template_name))
        }

        match self.0.add_template_files(template_tuples) {
            Ok(_) => Rbool::true_value(),
            Err(e) => throw_r_error(&format!("{}", e)),
        }
    }

    fn list_templates(&self) -> Strings {
        self.0.get_template_names().collect()
    }

    fn render_to_file(&self, template_name: &str, context_string: &str, outfile: &str) -> Rbool {
        let context = to_context(context_string);

        let file = match fs::File::create(outfile) {
            Ok(f) => f,
            Err(e) => throw_r_error(&format!("{}", e)),
        };

        let mut writer = BufWriter::new(file);

        match self.0.render_to(template_name, &context, &mut writer) {
            Ok(_) => Rbool::true_value(),
            Err(e) => throw_r_error(&format!("{}", e)),
        }
    }

    fn render_to_string(&self, template_name: &str, context_string: &str) -> String {
        let context = to_context(context_string);

        match self.0.render(template_name, &context) {
            Ok(result) => result.into(),
            Err(e) => throw_r_error(&format!("{}", e)),
        }
    }

    fn autoescape_on(&mut self) -> Rbool {
        self.0.reset_escape_fn();
        Rbool::true_value()
    }

    fn autoescape_off(&mut self) -> Rbool {
        self.0.autoescape_on(vec![]);
        Rbool::true_value()
    }
}

fn to_context(x: &str) -> Context {
    let value: Value = match serde_json::from_str(x) {
        Ok(v) => v,
        Err(_) => throw_r_error("Failed to convert &str to Value."),
    };

    match Context::from_value(value) {
        Ok(ctx) => ctx,
        Err(_) => throw_r_error("Failed to convert Value to Context."),
    }
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod extera;
    impl RustExTera;
}
