import UIKit

public class LightboxTransition: UIPercentDrivenInteractiveTransition {

  public lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGesture:")

    return gesture
    }()

  var interactive = false
  var dismissing = false
  var initialOrigin = CGPoint(x: 0, y: 0)

  public var scrollView: UIScrollView? {
    didSet {
      guard let scrollView = scrollView else { return }
      scrollView.addGestureRecognizer(panGestureRecognizer)
    }
  }

  public var lightboxController: LightboxController?

  // MARK: - Transition

  func transition(show: Bool) {
    guard let controller = lightboxController else { return }

    controller.view.alpha = show ? 1 : 0
  }

  // MARK: - Pan gesture recognizer

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(scrollView)
    let percentage: CGFloat = 0.5

    switch panGestureRecognizer.state {
    case .Began:
      lightboxController?.dismissViewControllerAnimated(true, completion: nil)
      interactive = true
      if let origin = scrollView?.frame.origin { initialOrigin = origin }

      break
    case .Changed:
      updateInteractiveTransition(percentage)
      scrollView?.frame.origin.y = initialOrigin.y + translation.x

      break
    default:
      interactive = false
      percentage > 0.5 ? finishInteractiveTransition() : cancelInteractiveTransition()

      break
    }
  }
}

extension LightboxTransition: UIViewControllerAnimatedTransitioning {

  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.5
  }

  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard let container = transitionContext.containerView(),
      fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view,
      toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
      else { return }

    if !dismissing {
      transition(false)
      container.addSubview(fromView)
      container.addSubview(toView)
    } else {
      container.addSubview(toView)
      container.addSubview(fromView)
    }

    let duration = transitionDuration(transitionContext)

    UIView.animateWithDuration(duration, animations: {
      self.transition(!self.dismissing)
      }, completion: { _ in
        transitionContext.transitionWasCancelled()
          ? transitionContext.completeTransition(false)
          : transitionContext.completeTransition(true)
    })
  }
}

extension LightboxTransition: UIViewControllerTransitioningDelegate {

  public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = true
    return self
  }

  public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = false
    return self
  }

  public func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }

  public func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }
}
