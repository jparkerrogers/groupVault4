

import Foundation
import UIKit

class TimerController: NSObject {
    
    static let sharedInstance = TimerController()
    var localNotification: UILocalNotification?
    
    
    func startTimer(timer: Timer) {
        
        if timer.isOn == false {
            timer.endDate = NSDate(timeIntervalSinceNow: 10)
            secondTick(timer)
        }
    }
    
    func stopTimer(timer: Timer) {
        if timer.isOn {
            timer.endDate = nil
            timer.complete()
        }
    }
    
    func secondTick(timer: Timer) {
        if timer.timeRemaining > 0 {
            timer.secondTick()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC*1)), dispatch_get_main_queue(), {
                self.secondTick(timer)
            })
        } else {
            stopTimer(timer)
        }
    }
    
}