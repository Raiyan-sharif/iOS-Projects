import Cocoa
/*
// ❌ Bad: Square violates LSP by changing Rectangle behavior
class Rectangle {
    var width: Double
    var height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    func area() -> Double {
        return width * height
    }
}

class Square: Rectangle {
    override var width: Double {
        didSet {
            height = width // Breaks expected behavior
        }
    }
    
    override var height: Double {
        didSet {
            width = height // Breaks expected behavior
        }
    }
}

// This fails - expected 50, but Square gives 25
func printArea(rectangle: Rectangle) {
    rectangle.width = 5
    rectangle.height = 10
    print(rectangle.area()) // Should be 50
}
*/

// ✅ Good: Use composition and proper abstractions

protocol Shape {
    func area() -> Double
}

class Rectangle: Shape {
    var width: Double
    var height: Double
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }
    
    func area() -> Double {
        return width * height
    }
}

class Square: Shape {
    var side: Double
    
    init(side: Double) {
        self.side = side
    }
    
    func area() -> Double {
        return side * side
    }
}

func main() {
    var square = Square(side: 5)
    print(square.area())
}

main()
