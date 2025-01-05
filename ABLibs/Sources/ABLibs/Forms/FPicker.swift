
import SwiftUI

public struct FPickerView<Label: View, FPV: FPickerValue>: View {
    @ObservedObject var field: FPicker<FPV>
    @ViewBuilder let label: Label
    
    let labelMaxWidth: CGFloat?
    let hint: String
    let viewOrientation: FFieldViewOrientation
    let copyCallback: (() -> Void)?
    
    public init(_ field: FPicker<FPV>, @ViewBuilder label: () -> Label = { EmptyView() }, labelMaxWidth: CGFloat = .infinity, hint: String, viewOrientation: FFieldViewOrientation = .vertical, copyCallback: (() -> Void)? = nil) {
        guard let parsedField = field as? FPicker<FPV> else {
            fatalError("FNumberPicker -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label()
        self.labelMaxWidth = labelMaxWidth
        self.hint = hint
        self.viewOrientation = viewOrientation
        self.copyCallback = copyCallback
    }
    
    public var body: some View {
        if viewOrientation == .horizontal {
            HStack {
                FPickerView_Body<FPV, Label>(field, label: label, labelMaxWidth: labelMaxWidth, hint: hint, viewOrientation: viewOrientation, copyCallback: copyCallback)
            }
        } else {
            VStack(spacing: 0) {
                FPickerView_Body<FPV, Label>(field, label: label, labelMaxWidth: labelMaxWidth, hint: hint, viewOrientation: viewOrientation, copyCallback: copyCallback)
            }
        }
        
        if let fieldMessage = field.error {
            Text(fieldMessage)
                .foregroundColor(.red)
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
                .padding([.horizontal], 0)
        }
    }
    
}

public struct FPickerView_Body<FPV: FPickerValue, Label: View>: View {
    @ObservedObject var field: FPicker<FPV>
    
    let label: Label
    let labelMaxWidth: CGFloat?
    let hint: String
    let viewOrientation: FFieldViewOrientation
    let copyCallback: (() -> Void)?
    
    public var body: some View {
        if !(label is EmptyView) {
            HStack() {
                label
                if let copyCallback {
                    Button {
                        UIPasteboard.general.string = field.value.toString()
                        copyCallback()
                    } label: {
                        Image(systemName: "document.on.document")
                    }
                }
                Spacer()
            }
            .frame(maxWidth: labelMaxWidth)
        }
        HStack() {
//                Text(hint)
//                Spacer()
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
    }
    
    public init(_ field: FField, label: Label, labelMaxWidth: CGFloat?, hint: String, viewOrientation: FFieldViewOrientation, copyCallback: (() -> Void)?) {
        guard let parsedField = field as? FPicker<FPV> else {
            fatalError("FNumberPicker -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label
        self.labelMaxWidth = labelMaxWidth
        self.hint = hint
        self.viewOrientation = viewOrientation
        self.copyCallback = copyCallback
    }
}

public class FPicker<FPV: FPickerValue>: ObservableObject, FField {
    @Published public var disabled: Bool
    @Published var error: String?
    @Published fileprivate var selection: [FPV]
    @Published fileprivate var value: FPV {
        didSet {
            setError(nil)
            onChangeListener.trigger()
        }
    }
    
    fileprivate var onChangeListener: OnChangeListener
    
    fileprivate var nullValue: AnyObject?
    
    public init(selection: [FPV], nullValue: AnyObject? = nil) {
        self.disabled = false
        self.selection = selection
        self.value = selection[0]
        self.error = nil
        self.nullValue = nullValue
        
        self.onChangeListener = OnChangeListener()
    }
            
    public func addOnValueChangedListener(_ onValueChanged: @escaping () -> Void) {
        onChangeListener.add(onValueChanged)
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
    func toString() -> String
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
    
    public func toString() -> String {
        return String(value)
    }
}
