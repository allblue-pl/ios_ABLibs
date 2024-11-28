
import SwiftUI

public struct FTextView: View {
    @ObservedObject var field: FText
    let hint: String
    let label: String?
    let type: FTextType
    let keyboardType: UIKeyboardType
    let copyCallback: (() -> Void)?
    
    public init(_ field: FField, hint: String, label: String? = nil, type: FTextType = .text, keyboardType: UIKeyboardType = .default, copyCallback: (() -> Void)? = nil) {
        guard let parsedField = field as? FText else {
            fatalError("FText -> Wrong field type.")
        }
        
        self.field = parsedField
        self.hint = hint
        self.label = label
        self.type = type
        self.keyboardType = keyboardType
        self.copyCallback = copyCallback
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if let label {
                HStack {
                    Text(label)
                    if let copyCallback {
                        Button {
                            UIPasteboard.general.string = field.value
                            copyCallback()
                        } label: {
                            Image(systemName: "document.on.document")
                        }
                    }
                }
            }
            VStack {
                switch type {
                case .password:
                    SecureField(hint, text: $field.value)
                        .padding([.horizontal], 8)
                        .frame(minHeight: 50, alignment: .center)
                case .multiline:
                    TextField(hint, text: $field.value, axis: .vertical)
                        .padding([.horizontal], 8)
                        .padding([.vertical], 8)
                        .frame(minHeight: 50, alignment: .center)
                        .lineLimit(3...)
                default:
                    TextField(hint, text: $field.value)
                        .keyboardType(keyboardType)
                        .padding([.horizontal], 8)
                        .frame(minHeight: 50, alignment: .center)
                }
            }
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

public class FText: ObservableObject, FField {
    @Published var value: String {
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
        self.value = ""
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
            self.value = "-"
            return
        }
        
        guard let parsedValue = value as? String else {
            print("FText -> Cannot parse value.")
            self.value = "-"
            return
        }
        
        self.value = parsedValue
    }
    
}

public enum FTextType {
    case int
    case text
    case password
    case multiline
}

#Preview {
    FTextView(FText(), hint: "Test")
}
