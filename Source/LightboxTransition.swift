import UIKit

public class LightboxTransition: UIPercentDrivenInteractiveTransition {

  public lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: "handlePanGesture:")
    gesture.delegate = self

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
    controller.closeButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -200)
    controller.pageControl.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 200)

    if interactive {
      controller.view.alpha = show ? 1 : 0.95
    } else {
      controller.view.alpha = show ? 1 : 0
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(scrollView)
    let percentage = abs(translation.y) / UIScreen.mainScreen().bounds.height * 1.75

    switch gesture.state {
    case .Began:
      interactive = true
      print(interactive)
      lightboxController?.dismissViewControllerAnimated(true, completion: nil)
      print(interactive)
      if let origin = scrollView?.frame.origin { initialOrigin = origin }

      break
    case .Changed:
      updateInteractiveTransition(percentage)
      scrollView?.frame.origin.y = initialOrigin.y + translation.y

      break
    case .Ended:
      print(interactive)
      interactive = false
      print(interactive)

      percentage > 0.5 ? finishInteractiveTransition() : cancelInteractiveTransition()

      UIView.animateWithDuration(0.25, animations: {
        self.scrollView?.frame.origin.y = self.initialOrigin.y
      })
    default:
      break
    }
  }
}

extension LightboxTransition: UIViewControllerAnimatedTransitioning {

  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.25
  }

  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    guard let container = transitionContext.containerView(),
      fromView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view,
      toView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)?.view
      else { return }

    let firstView = dismissing ? toView : fromView
    let secondView = dismissing ? fromView : toView

    if !dismissing { transition(false) }

    container.addSubview(firstView)
    container.addSubview(secondView)

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

// MARK: Gesture recognizer delegate methods

extension LightboxTransition : UIGestureRecognizerDelegate {

  public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translationInView(gestureRecognizer.view)
      if fabs(translation.x) < fabs(translation.y) {
        return true
      }
    }
    return false
  }
}
