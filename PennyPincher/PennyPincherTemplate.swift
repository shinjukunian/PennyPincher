import UIKit

public struct PennyPincherTemplate {
    
    public let id: String
    public let points: [CGPoint]
    
    
    public func encodeTemplate(url:NSURL){
        let encoder=TemplateEncoder(t: self)
        let data=NSKeyedArchiver.archivedDataWithRootObject(encoder)
        data.writeToURL(url, atomically: true)
    }
    
    static func decodeFromURL(aUrl:NSURL) -> PennyPincherTemplate?{
        
        guard let data=try? NSData(contentsOfURL: aUrl, options: .MappedRead) else{
            return nil
        }
        guard let helper=NSKeyedUnarchiver.unarchiveObjectWithData(data) as? TemplateEncoder else{
            return nil
        }
        return helper.template
    }
    
    class TemplateEncoder: NSObject,NSSecureCoding {
        
        var template:PennyPincherTemplate?
        
        class func supportsSecureCoding() -> Bool {
            return true
        }
        
        init(t:PennyPincherTemplate) {
            self.template=t
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            guard let newID=aDecoder.decodeObjectForKey("templateName")as! String? else{
                return
            }
            guard let newPoints=aDecoder.decodeObjectForKey("templatePoints") as! NSArray? else {
                return
            }
            var newCGPoints=[CGPoint]()
            for pointValue in newPoints{
                if let p=pointValue as? NSValue{
                    let point=p.CGPointValue()
                    newCGPoints.append(point)
                }
            }
            let tem:PennyPincherTemplate=PennyPincherTemplate(id: newID, points: newCGPoints)
            template=tem
            
            
        }
        
        func encodeWithCoder(aCoder: NSCoder) {
            aCoder.encodeObject(template?.id, forKey:"templateName")
            let nsPoints=NSMutableArray()
            for p in (template?.points)!{
                let pValue=NSValue(CGPoint: p)
                nsPoints.addObject(pValue)
            }
            aCoder.encodeObject(nsPoints, forKey: "templatePoints")
        }
        
    }
    
}

