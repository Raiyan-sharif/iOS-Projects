import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class CustomThread {
    func createThread() {
        let thread: Thread = Thread(target: self, selector: #selector(threadSelector), object: nil)
        
        thread.start()
    }
    
    @objc func threadSelector() {
        print("Hello from a custom thread!")
    }
    
}

let customThread: CustomThread = CustomThread()
customThread.createThread()
