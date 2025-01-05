
import Foundation

public class ABDate {
    static public let span_Hour    = Int64(3600)
    static public let span_Day     = Int64(86400)
    
    static private var date_Format: String? = "yyyy-MM-dd"
    static private var dateTime_Format: String? = "yyyy-MM-dd HH:mm"
    static private var timeZone: TimeZone = TimeZone(identifier: "UTC")!
    
    
    static public func getDay(time: Int64) -> Int64 {
        return Int64(floor(Double(time + ABDate.getUTCOffset_Seconds(time)) / Double(ABDate.span_Day))) * ABDate.span_Day - ABDate.getUTCOffset_Seconds(time)
    }
    
    static public func getDay_UTC(time: Int64? = nil) -> Int64 {
        return Int64(floor(Double(time ?? getTime()) / Double(ABDate.span_Day))) * ABDate.span_Day
    }

    static public func getTime() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
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
            dateFormatter.dateFormat = ABDate.date_Format
            dateFormatter.timeZone = ABDate.timeZone
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
        } else {
            return "-"
        }
    }
    
    static public func format_DateTime(time: Int64?) -> String {
        if let time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = ABDate.dateTime_Format
            dateFormatter.timeZone = ABDate.timeZone
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
        } else {
            return "-"
        }
    }
    
    static public func format_Date_UTC(time: Int64?) -> String {
        if let time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = ABDate.date_Format
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(time)))
        } else {
            return "-"
        }
    }
    
    static public func format_DateTime_UTC(time: Int64?) -> String {
        if let time {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = ABDate.dateTime_Format
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
    
    static public func setDateFormat(dateFormat: String) {
        ABDate.date_Format = dateFormat
    }
    
    static public func setDateTimeFormat(dateTimeFormat: String) {
        ABDate.dateTime_Format = dateTimeFormat
    }
    
    static public func strToTime_Date_UTC(_ dateStr: String, dateFormat: String? = nil) -> Int64? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat ?? date_Format
        
        let date = dateFormatter.date(from: dateStr)
        
        if let date {
            return Int64(date.timeIntervalSince1970)
        }
        
        return nil
    }
}
