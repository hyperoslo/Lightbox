import UIKit
import Sugar

class LightboxTransition: UIPercentDrivenInteractiveTransition {

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let gesture = UIPanGestureRecognizer()
    gesture.addTarget(self, action: #selector(handlePanGesture(_:)))
    gesture.delegate = self

    return gesture
    }()

  var interactive = false
  var dismissing = false
  var initialOrigin = CGPoint(x: 0, y: 0)

  var scrollView: UIScrollView? {
    didSet {
      guard let scrollView = scrollView else { return }
      scrollView.addGestureRecognizer(panGestureRecognizer)
    }
  }

  weak var lightboxController: LightboxController?

  // MARK: - Transition

  func transition(show: Bool) {
    guard let controller = lightboxController else { return }

    controller.headerView.transform = show
      ? CGAffineTransformIdentity
      : CGAffineTransformMakeTranslation(0, -200)

    controller.footerView.transform = show
      ? CGAffineTransformIdentity
      : CGAffineTransformMakeTranslation(0, 250)

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
    let velocity = gesture.velocityInView(scrollView)

    switch gesture.state {
    case .Began:
      interactive = true
      lightboxController?.presented = false
      lightboxController?.dismissViewControllerAnimated(true, completion: nil)
      if let origin = scrollView?.frame.origin { initialOrigin = origin }
    case .Changed:
      updateInteractiveTransition(percentage)
      scrollView?.frame.origin.y = initialOrigin.y + translation.y
    case .Ended, .Cancelled:

      var time = translation.y * 3 / abs(velocity.y)
      if time > 1 { time = 0.7 }

      interactive = false
      lightboxController?.presented = true

      if percentage > 0.1 {
        finishInteractiveTransition()
        guard let controller = lightboxController else { return }

        controller.headerView.alpha = 0
        controller.footerView.alpha = 0

        UIView.animateWithDuration(NSTimeInterval(time), delay: 0, options: [.AllowUserInteraction], animations: {
          self.scrollView?.frame.origin.y = translation.y * 3
          controller.view.alpha = 0
          controller.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0)
          }, completion: { _ in })
      } else {
        cancelInteractiveTransition()

        delay(0.035) {
          UIView.animateWithDuration(0.35, animations: {
            self.scrollView?.frame.origin = self.initialOrigin
          })
        }
      }
    default: break
    }
  }

  override func finishInteractiveTransition() {
    super.finishInteractiveTransition()

    guard let lightboxController = lightboxController else { return }
    lightboxController.dismissalDelegate?.lightboxControllerWillDismiss(lightboxController)
  }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension LightboxTransition: UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return 0.25
  }

  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
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

  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = true
    return self
  }

  func animationControllerForPresentedController(presented: UIViewController,
                                                 presentingController presenting: UIViewController,
                                                                      sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = false
    return self
  }

  func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }

  func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }
}

// MARK: - UIGestureRecognizerDelegate

extension LightboxTransition: UIGestureRecognizerDelegate {

  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
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
