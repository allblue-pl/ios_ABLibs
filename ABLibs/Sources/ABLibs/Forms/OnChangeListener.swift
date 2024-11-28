
public class OnChangeListener {
    var listeners: [() -> Void]
    
    init() {
        self.listeners = [() -> Void]()
    }
    
    public func add(_ listener: @escaping () -> Void) {
        listeners.append(listener)
    }
    
    func trigger() {
        for listener in listeners {
            listener()
        }
    }
    
}
