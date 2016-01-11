import UIKit

public class LightboxTransition: NSObject {

  public lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGesture")

    return gesture
    }()

  var interactive = false

  public var scrollView: UIScrollView? {
    didSet {
      guard let scrollView = scrollView else { return }
      scrollView.addGestureRecognizer(panGestureRecognizer)
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGesture() {
    print("FUUUUUCK")
  }
  
}

extension LightboxTransition: UIViewControllerAnimatedTransitioning {

  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 2
  }

  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {

  }
}

extension LightboxTransition: UIViewControllerTransitioningDelegate {

}

extension LightboxTransition: UIViewControllerInteractiveTransitioning {

  public func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {

  }
}
