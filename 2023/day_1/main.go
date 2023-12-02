package main

import (
    "errors"
    "fmt"
    "strings"
    "os"
)

var numbers = [9]string{
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
}

func main() {
    file, err := os.ReadFile("input.txt")
    if err != nil {
        panic("File could not be opened")
    }

    fileContents := string(file)

    totalCalibration := 0
    for _, line := range strings.Split(fileContents, "\n"){
        line = strings.TrimSpace(line)
        if len(line) == 0 {
            continue
        }
        var buf [2]int
        n := len(line)-1;
        var read_start, read_end = true, true
        for i, j:= 0, n; i <= n && j >= 0; i, j = i+1, j-1 {
            if is_digit(line[i]) && read_start {
                v := int(line[i] - '0')
                buf[0] = v
                read_start = false
            } else if !is_digit(line[i]) && read_start {
                v, err := parseWord(line[i:], "start")
                if err == nil {
                    buf[0] = v
                    read_start = false
                }
            }
            if is_digit(line[j]) && read_end{
                v  :=  int(line[j] - '0')
                buf[1] = v
                read_end = false
            } else if !is_digit(line[j]) && read_end {
                v, err :=  parseWord(line[:j+1], "end")
                if err == nil {
                    buf[1] = v
                    read_end = false
                }
            }
            if !read_start && !read_end {
                break;
            }
        }
        value:= buf[0]*10 + buf[1]
        fmt.Printf("line: %s | %d\n", line, value)
        totalCalibration += value
    }
    fmt.Println(totalCalibration)
}

func is_digit(ch byte) bool{
    return ch >= '0' && ch <= '9'
}

func parseWord(str string, strategy string) (int, error){
    if strategy == "start"{
        for i, s := range numbers {
            if strings.HasPrefix(str, s) {
                return i+1, nil
            }
        }
    } else if strategy == "end" {
        for i, s := range numbers {
            if strings.HasSuffix(str, s) {
                return i+1, nil
            }
        }
    } else {
        return 0, errors.New("Invalid strategy")
    }
    return 0, errors.New("Not a valid word")
}

func parseWordIntoNumber(line string) {
}
