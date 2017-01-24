import UIKit
import DateTools
import Neon
import DynamicColor

protocol EventViewDelegate: class {
  func eventViewDidTap(_ eventView: EventView)
  func eventViewDidLongPress(_ eventview: EventView)
}

protocol EventDescriptor {
  var datePeriod: TimePeriod {get}
  var data: [String] {get}
  var color: UIColor {get}
  var textColor: UIColor {get}
  var backgroundColor: UIColor {get}
  var frame: CGRect {get set}
}

open class EventView: UIView {

  weak var delegate: EventViewDelegate?

  var descriptor: EventDescriptor?

//  var color = UIColor() {
//    didSet {
//      textView.textColor = color.darkened(amount: 0.3)
//      backgroundColor = UIColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0.3)
//    }
//  }

  var contentHeight: CGFloat {
    //TODO: use strings array to calculate height
    return textView.height
  }

  lazy var textView: UITextView = {
    let view = UITextView()
    view.font = UIFont.boldSystemFont(ofSize: 12)
    view.isUserInteractionEnabled = false
    view.backgroundColor = UIColor.clear

    return view
  }()

  lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EventView.tap))
  lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(EventView.longPress))

//  var datePeriod = TimePeriod()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configure()
  }

  func configure() {
    clipsToBounds = true
    [tapGestureRecognizer, longPressGestureRecognizer].forEach {addGestureRecognizer($0)}

    addSubview(textView)
  }

  func updateWithDescriptor(event: EventDescriptor) {
    descriptor = event
    textView.text = event.data.reduce("", {$0 + $1 + "\n"})
    textView.textColor = event.textColor
    backgroundColor = event.backgroundColor
  }

  func tap() {
    delegate?.eventViewDidTap(self)
  }

  func longPress() {
    delegate?.eventViewDidLongPress(self)
  }

  override open func draw(_ rect: CGRect) {
    super.draw(rect)
    let color = descriptor?.color ?? tintColor ?? UIColor.blue
    let context = UIGraphicsGetCurrentContext()
    context!.interpolationQuality = .none
    context?.saveGState()
    context?.setStrokeColor(color.cgColor)
    context?.setLineWidth(3)
    context?.translateBy(x: 0, y: 0.5)
    let x: CGFloat = 0
    let y: CGFloat = 0
    context?.beginPath()
    context?.move(to: CGPoint(x: x, y: y))
    context?.addLine(to: CGPoint(x: x, y: (bounds).height))
    context?.strokePath()
    context?.restoreGState()
  }

  override open func layoutSubviews() {
    super.layoutSubviews()
    textView.fillSuperview()
  }
}
