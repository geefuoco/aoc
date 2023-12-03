use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::Read;
use std::str;

#[derive(Debug, PartialOrd, PartialEq, Eq, Hash, Clone, Copy)]
struct Location{
    row:    isize,
    start:  isize,
    end:    isize
}

impl Location {
    fn is_adjacent(&self, loc: &Self) -> bool {
        if (self.row - loc.row).abs() > 1 {
            return false;
        }
        if self == loc {
            return false;
        }
        let dirs = [-1, 0, 1];
        for x in dirs {
            if self.start + x >= loc.start && self.start+x <= loc.end{
                return true;
            }
        }
        return false;
    }
}

fn parse_number(line: &[u8], index: &mut usize) -> usize {
    let start = *index;
    while *index < line.len() && line[*index].is_ascii_digit() {
        (*index) += 1;
    }
    let s = str::from_utf8(&line[start..*index]).expect("Could not create str from byte slice");
    return s.parse::<usize>().expect("Could not parse &str into usize");
}

pub fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage:\t./main <filepath>");
        return;
    }

    let filepath = &args[1];
    let mut file = File::open(filepath).expect("Could not open file");
    let mut s = String::new();
    file.read_to_string(&mut s).expect("Could not read file to string");
    let lines: Vec<&str> = s.split_whitespace().collect();
    let row_length = lines.len();
    let column_length = lines[0].len();

    let mut symbols: Vec<Location> = Vec::new();
    let mut location_map: HashMap<Location, usize> = HashMap::new();

    let mut i = 0;
    let mut j = 0;

    while i < row_length {
        let line: &[u8] = lines[i].as_bytes();
        while j < column_length {
            let b: u8 = line[j];
            if !b.is_ascii_digit() && b != b'.' {
                symbols.push(Location{row: i as isize, start: j as isize, end: j as isize});
            } else if b.is_ascii_digit() {
                let start = j as isize;
                let x = parse_number(line, &mut j);
                location_map.insert(Location{row: i as isize, start: start, end: (j-1) as isize}, x);
                j -= 1;
            }
            j += 1;
        }
        j = 0;
        i += 1;
    }

    let mut total= 0;

    for sym_loc in symbols {
        let filtered_keys: Vec<&Location> = location_map.keys().clone().filter(|loc| sym_loc.is_adjacent(loc)).collect();

        for k in filtered_keys.iter() {
            if let Some(v) = location_map.get(k){ 
                total += v;
            }
        }
    }
    println!("{total}");
}

