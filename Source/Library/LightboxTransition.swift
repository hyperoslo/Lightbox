import UIKit

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

  func transition(_ show: Bool) {
    guard let controller = lightboxController else { return }

    if interactive {
      controller.view.backgroundColor = UIColor.black.withAlphaComponent(show ? 1 : 0)
    } else {
      controller.view.alpha = show ? 1 : 0
    }
  }

  // MARK: - Pan gesture recognizer

  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let translation = gesture.translation(in: scrollView)
    let percentage = abs(translation.y) / UIScreen.main.bounds.height / 1.5
    let velocity = gesture.velocity(in: scrollView)

    switch gesture.state {
    case .began:
      interactive = true
      lightboxController?.presented = false
      lightboxController?.dismiss(animated: true, completion: nil)
      if let origin = scrollView?.frame.origin { initialOrigin = origin }
    case .changed:
      update(percentage)
      scrollView?.frame.origin.y = initialOrigin.y + translation.y
    case .ended, .cancelled:

      var time = translation.y * 3 / abs(velocity.y)
      if time > 1 { time = 0.7 }

      interactive = false
      lightboxController?.presented = true

      if percentage > 0.1 {
        finish()
        guard let controller = lightboxController else { return }

        controller.headerView.alpha = 0
        controller.footerView.alpha = 0

        UIView.animate(withDuration: TimeInterval(time), delay: 0, options: [.allowUserInteraction], animations: {
          self.scrollView?.frame.origin.y = translation.y * 3
          controller.view.alpha = 0
          controller.view.backgroundColor = UIColor.black.withAlphaComponent(0)
          }, completion: { _ in })
      } else {
        cancel()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.035) {
          UIView.animate(withDuration: 0.35, animations: {
            self.scrollView?.frame.origin = self.initialOrigin
          })
        }
      }
    default: break
    }
  }

  override func finish() {
    super.finish()

    guard let lightboxController = lightboxController else { return }
    lightboxController.dismissalDelegate?.lightboxControllerWillDismiss(lightboxController)
  }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension LightboxTransition: UIViewControllerAnimatedTransitioning {

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.25
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    let container = transitionContext.containerView

    guard let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from),
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
      else { return }

    let firstView = dismissing ? toView : fromView
    let secondView = dismissing ? fromView : toView

    if !dismissing { transition(false) }

    container.addSubview(firstView)
    container.addSubview(secondView)

    toView.frame = container.bounds

    let duration = transitionDuration(using: transitionContext)

    UIView.animate(withDuration: duration, animations: {
      self.transition(!self.dismissing)
      }, completion: { _ in
        transitionContext.transitionWasCancelled
          ? transitionContext.completeTransition(false)
          : transitionContext.completeTransition(true)
    })
  }
}

// MARK: - UIViewControllerTransitioningDelegate

extension LightboxTransition: UIViewControllerTransitioningDelegate {

  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = true
    return self
  }

  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    dismissing = false
    return self
  }

  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }

  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }
}

// MARK: - UIGestureRecognizerDelegate

extension LightboxTransition: UIGestureRecognizerDelegate {

  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    var result = false

    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translation(in: gestureRecognizer.view)
      if fabs(translation.x) < fabs(translation.y) {
        result = true
      }
    }

    return result
  }
}
