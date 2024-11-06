
import SwiftUI

public struct FPickerView<FPV: FPickerValue>: View {
    @ObservedObject var field: FPicker<FPV>
    let hint: String
    let label: String?
    
    public init(_ field: FField, hint: String, label: String? = nil) {
        guard let parsedField = field as? FPicker<FPV> else {
            fatalError("FNumberPicker -> Wrong field type.")
        }
        
        self.field = parsedField
        self.hint = hint
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let label {
                Text(label)
            }
            HStack() {
                Text(hint)
                Spacer()
                Picker(hint, selection: $field.value) {
                    ForEach(field.selection) { selectionValue in
                        Text(selectionValue.title)
                            .tag(selectionValue)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding([.horizontal], 8)
            .padding([.vertical], 8)
            .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
            .background(Color.accentColor.opacity(0.2))
            .cornerRadius(10)
            
            Text(field.error ?? " ")
                .foregroundColor(.red)
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
                .padding([.horizontal], 0)
                .opacity(field.error == nil ? 0.0 : 1.0)
        }
    }
    
}

public class FPicker<FPV: FPickerValue>: ObservableObject, FField {
    @Published fileprivate var selection: [FPV]
    @Published fileprivate var value: FPV {
        didSet {
            setError(nil)
            if let listener = listeners_OnChange {
                listener()
            }
        }
    }
    @Published var error: String?
    
    fileprivate var nullValue: AnyObject?
    fileprivate var listeners_OnChange: (() -> Void)?
    
    public init(selection: [FPV], nullValue: AnyObject? = nil) {
        self.selection = selection
        self.value = selection[0]
        self.error = nil
        self.nullValue = nullValue
        self.listeners_OnChange = nil
    }
            
    public func getValue() -> AnyObject {
        if let nullValue {
            if value.isEqualTo(nullValue) {
                return NSNull()
            }
        }
        
        return value.getValue()
    }
    
    public func setError(_ error: String?) {
        self.error = error
    }
    
    public func setListener_OnChange(execute listener: @escaping () -> Void) {
        listeners_OnChange = listener
    }
    
    public func setValue(_ value: AnyObject) {
        var parsedValue: AnyObject
        if value is NSNull {
            if let nullValue {
                parsedValue = nullValue
            } else {
                print("FNumberPicker -> No null value in selection.")
                if selection.count > 0 {
                    self.value = selection[0]
                }
                return
            }
        } else {
            parsedValue = value
        }
        
        for selectionValue in selection {
            if selectionValue.isEqualTo(parsedValue) {
                self.value = selectionValue
                return
            }
        }
        
        print("FNumberPicker -> Cannot find value in selection.")
        if selection.count > 0 {
            self.value = selection[0]
        }
    }
    
    
}

public protocol FPickerValue: Identifiable, Hashable {
    var title: String {
        get
    }
    
    func getValue() -> AnyObject
    func isEqualTo(_ compareValue: AnyObject) -> Bool
}


public struct FIntPickerValue: FPickerValue {
    public var id: Int {
        return value
    }
    
    public var title: String
    public let value: Int
    
    
    public init(title: String, value: Int) {
        self.title = title
        self.value = value
    }
    
    
    public func getValue() -> AnyObject {
        return value as AnyObject
    }
    
    public func isEqualTo(_ compareValue: AnyObject) -> Bool {
        guard let compareValue_Parsed = compareValue as? Int else {
            print("FIntPicker -> Cannot parse compare value.")
            return false
        }
        
        return value == compareValue_Parsed
    }
    
}
