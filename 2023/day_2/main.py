#!/usr/bin/env python3
from typing import List

RED_TOTAL = 12
GREEN_TOTAL = 13
BLUE_TOTAL = 14

def game_parser(input: List[str]) -> int:
    total = 0
    for line in input:
        start, end = line.split(":")
        _, id = start.split(" ")
        line = end.strip()
        games = line.split(";")
        possible = True
        for game in games:
            possible = possible and is_game_possible(game)

        if possible:
            total += int(id)
    return total


def is_game_possible(game: str) -> bool:
    game = game.strip()
    red_sum = 0
    green_sum = 0
    blue_sum=0

    colors = game.split(",")
    for c in colors:
        c = c.strip()
        num, color = c.split(" ")
        if color == "blue":
            blue_sum += int(num)
        elif color == "red":
            red_sum += int(num)
        elif color == "green":
            green_sum += int(num)
    if blue_sum <= BLUE_TOTAL and red_sum <= RED_TOTAL and green_sum <= GREEN_TOTAL:
        return True
    return False

def game_parser_2(input: List[str]) -> int:
    total = 0
    for line in input:
        start, end = line.split(":")
        _, id = start.split(" ")
        line = end.strip()
        games = line.split(";")
        red_min = 0 
        green_min = 0 
        blue_min= 0 
        for game in games:
            game = game.strip()

            colors = game.split(",")
            for c in colors:
                c = c.strip()
                num, color = c.split(" ")
                if color == "blue":
                    blue_min = max(blue_min, int(num))
                elif color == "red":
                    red_min = max(red_min, int(num))
                elif color == "green":
                    green_min = max(green_min, int(num))

        total += blue_min * red_min * green_min
    return total

if __name__ == "__main__":
    import sys
    filename = sys.argv[1]

    with open(filename, "r") as f:
        input = f.readlines()
        print(game_parser_2(input))
