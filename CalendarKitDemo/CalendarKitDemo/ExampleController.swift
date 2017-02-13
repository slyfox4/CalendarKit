import UIKit
import CalendarKit
import SwiftDate

enum SelectedStyle {
  case Dark
  case Light
}

class ExampleController: DayViewController {

  var data = [["Breakfast at Tiffany's",
               "New York, 5th avenue"],

              ["Workout",
               "Tufteparken"],

              ["Meeting with Alex",
               "Home",
               "Oslo, Tjuvholmen"],

              ["Beach Volleyball",
               "Ipanema Beach",
               "Rio De Janeiro"],

              ["WWDC",
               "Moscone West Convention Center",
               "747 Howard St"],

              ["Google I/O",
               "Shoreline Amphitheatre",
               "One Amphitheatre Parkway"],

              ["✈️️ to Svalbard ❄️️❄️️❄️️❤️️",
               "Oslo Gardermoen"],

              ["💻📲 Developing CalendarKit",
               "🌍 Worldwide"],

              ["Software Development Lecture",
               "Mikpoli MB310",
               "Craig Federighi"],

              ]

  var colors = [UIColor.blue,
                UIColor.yellow,
                UIColor.black,
                UIColor.green,
                UIColor.red]

  var currentStyle = SelectedStyle.Light

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "CalendarKit Demo"
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Dark",
                                                        style: .done,
                                                        target: self,
                                                        action: #selector(ExampleController.changeStyle))
    navigationController?.navigationBar.isTranslucent = false
    reloadData()
  }

  func changeStyle() {
    var title: String!
    var style: CalendarStyle!

    if currentStyle == .Dark {
      currentStyle = .Light
      title = "Dark"
      style = StyleGenerator.defaultStyle()
    } else {
      title = "Light"
      style = StyleGenerator.darkStyle()
      currentStyle = .Dark
    }
    updateStyle(style)
    navigationItem.rightBarButtonItem!.title = title
    navigationController?.navigationBar.barTintColor = style.header.backgroundColor
    navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:style.header.swipeLabel.textColor]
  }

  // MARK: DayViewDataSource

  override func eventViewsForDate(_ date: Date) -> [EventView] {
    var date = date + Int(arc4random_uniform(10) + 5).hour
    var events = [EventView]()

    for _ in 0...5 {
      let event = EventView()
      let duration = Int(arc4random_uniform(160) + 60)
      let datePeriod = DateTimeInterval(start: date, end: date + duration.minute)


      event.datePeriod = datePeriod
      var info = data[Int(arc4random_uniform(UInt32(data.count)))]
        info.append("\(datePeriod.start.string(format: .custom("HH:mm"))) - \(datePeriod.end.string(format: .custom("HH:mm")))")
      event.data = info
      event.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
      events.append(event)

      let nextOffset = Int(arc4random_uniform(250) + 40)
      date = date + nextOffset.minute
    }

    return events
  }

  // MARK: DayViewDelegate

  override func dayViewDidSelectEventView(_ eventview: EventView) {

    print("Event has been selected: \(eventview.data)")
  }
  
  override func dayViewDidLongPressEventView(_ eventView: EventView) {
    print("Event has been longPressed: \(eventView.data)")
  }
    
  override func dayViewDidChageCurrentDate(_ date: Date) {
    print("New date has been selected: \(date)")
  }
    
}
