import UIKit
import DateTools
import DynamicColor

class Event: EventDescriptor {
  var datePeriod = TimePeriod()
  var data = [String]()
  var color = UIColor.blue {
    didSet {
      textColor = color.darkened(amount: 0.3)
      backgroundColor = UIColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0.3)
    }
  }
  var backgroundColor = UIColor()
  var textColor = UIColor()
  var frame = CGRect.zero
}
