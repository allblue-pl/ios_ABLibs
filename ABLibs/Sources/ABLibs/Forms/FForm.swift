
import Foundation

public class FForm {
    var fields: [String: FField]
    
    public init() {
        self.fields = [String: FField]()
    }
    
    public func addField(_ fieldName: String, _ field: FField) {
        fields[fieldName] = field
    }
    
    public func getField(_ fieldName: String) -> FField {
        guard let field = fields[fieldName] else {
            fatalError("FForm -> Field '\(fieldName)' does not exist.")
        }
        
        return field
    }
    
    public func getValue(_ fieldName: String) -> AnyObject? {
        guard let field = fields[fieldName] else {
            print("FForm -> Field '\(fieldName)' does not exist.")
            return nil
        }
        
        return field.getValue()
    }
    
    public func getValues() -> [String: AnyObject] {
        var values = [String: AnyObject]()
        for (fieldName, field) in fields {
            values[fieldName] = field.getValue()
        }
        
        return values
    }
    
    public func setValidatorInfo(validator: [String: AnyObject]) {
        guard let vFields = validator["fields"] as? [String: AnyObject] else {
            print("FForm -> Cannot parse validator info.")
            return
        }
        
        for (fieldName, vField_Raw) in vFields {
            guard let field = self.fields[fieldName] else {
                print("FForm -> No field '\(fieldName)' in form.")
                continue
            }
            
            guard let vField = vField_Raw as? [String: AnyObject] else {
                print("FForm -> Cannot parse field validator for '\(fieldName)'.")
                continue
            }
            
            guard let vField_Valid = vField["valid"] as? Bool else {
                print("FForm -> Cannot parse field validator for '\(fieldName)'.")
                continue
            }
            
            if vField_Valid {
                self.fields[fieldName]?.setError(nil)
            } else {
                guard let errorsArr = vField["errors"] as? [AnyObject] else {
                    print("FForm -> Cannot parse field validator for '\(fieldName)'.")
                    continue
                }
                
                var errorMessage: String = ""
                for i in 0..<errorsArr.count {
                    if i > 0 {
                        errorMessage += " "
                    }
                    guard let errorMessage_Part = errorsArr[i] as? String else {
                        print("FForm -> Cannot parse field validator for '\(fieldName)'.")
                        continue
                    }
                    errorMessage += errorMessage_Part
                }
                
                field.setError(errorMessage)
            }
        }
    }
    
    public func setValues(_ values: [String: AnyObject]) {
        for (fieldName, value) in values {
            guard let field = fields[fieldName] else {
                print("FForm -> Field '\(fieldName)' does not exist.")
                continue
            }
            
            field.setValue(value)
        }
    }
    
}
