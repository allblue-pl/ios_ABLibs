
import Foundation

public class Lang {
    private static var textTranslations = [Int: String]()
    
    public static func addTexts<T : RawRepresentable & CaseIterable>(_ texts: T.Type, translations: [T: String]? = nil) where T.RawValue == String {
        for text in texts.allCases {
            if let translations {
                var textTranslationValue: String? = nil
                for (translationText, translationValue) in translations {
                    if (translationText.hashValue == text.hashValue) {
                        textTranslationValue = translationValue
                        break
                    }
                }
                
                textTranslations[text.hashValue] = textTranslationValue ?? text.rawValue
            } else {
                textTranslations[text.hashValue] = text.rawValue
            }
        }
    }
    
    public static func t(_ text: any Hashable, _ args: [String: String] = [:]) -> String {
        if var textTranslation = textTranslations[text.hashValue] {
            for (argName, argValue) in args {
                print(argName, argValue)
                textTranslation = textTranslation.replacingOccurrences(of: "{\(argName)}", with: argValue)
            }
            
            return textTranslation
        }
        
        return "#\(text) \(args)#"
    }
    
}
