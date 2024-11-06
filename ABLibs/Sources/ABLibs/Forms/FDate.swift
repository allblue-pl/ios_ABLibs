
import SwiftUI

import ABLibs

public struct FDateView: View {
    @ObservedObject var field: FDate
    let label: String?
    let closeText: String
    
    public init(_ field: FField, label: String?, closeText: String) {
        guard let parsedField = field as? FDate else {
            fatalError("FDate -> Wrong field type.")
        }
        
        self.field = parsedField
        self.label = label
        self.closeText = closeText
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if let label {
                    Text(label)
                }
                
                HStack {
                    TextField(label ?? "", text: $field.date_Str)
                        .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        .frame(minHeight: 50, alignment: .center)
                        .padding([.horizontal], 8)
                    
                    if !field.date_Empty {
                        Button {
                            field.setValue(NSNull())
                        } label: {
                            Image(systemName: "multiply.circle")
                                .padding(15)
                        }
                    }
                }
                .background(Color.accentColor.opacity(0.2))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    field.showPicker = true
                }
                
                Text(field.error ?? " ")
                    .foregroundColor(.red)
                    .font(.system(size: 15))
                    .multilineTextAlignment(.leading)
                    .padding([.horizontal], 0)
                    .opacity(field.error == nil ? 0.0 : 1.0)
            }
            .frame(maxWidth: .infinity)
            .fullScreenCover(isPresented: $field.showPicker) {
                FDateModalView(field: field, label: label, closeText: closeText)
            }
        }
        .frame(alignment: .leading)
    }
}

struct FDateModalView: View {
//    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var field: FDate
    let label: String?
    let closeText: String
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Button(action: {
                    field.afterDateSet()
                    field.showPicker = false
                }, label: {
                    Label(closeText, systemImage: "multiply.circle")
                })
                .padding(30)
                
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .onTapGesture {
                        field.afterDateSet()
                        field.showPicker = false
                    }
                
                DatePicker(
                    label ?? "",
                    selection: $field.date,
                    displayedComponents: [.date]
                )
                .background(Color.gray)
                .cornerRadius(10)
                .datePickerStyle(.graphical)
                
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .onTapGesture {
                        field.afterDateSet()
                        field.showPicker = false
                    }
            }
        }
    }
    
}

public class FDate: ObservableObject, FField {
    @Published fileprivate var date: Date {
        didSet {
            afterDateSet()
            showPicker = false
        }
    }
    @Published var date_Str: String
    @Published var date_Empty: Bool
    
    @Published fileprivate var error: String?
    @Published var showPicker: Bool
    
    let defaultValue: Int64
    let utc: Bool
    
    public init(defaultValue: Int64, utc: Bool = true) {
        self.date_Empty = true
        self.date_Str = "-"
        self.error = nil
        self.showPicker = false
        self.defaultValue = defaultValue
        self.utc = utc
        
        self.date = Date()
    }
    
    func afterDateSet() {
        setError(nil)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        date_Str = dateFormatter.string(from: date)
        date_Empty = false
    }
    
    public func getValue() -> AnyObject {
        if date_Empty {
            return NSNull()
        }
        
        let time = Int64(date.timeIntervalSince1970)
        
        return time as AnyObject
    }
    
    public func setError(_ error: String?) {
        self.error = error
    }
    
    public func setValue(_ value: AnyObject) {
        if value is NSNull {
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
        
        date = Date(timeIntervalSince1970: TimeInterval(parseValue(parsedValue)))
        afterDateSet()
    }
    
    private func parseValue(_ value: Int64) -> Int64 {
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
    
}
