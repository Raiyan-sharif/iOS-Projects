import Cocoa
/*
// ❌ Bad: Forcing all workers to implement methods they don't need
protocol Worker {
    func work()
    func eat()
    func sleep()
}

class HumanWorker: Worker {
    func work() { print("Working") }
    func eat() { print("Eating lunch") }
    func sleep() { print("Sleeping") }
}

class RobotWorker: Worker {
    func work() { print("Working") }
    func eat() { /* Robots don't eat! */ }
    func sleep() { /* Robots don't sleep! */ }
}
*/
// ✅ Good: Split into smaller, focused protocols
protocol Workable {
    func work()
}

protocol Eatable {
    func eat()
}

protocol Sleepable {
    func sleep()
}

class HumanWorker: Workable, Eatable, Sleepable {
    func work() { print("Working") }
    func eat() { print("Eating lunch") }
    func sleep() { print("Sleeping") }
}

class RobotWorker: Workable {
    func work() { print("Working continuously") }
}

func main() {
    let worker: Workable = HumanWorker()
    worker.work()
}

main()
