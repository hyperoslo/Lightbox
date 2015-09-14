import UIKit

protocol LightboxTransitionDelegate: class {

  func transitionDidDismissController(controller: LightboxController)
}

class LightboxTransition: UIPercentDrivenInteractiveTransition {

  struct Timing {
    static let transition: NSTimeInterval = 0.5
  }

  lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
    let panGestureRecognizer = UIPanGestureRecognizer()
    panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
    panGestureRecognizer.delegate = self

    return panGestureRecognizer
    }()

  var presentingViewController = false
  var interactive = false
  var animator: UIDynamicAnimator!
  var attachmentBehavior: UIAttachmentBehavior!
  var gravityBehaviour: UIGravityBehavior!
  var snapBehavior: UISnapBehavior!
  weak var sourceViewController: LightboxController!
  weak var delegate: LightboxTransitionDelegate?
  weak var lightboxController: LightboxController!

  weak var sourceViewCell: LightboxViewCell! {
    didSet {
      sourceViewCell.addGestureRecognizer(panGestureRecognizer)
    }
  }

  func transition(controller: LightboxController, show: Bool) {
    controller.view.backgroundColor = .blackColor()
    controller.view.alpha = show ? 1 : 0.01
    controller.collectionView.alpha = show ? 1 : 0
    lightboxController = controller

    if UIDevice.currentDevice().orientation != UIDeviceOrientation.LandscapeLeft
      && UIDevice.currentDevice().orientation != UIDeviceOrientation.LandscapeRight{
        if sourceViewCell != nil {
          self.sourceViewCell.lightboxView.imageView.center = CGPointMake(
            UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height/2)
        }

        controller.pageLabel.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(0, 250)
        for button in [controller.closeButton, controller.deleteButton] {
          button.transform = show
          ? CGAffineTransformIdentity
          : CGAffineTransformMakeTranslation(0, -250)
        }
    }

    if presentingViewController {
      controller.collectionView.transform = show ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.5, 0.5)
    }
  }
}

// MARK: Transitioning delegate

extension LightboxTransition : UIViewControllerAnimatedTransitioning {

  func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return Timing.transition
  }

  func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    let containerView = transitionContext.containerView()

    let screens : (from: UIViewController, to: UIViewController) = (
      transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!,
      transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!)

    let lightboxViewController = !presentingViewController
      ? screens.from as! LightboxController
      : screens.to as! LightboxController

    let viewController = !presentingViewController
      ? screens.to as UIViewController
      : screens.from as UIViewController

    for controller in [viewController, lightboxViewController] {
      containerView?.addSubview(controller.view)
    }

    if presentingViewController {
      transition(lightboxViewController, show: false)
    }

    UIView.animateWithDuration(Timing.transition, animations: { [unowned self] in
      self.transition(lightboxViewController, show: self.presentingViewController)
      }, completion: { _ in
        if transitionContext.transitionWasCancelled() {
          UIView.animateWithDuration(Timing.transition/2, animations: { [unowned self] in
            self.sourceViewCell.lightboxView.imageView.center = CGPointMake(
              UIScreen.mainScreen().bounds.width/2, UIScreen.mainScreen().bounds.height/2)
            self.transition(lightboxViewController, show: true)
            }, completion: { finished in
              transitionContext.completeTransition(false)
              UIApplication.sharedApplication().keyWindow?.addSubview(screens.from.view)
          })
        } else {
          if self.lightboxController.view.alpha < 0.97 && !self.presentingViewController {
            UIView.animateWithDuration(0.6, animations: { () -> Void in
              self.lightboxController.view.alpha = 0
              }, completion: { _ in
                transitionContext.completeTransition(true)
            })
          } else {
            transitionContext.completeTransition(true)
            UIApplication.sharedApplication().keyWindow?.addSubview(screens.to.view)
          }
        }
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

  func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }

  func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    return interactive ? self : nil
  }
}

// MARK: Interactive transition delegate

extension LightboxTransition {

  func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    let imageView = sourceViewCell.lightboxView.imageView
    let location = panGestureRecognizer.locationInView(sourceViewCell.lightboxView)
    let boxLocation = panGestureRecognizer.locationInView(imageView)
    let translation = panGestureRecognizer.translationInView(sourceViewCell.lightboxView)
    let percentage = fabs(translation.y / UIScreen.mainScreen().bounds.height)

    if sourceViewCell.parentViewController.physics {
      if panGestureRecognizer.state == UIGestureRecognizerState.Began {
        interactive = true
        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
        animator.removeBehavior(snapBehavior)
        let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(imageView.bounds),
          boxLocation.y - CGRectGetMidY(imageView.bounds))
        attachmentBehavior = UIAttachmentBehavior(item: imageView,
          offsetFromCenter: centerOffset, attachedToAnchor: location)
        attachmentBehavior.frequency = 0
        animator.addBehavior(attachmentBehavior)
      } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
        attachmentBehavior.anchorPoint = location
        updateInteractiveTransition(percentage)
      } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
        interactive = false

        if percentage > 0.25 {
          finishInteractiveTransition()
          delegate?.transitionDidDismissController(lightboxController)
        } else {
          cancelInteractiveTransition()

          animator.removeBehavior(attachmentBehavior)
          snapBehavior = UISnapBehavior(item: imageView,
            snapToPoint: sourceViewCell.lightboxView.center)
          animator.addBehavior(snapBehavior)
        }
      }
    } else {
      if panGestureRecognizer.state == .Began {
        interactive = true
        sourceViewController.dismissViewControllerAnimated(true, completion: nil)
      } else if panGestureRecognizer.state == .Changed {
        imageView.center = CGPointMake(imageView.center.x, UIScreen.mainScreen().bounds.height/2 + translation.y)
        updateInteractiveTransition(percentage)
      } else {
        interactive = false
        if percentage > 0.25 {
          finishInteractiveTransition()
          delegate?.transitionDidDismissController(lightboxController)
        } else {
          cancelInteractiveTransition()
        }
      }
    }
  }

  override func finishInteractiveTransition() {
    super.finishInteractiveTransition()

    let point = (sourceViewCell.lightboxView.imageView.center.y - UIScreen.mainScreen().bounds.height/2) * 10

    UIView.animateWithDuration(Timing.transition, animations: { [unowned self] in
      self.sourceViewCell.lightboxView.imageView.center = CGPointMake(
        UIScreen.mainScreen().bounds.width/2, point)
      }, completion: { _ in
        if self.sourceViewCell.parentViewController.physics {
          self.animator.removeBehavior(self.attachmentBehavior)
          self.snapBehavior = UISnapBehavior(item: self.sourceViewCell.lightboxView.imageView,
            snapToPoint: self.sourceViewCell.lightboxView.center)
          self.animator.addBehavior(self.snapBehavior)
        }
    })

    sourceViewController.collectionView.scrollRectToVisible(
      CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height),
      animated: false)
  }
}

// MARK: Gesture recognizer delegate methods

extension LightboxTransition : UIGestureRecognizerDelegate {

  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
      let translation = panGestureRecognizer.translationInView(sourceViewCell.superview!)
      if fabs(translation.x) < fabs(translation.y) {
        return true
      }
    }
    return false
  }
}
