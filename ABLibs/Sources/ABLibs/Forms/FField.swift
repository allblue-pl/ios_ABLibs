
import Foundation

public protocol FField {
    var disabled: Bool { get set }
    
    func addOnValueChangedListener(_ onValueChanged: @escaping () -> Void) -> Void
    func getValue() -> AnyObject
    func setError(_ errorMessage: String?)
    func setValue(_ value: AnyObject)
    
}

public enum FFieldViewOrientation {
    case horizontal
    case vertical
}
