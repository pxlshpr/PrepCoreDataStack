import Foundation

extension Range where Bound == Date {
    var dates: [Date] {
        Array(stride(
            from: lowerBound.startOfDay,
            to: upperBound.startOfDay,
            by: 60*60*24
        ))
    }
    
    var calendarDayStrings: [String] {
        dates.map { $0.calendarDayString }
    }
}
