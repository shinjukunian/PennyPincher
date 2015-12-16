import UIKit

struct GestureViewStroke {
    let points: [CGPoint]
}

@objc public class GestureView: UIView {
    
    var strokes = [GestureViewStroke]() {
        didSet {
            strokePoints.removeAll(keepCapacity: false)
            setNeedsDisplay()
        }
    }
    
   public var points: [CGPoint] {
        return strokes.reduce([CGPoint]()) { points, stroke in
            return points + stroke.points
        }
    }
    
    public var nsPoints:NSArray{
        let points=self.points
        let outPoints=NSMutableArray()
        for p in points{
            let pValue=NSValue(CGPoint: p)
            outPoints .addObject(pValue)
        }
        return outPoints.copy() as! NSArray
    }
    
    
    private var strokePoints = [CGPoint]()
    
    var strokeColor: UIColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var showSamplingPoints = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let path = UIBezierPath()
    private let samplingPath = UIBezierPath()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        setup()
    }
    
    private func setup() {
        path.lineWidth = 2.0
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        addStrokePointFromTouches(touches)
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)  {
        super.touchesMoved(touches, withEvent: event)
        
        addStrokePointFromTouches(touches)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        strokes.append(GestureViewStroke(points: strokePoints))
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        strokePoints.removeAll(keepCapacity: false)
    }
    
    private func addStrokePointFromTouches(touches: Set<NSObject>) {
        if let touch = touches.first as? UITouch {
            let point = touch.locationInView(self)
            strokePoints.append(point)
            
            setNeedsDisplay()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        path.removeAllPoints()
        
        strokeColor.setStroke()
        
        addStrokePoint(strokePoints)
        for stroke in strokes {
            addStrokePoint(stroke.points)
        }
        
        path.stroke()
        
        if showSamplingPoints {
            addSamplingPoints()
        }
    }
    
    private func addStrokePoint(points: [CGPoint]) {
        if points.count < 3 {
            return
        }
        
        path.moveToPoint(points.first!)
        
        for i in 1...points.count - 2 {
            let point = points[i]
            let nextPoint = points[i + 1]
            let endPoint = CGPointMake(
                (point.x + nextPoint.x) / 2,
                (point.y + nextPoint.y) / 2)
            
            path.addQuadCurveToPoint(endPoint, controlPoint: point)
        }
        
        let lastPoint = points[points.count - 1]
        let secondLastPoint = points[points.count - 2]
        
        path.addQuadCurveToPoint(lastPoint, controlPoint: secondLastPoint)
    }
    
    private func addSamplingPoints() {
        samplingPath.removeAllPoints()
        
        UIColor.redColor().setStroke()
        
        for stroke in strokes {
            for point in stroke.points {
                samplingPath.moveToPoint(point)
                samplingPath.appendPath(UIBezierPath(arcCenter:point, radius: path.lineWidth * 3, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2, clockwise: true))
            }
        }
        
        samplingPath.stroke()
    }
    
    public func clear() {
        strokes.removeAll(keepCapacity: false)
    }
    
}
