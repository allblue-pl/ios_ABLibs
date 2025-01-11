
import SwiftUI

public struct FCheckboxView<Label: View>: View {
    @ObservedObject var field: FCheckbox
    @ViewBuilder let label: Label
    
    public init(_ field: FField, @ViewBuilder label: () -> Label) {
        guard let parsedField = field as? FCheckbox else {
            fatalError("FCheckbox -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label()
    }
    
    public var body: some View {
        VStack() {
            HStack {
                Toggle("", isOn: $field.value)
                    .disabled(field.disabled)
                    .labelsHidden()
                label
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            if let fieldError = field.error {
                HStack {
                    Text(fieldError)
                        .foregroundColor(.red)
                        .font(.system(size: 15))
                        .multilineTextAlignment(.leading)
                        .padding([.horizontal], 0)
                    Spacer()
                }
            }
        }
    }
}

public class FCheckbox: ObservableObject, FField {
    @Published public var disabled: Bool
    @Published var error: String?
    @Published var value: Bool {
        didSet {
            setError(nil)
            onChangeListener.trigger()
        }
    }

    fileprivate var onChangeListener: OnChangeListener
    
    public init() {
        self.disabled = false
        self.error = nil
        self.value = false
        
        self.onChangeListener = OnChangeListener()
    }
    
    public func addOnValueChangedListener(_ onValueChanged: @escaping () -> Void) {
        onChangeListener.add(onValueChanged)
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
