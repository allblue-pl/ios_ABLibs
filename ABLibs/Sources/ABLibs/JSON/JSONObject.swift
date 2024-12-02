
import Foundation

public class JSONObject {
    private var json: [String: AnyObject]
    
    public init(_ json: [String: AnyObject]) {
        self.json = json
    }
    
    public func get(key: String) -> AnyObject? {
        return json[key]
    }
    
    public func isNull(key: String) -> Bool {
        return json[key] is NSNull
    }
    
    public func set(key: String, value: AnyObject) {
        json[key] = value
    }
}
