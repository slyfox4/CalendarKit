import UIKit
import SwiftDate

open class DayViewController: UIViewController, DayViewDelegate {

  public lazy var dayView: DayView = DayView()

  override open func viewDidLoad() {
    super.viewDidLoad()
    self.edgesForExtendedLayout = UIRectEdge()
    view.addSubview(dayView)
    view.tintColor = UIColor.red

    dayView.dataSource = self
    dayView.delegate = self
    dayView.reloadData()
  }

  open override func viewDidLayoutSubviews() {
    dayView.fillSuperview()
  }

  open func reloadData() {
    dayView.reloadData()
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    dayView.updateStyle(newStyle)
  }
    
  public func changeDate(_ date: Date) {
    dayView.changeDate(date)
  }
}

extension DayViewController: DayViewDataSource {
  open func eventViewsForDate(_ date: Date) -> [EventView] {
    return [EventView]()
  }

  // MARK: DayViewDelegate

  open func dayViewDidSelectEventView(_ eventview: EventView) {

  }

  open func dayViewDidLongPressEventView(_ eventView: EventView) {

  }

  open func dayViewDidChageCurrentDate(_ date: Date) {
    
  }
}
