

import Foundation
import Foundation

class Timer {
    
    var endDate: NSDate?
    
    var timeRemaining: NSTimeInterval {
        if let endDate = endDate {
            return endDate.timeIntervalSinceNow
        } else {
            return 0
        }
    }
    
    weak var receiverDelegate: ReceiverTimerDelegate?
    weak var senderDelegate: SenderTimerDelegate?
    weak var imageDelegate: ImageTimerDelegate?
    
    var isOn: Bool {
        if endDate == nil {
            return false
        } else {
            return true
        }
    }
    
    func timeAsString() -> String {
        let timeRemaining = Int(self.timeRemaining)
        return String(format: "%02d", arguments: [timeRemaining])
    }
    
    func secondTick() {
        receiverDelegate?.updateTimerLabel()
        senderDelegate?.updateTimerLabel()
        imageDelegate?.updateImageTimerLabel()
    }
    
    func complete() {
        receiverDelegate?.messageTimerComplete()
        senderDelegate?.messageTimerComplete()
        imageDelegate?.messageImageTimerComplete()
    }
    
}

protocol ReceiverTimerDelegate: class {
    func updateTimerLabel()
    func messageTimerComplete()
}

protocol SenderTimerDelegate: class {
    func updateTimerLabel()
    func messageTimerComplete()
}

protocol ImageTimerDelegate: class {
    func updateImageTimerLabel()
    func messageImageTimerComplete()
}