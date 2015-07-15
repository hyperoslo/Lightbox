import UIKit

class LightboxTransition: NSObject {

  struct Timing {
    static let Transition: NSTimeInterval = 1
  }

  var presentingViewController = false

  func dismissLightbox(controller: UIViewController) {
    controller.view.transform = CGAffineTransformMakeScale(0, 0)
    controller.view.alpha = 0
  }

  func showLightbox(controller: UIViewController) {
    controller.view.transform = CGAffineTransformIdentity
    controller.view.alpha = 1
  }
}

// MARK: Transitioning delegate

extension LightboxTransition : UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
    return Timing.Transition
  }

  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
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
      dismissLightbox(lightboxViewController)
    }

    UIView.animateWithDuration(0.7, animations: { [unowned self] in
      self.presentingViewController
        ? self.showLightbox(lightboxViewController)
        : self.dismissLightbox(lightboxViewController)

      }, completion: { _ in
        transitionContext.completeTransition(true)
        UIApplication.sharedApplication().keyWindow!.addSubview(screens.to.view)
    })
  }
}

// MARK: Transition delegate

extension LightboxTransition : UIViewControllerTransitioningDelegate {

  func animationControllerForPresentedController(presented: UIViewController,
    presentingController presenting: UIViewController,
    sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      presentingViewController = true
      return self
  }

  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentingViewController = false
    return self
  }
}
