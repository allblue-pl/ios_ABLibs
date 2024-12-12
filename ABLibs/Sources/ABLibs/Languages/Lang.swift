
import Foundation

public class Lang {
    
    static private var textFn: (_ text: String) -> String = { text in
        return "###NO_TEXT_FN_SET###"
    }
    
    static public func setTextFn(execute fn: @escaping (_ text: String) -> String) {
        Lang.textFn = fn
    }
    
    static public func t(_ text: String) -> String {
        return textFn(text)
    }
    
}
