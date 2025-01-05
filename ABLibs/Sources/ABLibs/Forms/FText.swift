
import SwiftUI

public struct FTextView<Label: View>: View {
    @ViewBuilder let label: Label
    @ObservedObject var field: FText
    let hint: String
    let labelMaxWidth: CGFloat
    let type: FTextType
    let keyboardType: UIKeyboardType
    let viewOrientation: FFieldViewOrientation
    let copyCallback: (() -> Void)?
    
    public init(_ field: FField, @ViewBuilder label: () -> Label = { EmptyView() }, labelMaxWidth: CGFloat = .infinity, hint: String, type: FTextType = .text, keyboardType: UIKeyboardType = .default, viewOrientation: FFieldViewOrientation = .vertical, copyCallback: (() -> Void)? = nil, labelStyle: ((_ label: Text) -> Void)? = nil) {
        guard let parsedField = field as? FText else {
            fatalError("FText -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label()
        self.labelMaxWidth = labelMaxWidth
        self.hint = hint
        self.type = type
        self.keyboardType = keyboardType
        self.viewOrientation = viewOrientation
        self.copyCallback = copyCallback
    }
    
    public var body: some View {
        VStack {
            if viewOrientation == .horizontal {
                HStack {
                    FTextView_Body(field, label: label, labelMaxWidth: labelMaxWidth, hint: hint, type: type, keyboardType: keyboardType, viewOrientation: viewOrientation, copyCallback: copyCallback)
                }
            } else {
                VStack(spacing: 0) {
                    FTextView_Body(field, label: label, labelMaxWidth: labelMaxWidth, hint: hint, type: type, keyboardType: keyboardType, viewOrientation: viewOrientation, copyCallback: copyCallback)
                }
            }
            
            if let fieldError = field.error {
                Text(fieldError)
                    .foregroundColor(.red)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.leading)
                    .padding([.horizontal], 0)
            }
        }
    }
}

public struct FTextView_Body<Label: View>: View {
    @ObservedObject var field: FText
    let label: Label
    let hint: String
    let labelMaxWidth: CGFloat
    let type: FTextType
    let keyboardType: UIKeyboardType
    let viewOrientation: FFieldViewOrientation
    let copyCallback: (() -> Void)?
    
    public var body: some View {
        if !(label is EmptyView) {
            HStack {
                label
                if let copyCallback {
                    Button {
                        UIPasteboard.general.string = field.value
                        copyCallback()
                    } label: {
                        Image(systemName: "document.on.document")
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        
        VStack {
            switch type {
            case .password:
                SecureField(hint, text: $field.value)
                    .padding([.horizontal], 8)
                    .frame(minHeight: 50, alignment: .center)
                    .disabled(field.disabled)
                    .foregroundStyle(field.disabled ? .gray : .primary)
            case .multiline:
                TextField(hint, text: $field.value, axis: .vertical)
                    .padding([.horizontal], 8)
                    .padding([.vertical], 8)
                    .frame(minHeight: 50, alignment: .center)
                    .lineLimit(3...)
                    .disabled(field.disabled)
                    .foregroundStyle(field.disabled ? .gray : .primary)
            default:
                TextField(hint, text: $field.value)
                    .keyboardType(keyboardType)
                    .padding([.horizontal], 8)
                    .frame(minHeight: 50, alignment: .center)
                    .disabled(field.disabled)
                    .foregroundStyle(field.disabled ? .gray : .primary)
            }
        }
        .background(Color.accentColor.opacity(0.2))
        .cornerRadius(10)
        .overlay {
            if field.error != nil {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.red)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    public init(_ field: FField, label: Label, labelMaxWidth: CGFloat, hint: String, type: FTextType, keyboardType: UIKeyboardType, viewOrientation: FFieldViewOrientation, copyCallback: (() -> Void)?) {
        guard let parsedField = field as? FText else {
            fatalError("FText -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label
        self.labelMaxWidth = labelMaxWidth
        self.hint = hint
        self.type = type
        self.keyboardType = keyboardType
        self.viewOrientation = viewOrientation
        self.copyCallback = copyCallback
    }
}

public class FText: ObservableObject, FField {
    @Published public var disabled: Bool
    @Published var error: String?
    @Published var value: String {
        didSet {
            if value == value_Last {
                return
            }
            
            value_Last = value
            setError(nil)
            onChangeListener.trigger()
        }
    }
    
    fileprivate var value_Last: String
    fileprivate var onChangeListener: OnChangeListener
    
    public init() {
        self.disabled = false
        self.error = nil
        self.value = ""
        self.value_Last = ""
        
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
            self.value = ""
            return
        }
        
        guard let parsedValue = value as? String else {
            print("FText -> Cannot parse value.")
            self.value = ""
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
