
import Foundation

public class JSONArray {
    public var length: Int {
        get {
            return json.count
        }
    }
    
    private var json: [AnyObject]
    
    public init(_ json: [AnyObject]) {
        self.json = json
    }
    
    public func get(_ index: Int) -> AnyObject {
        return json[index]
    }
    
    public func isNull(_ index: Int) -> Bool {
        return json[index] is NSNull
    }
    
    public func set(_ index: Int, _ value: AnyObject) {
        json[index] = value
    }
}
