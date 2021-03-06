import UIKit
import Neon
import SwiftDate

protocol DayViewDataSource: class {
  func eventViewsForDate(_ date: Date) -> [EventView]
}

protocol DayViewDelegate: class {
  func dayViewDidSelectEventView(_ eventview: EventView)
  func dayViewDidLongPressEventView(_ eventView: EventView)
  func dayViewDidChageCurrentDate(_ date: Date)

}

public class DayView: UIView {

  weak var dataSource: DayViewDataSource?
  weak var delegate: DayViewDelegate?

  var headerHeight: CGFloat = 88

  let dayHeaderView = DayHeaderView()
  let timelinePager = PagingScrollView<TimelineContainer>()
  var timelineSynchronizer: ScrollSynchronizer?

  var currentDate = Date().startOfDay {
    didSet {
      delegate?.dayViewDidChageCurrentDate(currentDate)
    }
  }

  var style = CalendarStyle()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    configureTimelinePager()
    dayHeaderView.delegate = self
    addSubview(dayHeaderView)
  }

  public func changeDate(_ date: Date) {
    currentDate = date.startOfDay
    self.subviews.forEach { $0.removeFromSuperview() }
    dayHeaderView.changeDate(date)
    configure()
    self.layoutSubviews()
    self.reloadData()
  }

  public func updateStyle(_ newStyle: CalendarStyle) {
    style = newStyle
    dayHeaderView.updateStyle(style.header)
    timelinePager.reusableViews.forEach{ timelineContainer in
      timelineContainer.timeline.updateStyle(style.timeline)
      timelineContainer.backgroundColor = style.timeline.backgroundColor
    }
  }

  func configureTimelinePager() {
    var verticalScrollViews = [TimelineContainer]()
    timelinePager.reset()
    for i in -1...1 {
      let timeline = TimelineView(frame: bounds)
      timeline.frame.size.height = timeline.fullHeight
      timeline.date = currentDate + i.days

      let verticalScrollView = TimelineContainer()
      verticalScrollView.timeline = timeline
      verticalScrollView.addSubview(timeline)
      verticalScrollView.contentSize = timeline.frame.size

      timelinePager.addSubview(verticalScrollView)
      timelinePager.reusableViews.append(verticalScrollView)

      verticalScrollViews.append(verticalScrollView)
    }
    timelineSynchronizer = ScrollSynchronizer(views: verticalScrollViews)
    addSubview(timelinePager)

    timelinePager.viewDelegate = self
    let contentWidth = CGFloat(timelinePager.reusableViews.count) * UIScreen.main.bounds.width
    let size = CGSize(width: contentWidth, height: 50)
    timelinePager.contentSize = size
    timelinePager.contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
  }

  public func reloadData() {
    timelinePager.reusableViews.forEach{self.updateTimeline($0.timeline)}
  }

  override public func layoutSubviews() {
    dayHeaderView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: headerHeight)
    timelinePager.alignAndFill(align: .underCentered, relativeTo: dayHeaderView, padding: 0)
  }

  func updateTimeline(_ timeline: TimelineView) {
    guard let dataSource = dataSource else {return}
    let eventViews = dataSource.eventViewsForDate(timeline.date)
    eventViews.forEach{$0.delegate = self}
    timeline.eventViews = eventViews
  }
}

extension DayView: EventViewDelegate {
  func eventViewDidTap(_ eventView: EventView) {
    delegate?.dayViewDidSelectEventView(eventView)
  }
  func eventViewDidLongPress(_ eventview: EventView) {
    delegate?.dayViewDidLongPressEventView(eventview)
  }
}

extension DayView: PagingScrollViewDelegate {
  func updateViewAtIndex(_ index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    let amount = index > 1 ? 1 : -1
    timeline?.date = currentDate + amount.days
    updateTimeline(timeline!)
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let timeline = timelinePager.reusableViews[index].timeline
    currentDate = timeline!.date
    dayHeaderView.selectDate(currentDate)
  }
}

extension DayView: DayHeaderViewDelegate {
  public func dateHeaderDateChanged(_ newDate: Date) {
    if newDate.isBefore(date: currentDate, orEqual: false, granularity: .day) {
      let timelineContainer = timelinePager.reusableViews.first!
      timelineContainer.timeline.date = newDate
      updateTimeline(timelineContainer.timeline)
      timelinePager.scrollBackward()
    } else if newDate.isAfter(date: currentDate, granularity: .day) {
      let timelineContainer = timelinePager.reusableViews.last!
      timelineContainer.timeline.date = newDate
      updateTimeline(timelineContainer.timeline)
      timelinePager.scrollForward()
    }
  }
}
