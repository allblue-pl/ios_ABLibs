
import Foundation

public protocol FField {
    
    func getValue() -> AnyObject
    func setError(_ errorMessage: String?)
    func setValue(_ value: AnyObject)
    
}
