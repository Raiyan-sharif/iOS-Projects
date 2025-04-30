import UIKit


//// Palindrome
//func isPalindrome(_ str: String) -> Bool {
//    let cleaned = str.lowercased().filter { $0.isLetter }
//    return cleaned == String(cleaned.reversed())
//}
//
//print(isPalindrome("Madam"))          // true
//print(isPalindrome("Hello"))        // false
func isPalindrome(_ str: String) -> Bool {
    let chars = Array(str)
    var left = 0
    var right = chars.count - 1
    
    while left < right {
        if chars[left] != chars[right] {
            return false
        }
        left += 1
        right -= 1
    }
    return true
}

print(isPalindrome("racecar"))  // true
print(isPalindrome("hello"))    // false


//Count vowel

//func countVowels(_ str: String) -> Int {
//    let vowels = "aeiouAEIOU"
//    return str.filter { vowels.contains($0) }.count
//}
//
//print(countVowels("Swift Programming"))

func countVowels(_ str: String) -> Int {
    let vowels: [Character] = ["a", "e", "i", "o", "u",
                               "A", "E", "I", "O", "U"]
    let chars = Array(str)
    var count = 0
    
    for char in chars {
        for vowel in vowels {
            if char == vowel {
                count += 1
                break
            }
        }
    }
    return count
}

print(countVowels("Swift Programming"))  // Output: 4

func mostFrequentChar(_ str: String) -> Character? {
    let counts = str.reduce(into: [:]) { counts, char in
        counts[char, default: 0] += 1
    }
    return counts.max { a, b in a.value < b.value }?.key
}

print(mostFrequentChar("swiss"))  // "s"

//func removeDuplicates(_ str: String) -> String {
//    var seen = Set<Character>()
//    return String(str.filter { seen.insert($0).inserted })
//}
//
//print(removeDuplicates("programming"))  // "progamin"

func removeDuplicates(_ str: String) -> String {
    var seen: [Character] = []
    var result = ""
    let chars = Array(str)
    
    for c in chars {
        var isDuplicate = false
        for s in seen {
            if s == c {
                isDuplicate = true
                break
            }
        }
        if !isDuplicate {
            seen.append(c)
            result += String(c)
        }
    }
    return result
}

print(removeDuplicates("programming"))  // Output: "progamin"



//func capitalizeWords(_ str: String) -> String {
//    return str
//        .lowercased()
//        .split(separator: " ")
//        .map { $0.prefix(1).uppercased() + $0.dropFirst() }
//        .joined(separator: " ")
//}
//
//print(capitalizeWords("hello swift world"))  // "Hello Swift World"


func capitalizeWords(_ str: String) -> String {
    let chars = Array(str)
    var result = ""
    var capitalizeNext = true
    
    for i in 0..<chars.count {
        let c = chars[i]
        if c == " " {
            result += " "
            capitalizeNext = true
        } else {
            if capitalizeNext {
                // Convert to uppercase manually
                if c >= "a" && c <= "z" {
                    let upper = Character(UnicodeScalar(c.asciiValue! - 32))
                    result += String(upper)
                } else {
                    result += String(c)
                }
                capitalizeNext = false
            } else {
                // Convert to lowercase manually
                if c >= "A" && c <= "Z" {
                    let lower = Character(UnicodeScalar(c.asciiValue! + 32))
                    result += String(lower)
                } else {
                    result += String(c)
                }
            }
        }
    }
    
    return result
}

print(capitalizeWords("hello SWIFT world"))  // Output: "Hello Swift World"


func reverseString(_ str: String) -> String {
    var result = ""
    let characters = Array(str)
    var index = characters.count - 1
    while index >= 0 {
        result += String(characters[index])
        index -= 1
    }
    return result
}

print(reverseString("hello"))  // Output: "olleh"




