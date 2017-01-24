import UIKit

class ReusePool<T: UIView> {
  var storage: [T]

  init() {
    storage = [T]()
  }

  func enqueue(views: [T]) {
    var views = views
    views.forEach{$0.removeFromSuperview()}
    storage.append(contentsOf: views)
  }

  func dequeue() -> T {
    guard !storage.isEmpty else {return T()}
    return storage.removeLast()
  }
}
