use std::collections::HashMap;
use std::fs;
use std::io::prelude::*;
use clearscreen::ClearScreen;

fn main() -> std::io::Result<()> {
    let contents = fs::read_to_string("/home/alex/kdata/2023/0157/data/p0157.rft")?;
    let geo_file =
        fs::read_to_string("/home/alex/Rust Scripts/geo_merge/src/source/ZIP_USR [2023].csv")?;
    let mut file = fs::File::create("/home/alex/kdata/2020/0157/data/p0157.rf3")?;
    //let mut extra_file = fs::File::create("/home/alex/kdata/2020/0157/data/age18to24.txt")?;

    let mut hashmap: HashMap<String, String> = HashMap::new();
    for line in geo_file.lines() {
        let mut iter = line.splitn(2, ',');
        if let (Some(key), Some(value)) = (iter.next(), iter.next()) {
            hashmap.insert(key.trim().to_string(), value.trim().to_string());
        }
    }

    ClearScreen::default()
        .clear()
        .expect("failed to clear the screen");

    let mut tot_lines = 0;
    let mut count = 0;
    for line in contents.lines() {
        tot_lines += 1;
        let mut line = String::from(line);
        line = line + &" ".repeat(500);
        line = String::from(&line[..=1950]);
        line = mid(&line, 3, String::from("1"));
        line = mid(&line, 67, " ".repeat(7));

        //let qage = &line[36..40];
        //let qage: u8 = qage.trim().parse().unwrap_or(0);
        //let agegroup = match qage {
        //    18..=24 => String::from("1"),
        //    25..=34 => String::from("2"),
        //    35..=44 => String::from("3"),
        //    45..=54 => String::from("4"),
        //    55..=64 => String::from("5"),
        //    65..=120 => String::from("6"),
        //    _ => String::from("7"),
        //};
        //line = mid(&line, 70, agegroup);

        let qzip = &line[203..208];
        let r_zip = &line[349..354];
        let m_zip = &line[395..400];

        let keys = [qzip, r_zip, m_zip];
        for &key in &keys {
            if let Some(geocode) = hashmap.get(key) {
                line = mid(&line, 1949, geocode.clone());
                count += 1;
                break;
            }
        }

        line = line + "\n";
        file.write_all(line.as_bytes())?;
        //if &line[70..71] == "1" {
        //    extra_file.write_all(line.as_bytes())?;
        //}
    }
    println!("\n\nMerging data...");
    println!("\nTotal lines: {}\n", tot_lines);
    println!("{} geocode merged\n", count);

    Ok(())
}

fn mid(source: &str, col: usize, edit: String) -> String {
    let end_col = col + edit.len();
    format!("{}{}{}", &source[..col], edit, &source[end_col..])
}
