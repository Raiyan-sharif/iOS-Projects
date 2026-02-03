import Foundation

class Journal
{
    var entries = [String]()
    var count = 0
    
    func addEntry(_ text: String) -> Int {
        count += 1
        entries.append("\(count) : \(text)")
        return count - 1
    }
    
    func removeEntry(_ index: Int) {
        entries.remove(at: index)
    }
    
    func description() -> String {
        return entries.joined(separator: "\n")
    }
    
}

func main() {
    let j = Journal()
    let _ = j.addEntry("I cried Today")
    let bug = j.addEntry("I broke my computer")
    print(j.description())
    print("================")
    j.removeEntry(bug)
    print(j.description())
}


main()
