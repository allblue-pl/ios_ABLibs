
import SwiftUI

import ABLibs

public struct FDateView<Label: View>: View {
    @ViewBuilder let label: Label
    @ObservedObject var field: FDate
    let labelMaxWidth: CGFloat
    let hint: String?
    let closeText: String
    let viewOrientation: FFieldViewOrientation
    let copyCallback: (() -> Void)?
    
    public init(_ field: FField, @ViewBuilder label: () -> Label = { EmptyView() }, labelMaxWidth: CGFloat = .infinity, hint: String? = nil, closeText: String, viewOrientation: FFieldViewOrientation = .vertical, copyCallback: (() -> Void)? = nil) {
        guard let parsedField = field as? FDate else {
            fatalError("FDate -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label()
        self.labelMaxWidth = labelMaxWidth
        self.hint = hint
        self.closeText = closeText
        self.copyCallback = copyCallback
        self.viewOrientation = viewOrientation
    }
    
    public var body: some View {
        VStack {
            if viewOrientation == .horizontal {
                HStack {
                    FDateView_Body(field, label: label, labelMaxWidth: labelMaxWidth, hint: hint, closeText: closeText, viewOrientation: viewOrientation, copyCallback: copyCallback)
                }
                .fullScreenCover(isPresented: $field.showPicker) {
                    FDateModalView(field: field, label: hint, closeText: closeText)
                }
            } else {
                VStack(spacing: 0) {
                    FDateView_Body(field, label: label, labelMaxWidth: labelMaxWidth, hint: hint, closeText: closeText, viewOrientation: viewOrientation, copyCallback: copyCallback)
                }
                .fullScreenCover(isPresented: $field.showPicker) {
                    FDateModalView(field: field, label: hint, closeText: closeText)
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
}

public struct FDateView_Body<Label: View>: View {
    @ObservedObject var field: FDate
    let label: Label
    let labelMaxWidth: CGFloat
    let hint: String?
    let closeText: String
    let viewOrientation: FFieldViewOrientation
    let copyCallback: (() -> Void)?
    
    public var body: some View {
        if !(label is EmptyView) {
            HStack() {
                label
                if let copyCallback {
                    Button {
                        UIPasteboard.general.string = field.date_Str
                        copyCallback()
                    } label: {
                        Image(systemName: "document.on.document")
                    }
                }
                Spacer()
            }
            .frame(maxWidth: labelMaxWidth)
        }
        
        HStack {
            TextField(hint ?? "", text: $field.date_Str)
                .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .frame(minHeight: 50, alignment: .center)
                .padding([.horizontal], 8)
                .foregroundStyle(field.disabled ? .gray : .primary)
            
            if !field.date_Empty && !field.disabled {
                Button {
                    field.setValue(NSNull())
                } label: {
                    Image(systemName: "multiply.circle")
                        .padding([.horizontal], 5)
                }
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
        .onTapGesture {
            if !field.disabled {
                field.showPicker = true
            }
        }
    }
    
    public init(_ field: FField, label: Label, labelMaxWidth: CGFloat, hint: String?, closeText: String, viewOrientation: FFieldViewOrientation, copyCallback: (() -> Void)?) {
        guard let parsedField = field as? FDate else {
            fatalError("FDate -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label
        self.labelMaxWidth = labelMaxWidth
        self.hint = hint
        self.closeText = closeText
        self.copyCallback = copyCallback
        self.viewOrientation = viewOrientation
    }
}

struct FDateModalView: View {
    @ObservedObject var field: FDate
    let label: String?
    let closeText: String
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .onTapGesture {
//                        field.afterDateSet()
                        field.showPicker = false
                    }
                
                DatePicker(
                    label ?? "",
                    selection: $field.date,
                    displayedComponents: [.date]
                )
                .cornerRadius(10)
                .datePickerStyle(.graphical)
                
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .onTapGesture {
//                        field.afterDateSet()
                        field.showPicker = false
                    }
                
                HStack {
                    Button(action: {
//                        field.afterDateSet()
                        field.showPicker = false
                    }, label: {
                        Label(Lang.t(TABLibs.texts_Cancel), systemImage: "multiply.circle")
                            .foregroundStyle(Color.red)
                    })
                    .padding(30)
                    
                    Button(action: {
                        field.afterDateSet()
                        field.showPicker = false
                        field.onChangeListener.trigger()
                    }, label: {
                        Label(Lang.t(TABLibs.texts_Ok), systemImage: "checkmark")
                    })
                    .padding(30)
                }
            }
        }
    }
    
}

public class FDate: ObservableObject, FField {
    static private func parseValue(_ value: Int64, utc: Bool) -> Int64 {
        var parsedValue = value
        parsedValue -= Int64(TimeZone.current.secondsFromGMT())
        if utc {
            parsedValue = ABDate.getDay_UTC(time: parsedValue)
        } else {
            parsedValue += ABDate.getUTCOffset_Seconds(parsedValue)
            parsedValue = ABDate.getDay(time: parsedValue)
        }
        
        return parsedValue
    }
    
    @Published public var disabled: Bool
    @Published fileprivate var date: Date {
        didSet {
            afterDateSet()
            showPicker = false
            onChangeListener.trigger()
        }
    }
    @Published var date_Str: String
    @Published var date_Empty: Bool
    
    @Published fileprivate var error: String?
    @Published var showPicker: Bool
    
    fileprivate var onChangeListener: OnChangeListener
    
    fileprivate let defaultValue: Int64
    fileprivate let utc: Bool
    
    public init(defaultValue: Int64, utc: Bool = true) {
        self.disabled = false
        self.date_Empty = true
        self.date_Str = "-"
        self.error = nil
        self.showPicker = false
        self.defaultValue = defaultValue
        self.utc = utc
        self.date = Date(timeIntervalSince1970: TimeInterval(FDate.parseValue(defaultValue, utc: utc)))
        
        self.onChangeListener = OnChangeListener()
    }
    
    public func addOnValueChangedListener(_ onValueChanged: @escaping () -> Void) {
        onChangeListener.add(onValueChanged)
    }
    
    func afterDateSet() {
        setError(nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        date_Str = dateFormatter.string(from: date)
        date_Empty = false
    }
    
    public func getRawValue() -> Int64? {
        if date_Empty {
            return nil
        }
        
        return Int64(date.timeIntervalSince1970)
    }
    
    public func getValue() -> AnyObject {
        if let time = getRawValue() {
            return time as AnyObject
        }
        
        return NSNull()
    }
    
    public func setError(_ error: String?) {
        self.error = error
    }
    
    public func setValue(_ value: AnyObject) {
        if value is NSNull {
            date = Date(timeIntervalSince1970: TimeInterval(FDate.parseValue(defaultValue, utc: utc)))
            date_Str = "-"
            date_Empty = true
            return
        }
        
        guard var parsedValue = value as? Int64 else {
            print("FText -> Cannot parse value.")
            date_Str = "-"
            date_Empty = true
            return
        }
        
        if utc {
            parsedValue = ABDate.getDay_UTC(time: parsedValue)
        } else {
            parsedValue += ABDate.getUTCOffset_Seconds(parsedValue)
            parsedValue = ABDate.getDay(time: parsedValue)
        }
        parsedValue -= Int64(TimeZone.current.secondsFromGMT())
        
        date = Date(timeIntervalSince1970: TimeInterval(parsedValue))
        afterDateSet()
    }
    
}
