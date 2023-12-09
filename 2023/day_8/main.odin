package main

import "core:fmt"
import "core:os"
import "core:strings"

// main :: proc() {
//     if len(os.args) < 2 {
//         fmt.println("Usage:\t./main <filename>")
//         os.exit(1)
//     }
//     if bytes, ok := os.read_entire_file(os.args[1]); ok {
//         file_contents := string(bytes)
//         split := strings.split_lines(file_contents)
//         directions := split[0]
//         location_map := make(map[string][]string)
//         for i:=1; i < len(split); i+=1 {
//             if split[i] == "" {
//                 continue
//             }
//             node, _ := strings.replace_all(split[i], "(", "")
//             node, _ = strings.replace_all(node, ")", "")
//             nodes := strings.split(node, "=")
//             key := strings.trim(nodes[0], " ")
//             values := strings.split(nodes[1], ",")
//             for _, i in values {
//                 values[i] = strings.trim(values[i], " ")
//             }
//             location_map[key] = values
//         }
//
//         start := "AAA"
//         end := "ZZZ"
//
//         current := start
//         steps := 0
//         outer: for {
//             for dir in directions {
//                 steps += 1
//                 idx := 0 if dir == 'L' else 1
//                 current = location_map[current][idx]
//                 if current == end {
//                     break outer
//                 }
//             }
//         }
//         fmt.println(steps)
//     } else {
//         fmt.printf("Error: could not read file '%s'", os.args[1])
//     }
// }

main :: proc() {
    if len(os.args) < 2 {
        fmt.println("Usage:\t./main <filename>")
        os.exit(1)
    }
    if bytes, ok := os.read_entire_file(os.args[1]); ok {
        file_contents := string(bytes)
        split := strings.split_lines(file_contents)
        directions := split[0]
        location_map := make(map[string][]string)
        for i:=1; i < len(split); i+=1 {
            if split[i] == "" {
                continue
            }
            node, _ := strings.replace_all(split[i], "(", "")
            node, _ = strings.replace_all(node, ")", "")
            nodes := strings.split(node, "=")
            key := strings.trim(nodes[0], " ")
            values := strings.split(nodes[1], ",")
            for _, i in values {
                values[i] = strings.trim(values[i], " ")
            }
            location_map[key] = values
        }

        starting_keys := make([dynamic]string, 0, 10)
        steps_array   := make([dynamic]int, 0, 10)
        for k in location_map {
            if strings.has_suffix(k, "A") {
                append(&starting_keys, k)
            }
        }

        for key in starting_keys {
            current := key
            steps := 0
            outer: for {
                for dir in directions {
                    steps += 1
                    idx := 0 if dir == 'L' else 1
                    current = location_map[current][idx]
                    if strings.has_suffix(current, "Z") {
                        break outer
                    }
                }
            }
            append(&steps_array, steps)
        }

        result := 1
        for value in steps_array {
            factors := get_prime_factors(value)
            result *= factors[0]
        }
        result *= 263

        fmt.println(result)
    } else {
        fmt.printf("Error: could not read file '%s'", os.args[1])
    }
}

get_prime_factors :: proc(n: int) -> [dynamic]int {
    result := make([dynamic]int, 0, 10)
    n := n
    divisor := 2;
    for n > 1 {
        for n % divisor == 0 {
            append(&result, divisor) 
            n /= divisor
        }
        divisor += 1
    }
    return result
}


