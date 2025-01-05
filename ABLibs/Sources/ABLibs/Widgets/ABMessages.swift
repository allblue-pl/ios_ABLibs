
import SwiftUI

public struct ABMessagesView: View {
    var foregroundColor: Color
    @ObservedObject var model: ABMessages
    
    public var body: some View {
        ZStack {
            if model.loading_Show {
                VStack {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32.0)
                        .symbolEffect(
                            .variableColor
                        )
                        .foregroundStyle(
                            Color(foregroundColor)
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.5))
            }
        }
        .alert(
            model.message_Title,
            isPresented: $model.message_Show,
            actions: {
                Button("OK", role: .cancel) {
                    if let callback = model.message_Callback {
                        callback()
                    }
                    
                    model.clearMessage()
                }
            },
            message: {
                HStack {
                    Text(model.message_Message)
                        .foregroundStyle(Color.red)
                }
            }
        )
        .alert(
            model.confirmation_Title,
            isPresented: $model.confirmation_Show,
            actions: {
                Button(model.confirmation_YesText, role: .destructive) {
                    model.confirmation_Callback(true)
                    model.clearConfirmation()
                }
                Button(model.confirmation_NoText, role: .cancel) {
                    model.confirmation_Callback(false)
                    model.clearConfirmation()
                }
            },
            message: {
                Text(model.confirmation_Message)
            }
        )
    }
    
    public init(_ model: ABMessages, foregroundColor: Color = Color.primary)  {
        self.model = model
        self.foregroundColor = foregroundColor
    }
    
}

public struct ABToastView: View {
    @ObservedObject var model: ABMessages
    
    public var body: some View {
        ForEach (model.toast_Messages, id: \.self) { message in
            HStack {
                Spacer()
                Text(message)
                    .padding(15)
                Spacer()
            }.padding([.vertical], 0)
        }
    }
    
    public init(_ model: ABMessages) {
        self.model = model
    }
}

public class ABMessages: ObservableObject {
    
    @Published fileprivate var loading_Show: Bool
    
    @Published fileprivate var message_Show: Bool
    @Published fileprivate var message_Title: String
    @Published fileprivate var message_Message: String
    @Published fileprivate var message_SystemImageName: String
    var message_Callback: (() -> Void)?
    
    @Published fileprivate var confirmation_Show: Bool
    @Published fileprivate var confirmation_Title: String
    @Published fileprivate var confirmation_Message: String
    @Published fileprivate var confirmation_YesText: String
    @Published fileprivate var confirmation_NoText: String
    fileprivate var confirmation_Callback: (_ result: Bool) -> Void

    @Published fileprivate var toast_Messages: [String]
    
    public init() {
        self.loading_Show = false
        
        self.message_Show = false
        self.message_Title = ""
        self.message_Message = ""
        self.message_SystemImageName = "check"
        self.message_Callback = nil
        
        self.confirmation_Show = false
        self.confirmation_Title = ""
        self.confirmation_Message = ""
        self.confirmation_YesText = ""
        self.confirmation_NoText = ""
        self.confirmation_Callback = { result in print("Confirmation callback not set.") }
        
        self.toast_Messages = []
    }
    
    public func hideLoading() {
        DispatchQueue.main.async {
            self.loading_Show = false
        }
    }
    
    public func showConfirmation(_ title: String, _ message: String, yesText: String, noText: String, execute callback: @escaping (_ result: Bool) -> Void) {
        self.confirmation_Callback = callback
        DispatchQueue.main.async {
            self.confirmation_Title = title
            self.confirmation_Message = message
            self.confirmation_YesText = yesText
            self.confirmation_NoText = noText
            self.confirmation_Show = true
        }
    }
    
    public func showLoading() {
        DispatchQueue.main.async {
            self.loading_Show = true
        }
    }
    
    public func showMessage(_ title: String, _ message: String, _ systemImageName: String, callback: (() -> Void)?) {
        message_Callback = callback
        DispatchQueue.main.async {
            self.message_Title = title
            self.message_Message = message
            self.message_SystemImageName = systemImageName
            self.message_Show = true
        }
    }
    
    public func showMessage_Failure(_ title: String, _ content: String, callback: (() -> Void)? = nil) {
        self.showMessage(title, content, "exclamationmark.circle.fill", callback: callback)
    }
    
    public func showMessage_Success(_ title: String, _ content: String, callback: (() -> Void)? = nil) {
        self.showMessage(title, content, "checkmark.circle.fill", callback: callback)
    }
    
    public func showToast(_ message: String) {
        DispatchQueue.main.async {
            self.toast_Messages.append(message)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.toast_Messages.removeFirst()
            }
        }
    }
    
    fileprivate func clearConfirmation() {
        confirmation_Callback = { result in print("Confirmation callback not set.") }
        DispatchQueue.main.async {
            self.confirmation_Title = ""
            self.confirmation_Message = ""
            self.confirmation_YesText = ""
            self.confirmation_NoText = ""
        }
    }
    
    fileprivate func clearMessage() {
        message_Callback = nil
        DispatchQueue.main.async {
            self.message_Title = ""
            self.message_Message = ""
        }
    }
    
}

fileprivate struct ToastMessage: Identifiable {
    let id: UUID
    var message: String
}
