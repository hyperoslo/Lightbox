import UIKit

class LightboxTransition: NSObject {

  private struct Timing {
    static let Transition: NSTimeInterval = 1
  }

  private var presentingViewController = false

  private func dismissLightbox(controller: UIViewController) {

  }

  private func showLightbox(controller: UIViewController) {

  }
}

// MARK: Transitioning delegate

extension LightboxTransition : UIViewControllerAnimatedTransitioning {

  private func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return Timing.Transition
  }

  private func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView()
    let duration = transitionDuration(transitionContext)

    let screens : (from: UIViewController, to: UIViewController) = (
      transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
      transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)

    let lightboxViewController = !presentingViewController
      ? screens.from as UIViewController
      : screens.to as UIViewController

    let viewController = !presentingViewController
      ? screens.to as UIViewController
      : screens.from as UIViewController

    containerView.addSubview(viewController.view)
    containerView.addSubview(lightboxViewController.view)

    if presentingViewController {
      transition(campaignReadyViewController, show: false)
    }

    UIView.animateWithDuration(0.7, animations: { [unowned self] in
      self.transition(campaignReadyViewController, show: self.presentingViewController)
      }, completion: { _ in
        transitionContext.completeTransition(true)
        UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
    })
  }
}

// MARK: Transition delegate

extension TransitionManager : UIViewControllerTransitioningDelegate {

  private func animationControllerForPresentedController(presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      presentingViewController = true
      return self
  }

  private func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentingViewController = false
    return self
  }
}
