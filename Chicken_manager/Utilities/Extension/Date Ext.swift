import Foundation

extension Date {
    static func ageString(from birthDate: Date, calendar: Calendar = .current) -> String {
        let now = Date()
        
        guard birthDate <= now else {
            return "0 months"
        }
        
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: now)
        
        if let years = components.year, years > 0 {
            return "\(years) years"
        }
        
        if let months = components.month, months > 0 {
            return "\(months) months"
        }
        
        return "0 months"
    }
    
    static func multiplyByWeeksSince(_ value: Int, from date: Date, calendar: Calendar = .current) -> Int {
        let now = Date()
        
        guard date <= now else {
            return 0
        }
        
        let components = calendar.dateComponents([.weekOfYear], from: date, to: now)
        let weeks = components.weekOfYear ?? 0
        
        return value * weeks
    }
}
