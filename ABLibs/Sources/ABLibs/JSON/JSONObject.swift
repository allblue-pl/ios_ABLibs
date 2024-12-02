
import Foundation

public class JSONObject {
    public var rawValue: [String: AnyObject] {
        get {
            return json
        }
    }
    private var json: [String: AnyObject]
    
    public init(_ json: [String: AnyObject]) {
        self.json = json
    }
    
    public func get(_ key: String) -> AnyObject? {
        return json[key]
    }
    
    public func isNull(_ key: String) -> Bool {
        return json[key] is NSNull
    }
    
    public func set(_ key: String, _ value: AnyObject) {
        json[key] = value
    }
}
