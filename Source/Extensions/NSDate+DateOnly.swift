import Foundation
import DateToolsSwift

extension Date {
  func dateOnly() -> Date {
    return Calendar.autoupdatingCurrent.startOfDay(for: self).add(TimeChunk(seconds: 0, minutes: 0, hours: 12, days: 0, weeks: 0, months: 0, years: 0))
  }
}
