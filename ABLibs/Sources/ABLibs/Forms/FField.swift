
import Foundation

public protocol FField {
    var onChange: OnChangeListener { get }
    
    func getValue() -> AnyObject
    func setError(_ errorMessage: String?)
    func setValue(_ value: AnyObject)
    
}
