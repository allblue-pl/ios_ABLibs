
import Foundation

public class ABDate {
    
    static public let span_Hour    = Int64(3600)
    static public let span_Day     = Int64(86400)
    
    static private var date_Format: String? = nil
    static private var timeZone: TimeZone = TimeZone(identifier: "UTC")!
    
    
    static public func getDay(time: Int64) -> Int64 {
        return Int64(floor(Double(time + ABDate.getUTCOffset_Seconds(time)) / Double(ABDate.span_Day))) * ABDate.span_Day - ABDate.getUTCOffset_Seconds(time)
    }
    
    static public func getDay_UTC(time: Int64) -> Int64 {
        return Int64(floor(Double(time) / Double(ABDate.span_Day))) * ABDate.span_Day
    }

    static public func getTime() -> Int64 {
        return Int64(Date().timeIntervalSince1970 / 1000)
    }
    
    static public func getTime_WithNegativeUTCOffset() -> Int64 {
        let time = getTime()
        return time - getUTCOffset_Seconds(time)
    }
    
    static public func getTime_WithUTCOffset() -> Int64 {
        let time = getTime()
        return time + getUTCOffset_Seconds(time)
    }
    
    static public func getUTCOffset(_ time: Int64) -> Int64 {
        return Int64(timeZone.secondsFromGMT()) / span_Hour
    }
    
    static public func getUTCOffset_Seconds(_ time: Int64) -> Int64 {
        return Int64(timeZone.secondsFromGMT())
    }
    
    static public func format_Date(time: Int64?) -> String {
        if let time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeZone = ABDate.timeZone
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
        } else {
            return "-"
        }
    }
    
    static public func format_Date_UTC(time: Int64?) -> String {
        if let time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
        } else {
            return "-"
        }
    }
    
    static public func setTimeZone(identifier: String) {
        guard let timeZone = TimeZone(identifier: identifier) else {
            assertionFailure("Cannot identify timezone '\(identifier)'.")
            timeZone = TimeZone(identifier: "UTC")!
            return
        }
        
        ABDate.timeZone = timeZone
    }
    
}
