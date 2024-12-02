
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
    
    public func set(_ index: Int, value: AnyObject) {
        json[index] = value
    }
}
