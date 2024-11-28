
import SwiftUI

public struct FCheckboxView: View {
    @ObservedObject var field: FCheckbox
    let label: String
    
    public init(_ field: FField, label: String) {
        guard let parsedField = field as? FCheckbox else {
            fatalError("FCheckbox -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Toggle("", isOn: $field.value)
                    .labelsHidden()
                Text(label)
                Spacer()
            }
            
            Text(field.error ?? " ")
                .foregroundColor(.red)
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
                .padding([.horizontal], 0)
                .opacity(field.error == nil ? 0.0 : 1.0)
        }
    }
}

public class FCheckbox: ObservableObject, FField {
    @Published var value: Bool {
        didSet {
            setError(nil)
            onChangeListener.trigger()
        }
    }
    @Published var error: String?
    
    public var onChange: OnChangeListener {
        get { return onChangeListener }
    }

    fileprivate var onChangeListener: OnChangeListener
    
    public init() {
        self.value = false
        self.error = nil
        
        self.onChangeListener = OnChangeListener()
    }
    
    public func getValue() -> AnyObject {
        return value as AnyObject
    }
    
    public func setError(_ error: String?) {
        self.error = error
    }
    
    public func setValue(_ value: AnyObject) {
        if value is NSNull {
            self.value = false
            return
        }
        
        guard let parsedValue = value as? Bool else {
            print("FCheckbox -> Cannot parse value.")
            self.value = false
            return
        }
        
        self.value = parsedValue
    }
}

#Preview {
    FCheckboxView(FCheckbox(), label: "Test")
}
