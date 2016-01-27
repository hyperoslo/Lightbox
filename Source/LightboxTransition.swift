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
    controller.deleteButton.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, -200)
    controller.pageLabel.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 250)

    if interactive {
      controller.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(show ? 1 : 0)
    } else {
      controller.view.alpha = show ? 1 : 0
    }
  }

  // MARK: - Pan gesture recognizer

  func handlePanGesture(gesture: UIPanGestureRecognizer) {
    let translation = gesture.translationInView(scrollView)
    let percentage = abs(translation.y) / UIScreen.mainScreen().bounds.height / 1.5

    switch gesture.state {
    case .Began:
      interactive = true
      lightboxController?.presented = false
      lightboxController?.dismissViewControllerAnimated(true, completion: nil)
      if let origin = scrollView?.frame.origin { initialOrigin = origin }
    case .Changed:
      updateInteractiveTransition(percentage)
      scrollView?.frame.origin.y = initialOrigin.y + translation.y
    default:
      interactive = false
      lightboxController?.presented = true

      if percentage > 0.3 {
        finishInteractiveTransition()
        guard let controller = lightboxController else { return }

        controller.closeButton.alpha = 0
        controller.deleteButton.alpha = 0
        controller.pageLabel.alpha = 0

        UIView.animateWithDuration(0.5, animations: {
          self.scrollView?.frame.origin.y = translation.y * 3
          controller.view.alpha = 0
          controller.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
        })
      } else {
        cancelInteractiveTransition()

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.035 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
          UIView.animateWithDuration(0.35, animations: {
            self.scrollView?.frame.origin = self.initialOrigin
          })
        }
      }
    }
  }

  public override func finishInteractiveTransition() {
    super.finishInteractiveTransition()
  }
}

// MARK: - UIViewControllerAnimatedTransitioning

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

// MARK: - UIViewControllerTransitioningDelegate

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

// MARK: - UIGestureRecognizerDelegate

extension LightboxTransition: UIGestureRecognizerDelegate {

  public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    var result = false

    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translationInView(gestureRecognizer.view)
      if fabs(translation.x) < fabs(translation.y) {
        result = true
      }
    }

    return result
  }
}
