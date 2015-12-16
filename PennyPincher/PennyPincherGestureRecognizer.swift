import UIKit
import UIKit.UIGestureRecognizerSubclass



public class PennyPincherGestureRecognizer: UIGestureRecognizer {
    
    public var enableMultipleStrokes: Bool = true
    public var allowedTimeBetweenMultipleStrokes: NSTimeInterval = 0.2
    public var templates = [PennyPincherTemplate]()
    private(set) public var result: (template: PennyPincherTemplate, similarity: CGFloat)?
    private(set) public var confidence:CGFloat=0.0
    private(set) public var recognizedTemplate:String=""
    
    private let pennyPincher = PennyPincher()
    private var points = [CGPoint]()
    private var timer: NSTimer?
    
    public override func reset() {
        super.reset()
        
        invalidateTimer()
        
        points.removeAll(keepCapacity: false)
        
        result = nil
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        invalidateTimer()
        
        if let touch = touches.first {
            points.append(touch.locationInView(view))
        }
        
        if state == .Possible {
            state = .Began
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        if let touch = touches.first {
            points.append(touch.locationInView(view))
        }
        
        state = .Changed
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        if enableMultipleStrokes {
            timer = NSTimer.scheduledTimerWithTimeInterval(allowedTimeBetweenMultipleStrokes,
                target: self,
                selector: "timerDidFire:",
                userInfo: nil,
                repeats: false)
        } else {
            recognize()
        }
    }
    
    override public func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        points.removeAll(keepCapacity: false)
        
        state = .Cancelled
    }
    
    override public func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    private func recognize() {
        result = PennyPincher.recognize(points, templates: templates)
        if let r=result{
            confidence=r.1
            recognizedTemplate=r.0.id
        }
        
        state = result != nil ? .Ended : .Failed
    }
    
    func timerDidFire(timer: NSTimer) {
        recognize()
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
