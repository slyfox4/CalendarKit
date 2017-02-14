import UIKit
import SwiftDate

public protocol DayHeaderViewDelegate: class {
  func dateHeaderDateChanged(_ newDate: Date)
}

public class DayHeaderView: UIView {

  public weak var delegate: DayHeaderViewDelegate?

  public var daysInWeek = 7

  public var calendar = Calendar.autoupdatingCurrent

  var style = DayHeaderStyle()

  var currentWeekdayIndex = -1
  var currentDate = Date().startOfDay

  var daySymbolsViewHeight: CGFloat = 20
  var pagingScrollViewHeight: CGFloat = 40
  var swipeLabelViewHeight: CGFloat = 20

  lazy var daySymbolsView: DaySymbolsView = DaySymbolsView(daysInWeek: self.daysInWeek)
  let pagingScrollView = PagingScrollView<DaySelector>()
  lazy var swipeLabelView: SwipeLabelView = SwipeLabelView(date: Date().startOfDay)

  public init(selectedDate: Date) {
    self.currentDate = selectedDate
    super.init(frame: CGRect.zero)
    configure()
    configurePages(selectedDate)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
    configurePages()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
    configurePages()
  }

  func configure() {
    [daySymbolsView, pagingScrollView, swipeLabelView].forEach {
      addSubview($0)
    }
    pagingScrollView.viewDelegate = self
    backgroundColor = style.backgroundColor
    self.swipeLabelView.date = self.currentDate
  }
  
  public func changeDate(_ date: Date) {
    self.subviews.forEach { $0.removeFromSuperview() }
    self.currentDate = date.startOfDay
    configure()
    configurePages(date)
    self.layoutSubviews()
  }

  func configurePages(_ selectedDate: Date = Date().startOfDay) {
    pagingScrollView.reset()
    for i in -1...1 {
      let date = selectedDate + i.week
      let daySelector = DaySelector(startDate: date.startWeek, daysInWeek: daysInWeek)
      pagingScrollView.reusableViews.append(daySelector)
      pagingScrollView.addSubview(daySelector)
      pagingScrollView.contentOffset = CGPoint(x: UIScreen.main.bounds.width, y: 0)
      daySelector.delegate = self
    }
    let centerDaySelector = pagingScrollView.reusableViews[1]
    centerDaySelector.selectedDate = selectedDate
    currentWeekdayIndex = centerDaySelector.selectedIndex
  }

  public func selectDate(_ selectedDate: Date) {
    let selectedDate = selectedDate
    let centerDaySelector = pagingScrollView.reusableViews[1]
    let startDate = centerDaySelector.startDate

    let daysFrom = selectedDate.day - startDate!.day

    if daysFrom < 0 {
      pagingScrollView.scrollBackward()
      currentWeekdayIndex = abs(daysInWeek + daysFrom % daysInWeek)
    } else if daysFrom > daysInWeek - 1 {
      pagingScrollView.scrollForward()
      currentWeekdayIndex = daysFrom % daysInWeek
    } else {
      centerDaySelector.selectedDate = selectedDate
    }

    swipeLabelView.date = selectedDate
    currentDate = selectedDate
  }

  public func updateStyle(_ newStyle: DayHeaderStyle) {
    style = newStyle
    daySymbolsView.updateStyle(style.daySymbols)
    swipeLabelView.updateStyle(style.swipeLabel)
    pagingScrollView.reusableViews.forEach { daySelector in
      daySelector.updateStyle(style.daySelector)
    }
    backgroundColor = style.backgroundColor
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    pagingScrollView.contentSize = CGSize(width: bounds.size.width * CGFloat(pagingScrollView.reusableViews.count), height: 0)

    daySymbolsView.anchorAndFillEdge(.top, xPad: 0, yPad: 0, otherSize: daySymbolsViewHeight)
    pagingScrollView.alignAndFillWidth(align: .underCentered, relativeTo: daySymbolsView, padding: 0, height: pagingScrollViewHeight)
    swipeLabelView.anchorAndFillEdge(.bottom, xPad: 0, yPad: 10, otherSize: swipeLabelViewHeight)
  }
}

extension DayHeaderView: DaySelectorDelegate {
  func dateSelectorDidSelectDate(_ date: Date, index: Int) {
    currentDate = date
    currentWeekdayIndex = index
    swipeLabelView.date = date
    delegate?.dateHeaderDateChanged(date)
  }
}

extension DayHeaderView: PagingScrollViewDelegate {

  func updateViewAtIndex(_ index: Int) {
    let viewToUpdate = pagingScrollView.reusableViews[index]
    let weeksToAdd = index > 1 ? 3 : -3
    viewToUpdate.startDate = viewToUpdate.startDate + weeksToAdd.week
  }

  func scrollviewDidScrollToViewAtIndex(_ index: Int) {
    let activeView = pagingScrollView.reusableViews[index]
    activeView.selectedIndex = currentWeekdayIndex
    swipeLabelView.date = activeView.selectedDate!
    delegate?.dateHeaderDateChanged(activeView.selectedDate!)
  }
}
