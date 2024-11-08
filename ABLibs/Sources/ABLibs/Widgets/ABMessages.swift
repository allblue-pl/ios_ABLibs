
import SwiftUI

public struct ABMessagesView: View {
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
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.8))
            }
        }
        .alert(
            model.message_Title,
            isPresented: $model.message_Show,
            actions: {
                Button("OK") {
                    
                }
            },
            message: {
                Image(systemName: "exclamationmark.triangle")
                Text(model.message_Message)
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
                Image(systemName: "questionmark.square.dashed")
                Text(model.confirmation_Message)
            }
        )
    }
    
    public init(_ model: ABMessages) {
        self.model = model
    }
    
}

public struct ABToastView: View {
    @ObservedObject var model: ABMessages
    
    public var body: some View {
        
        if model.toast_Show {
            Text(self.model.toast_Message)
                .padding(15)
                .tint(.accentColor)
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
    var message_Callback: (() -> Void)?
    
    @Published fileprivate var confirmation_Show: Bool
    @Published fileprivate var confirmation_Title: String
    @Published fileprivate var confirmation_Message: String
    @Published fileprivate var confirmation_YesText: String
    @Published fileprivate var confirmation_NoText: String
    fileprivate var confirmation_Callback: (_ result: Bool) -> Void

    @Published fileprivate var toast_Show: Bool
    @Published fileprivate var toast_Message: String

    private let toast_Queue: DispatchQueue
    private var toast_CallsCount: Int
    
    public init() {
        self.loading_Show = false
        
        self.message_Show = false
        self.message_Title = ""
        self.message_Message = ""
        self.message_Callback = nil
        
        self.confirmation_Show = false
        self.confirmation_Title = ""
        self.confirmation_Message = ""
        self.confirmation_YesText = ""
        self.confirmation_NoText = ""
        self.confirmation_Callback = { result in print("Confirmation callback not set.") }
        
        self.toast_Queue = DispatchQueue(label: "ABMessages.toast.queue", attributes: .concurrent)
        self.toast_CallsCount = 0
        self.toast_Show = false
        self.toast_Message = ""
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
    
    public func showMessage(_ title: String, _ message: String, callback: (() -> Void)?) {
        message_Callback = callback
        DispatchQueue.main.async {
            self.message_Title = title
            self.message_Message = message
            self.message_Show = true
        }
    }
    
    public func showMessage_Failure(_ title: String, _ content: String, callback: (() -> Void)? = nil) {
        self.showMessage(title, content, callback: callback)
    }
    
    public func showToast(_ message: String) {
        toast_Queue.sync {
            toast_Message = message
            toast_Show = true
            toast_CallsCount += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.toast_Queue.sync {
                self.toast_CallsCount -= 1
                if self.toast_CallsCount <= 0 {
                    self.toast_CallsCount = 0
                    self.toast_Show = false
                    self.toast_Message = ""
                }
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
