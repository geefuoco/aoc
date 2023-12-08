import Foundation 

enum HandType: Int, Comparable {
    case HIGH_CARD = 0
    case PAIR = 1
    case TWO_PAIR = 2
    case THREE = 3
    case FULL_HOUSE = 4
    case FOUR = 5
    case FIVE = 6

    static func < (lhs: HandType, rhs: HandType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

func readFileToString(atPath filepath: String) throws -> String {
    let fileURL = URL(fileURLWithPath: filepath)
    let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
    return fileContents
}

func getCardValue(card: Character) -> Int {
    switch card {
    case "A":
        return 14
    case "K":
        return 13
    case "Q":
        return 12
    case "T":
        return 10
    case "9":
        return 9 
    case "8":
        return 8
    case "7":
        return 7
    case "6":
        return 6
    case "5":
        return 5 
    case "4":
        return 4
    case "3":
        return 3
    case "2":
        return 2
    case "J":
        return 1
    default:
        fatalError("Unreachable")
    }
}

func convertJokers(hand cards: String) -> String {
    var dict=[Character: Int]() 
    for char in cards {
        dict[char, default: 0] += 1
    }
    // Get the highest card count from the dict
    var highestCard: Character = "J"
    var bestCard: Character = "J"
    var bestCount = 0
    for (ch, count) in dict {
        if count > bestCount && ch != "J"{
            bestCard = ch
            bestCount = count
        }
        if getCardValue(card: ch) > getCardValue(card: highestCard) {
            highestCard = ch
        }
    }
    let jokerCount = dict["J"]
    if jokerCount != 0 {
        if bestCount == 1 {
            let result = cards.replacingOccurrences(of: "J", with: String(highestCard))
            return result
        } else {
            let result = cards.replacingOccurrences(of: "J", with: String(bestCard))
            return result
        }
    }
    return cards
}

func evaluateHandType(hand cards: String) -> HandType {
    var dict=[Character: Int]() 
    var cardsToSearch: String = cards
    if cards.contains("J") {
        cardsToSearch = convertJokers(hand: cards)
        if cardsToSearch.contains("J") && cardsToSearch != "JJJJJ" {
            print("Cards:")
            print(cards)
            print("After Conversion:")
            print(cardsToSearch)
            print("--------------------")
        }
    }
    for char in cardsToSearch {
        dict[char, default: 0] += 1
    }
    var hasTwo = false
    var hasThree = false
    for (_, count) in dict {
        if count == 4 {
            return .FOUR
        } else if count == 5 {
            return .FIVE
        } else if count == 3 {
            hasThree = true
            if hasTwo {
                return .FULL_HOUSE
            }
        } else if count == 2 {
            if hasTwo {
                return .TWO_PAIR
            }
            hasTwo = true
            if hasThree {
                return .FULL_HOUSE
            }
        }
    }
    if hasThree {
        return .THREE
    } else if hasTwo {
        return .PAIR
    }
    return .HIGH_CARD 
}

func main() {
    do {
        let arguments = CommandLine.arguments
        if arguments.count < 2 {
            print("Usage:\tswift main.swift <filepath>")
            return
        }
        let filepath = arguments[1]
        let input = try readFileToString(atPath: filepath)
        let lines = input.components(separatedBy: "\n")
        var result = 0
        var cards: [(String, Int)] = []
        for line in lines {
            if line == "" {
                continue
            }
            let lineSplit = line.components(separatedBy: " ") 
            let card = lineSplit[0]
            let score = Int(lineSplit[1])
            cards.append((card, score!))
        }

        let cardCompare: (Character, Character) -> Bool = {ch1, ch2 in 
            let cardValue1 = getCardValue(card: ch1)
            let cardValue2 = getCardValue(card: ch2)
            return cardValue1 < cardValue2
        }

        let handCompare: ((String, Int), (String, Int)) -> Bool = { tuple1, tuple2 in
            let str1 = tuple1.0
            let str2 = tuple2.0
            let handType1 = evaluateHandType(hand: tuple1.0)
            let handType2 = evaluateHandType(hand: tuple2.0)

            if handType1 == handType2 {
                for i in 0...str1.count {
                    let index = str1.index(str1.startIndex, offsetBy: i)
                    if  str1[index] == str2[index]{
                        continue
                    }
                    return cardCompare(str1[index], str2[index]) 
                }
            }
            return handType1 < handType2
        }

        cards = cards.sorted(by: handCompare)

        var idx = 1
        for (_, score) in cards {
            result += idx * score
            idx += 1
        }

        print(result)
    } catch {
        print("Error reading file: \(error)")
    }
}

main()
