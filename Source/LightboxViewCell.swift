import UIKit

public class LightboxViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {

  public static let reuseIdentifier: String = "LightboxViewCell"

  var constraintsAdded = false

  public lazy var lightboxView: LightboxView = { [unowned self] in
    let lightboxView = LightboxView(frame: self.bounds)
    lightboxView.setTranslatesAutoresizingMaskIntoConstraints(false)

    self.contentView.addSubview(lightboxView)

    return lightboxView
    }()

  lazy var panGestureRecognizer: UIPanGestureRecognizer = {
    let panGestureRecognizer = UIPanGestureRecognizer()
    panGestureRecognizer.delegate = self
    panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
    
    return panGestureRecognizer
    }()

  public override func layoutSubviews() {
    super.layoutSubviews()
    animator = UIDynamicAnimator(referenceView: lightboxView)
    lightboxView.imageView.addGestureRecognizer(panGestureRecognizer)
    setupConstraints()
    lightboxView.updateViewLayout()
  }

  var animator: UIDynamicAnimator!
  var attachmentBehavior: UIAttachmentBehavior!
  var gravityBehaviour: UIGravityBehavior!
  var snapBehavior: UISnapBehavior!
  var parentViewController: LightboxController!

  func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
    let imageView = lightboxView.imageView
    let location = panGestureRecognizer.locationInView(lightboxView)
    let boxLocation = panGestureRecognizer.locationInView(imageView)
    let translation = panGestureRecognizer.translationInView(lightboxView)
    let maximumValue = UIScreen.mainScreen().bounds.height
    let calculation = abs(translation.y) / maximumValue
    let alphaValue = 1 - calculation

    parentViewController.view.alpha = alphaValue
    parentViewController.pageLabel.transform =
      CGAffineTransformMakeTranslation(0, calculation * 100)
    parentViewController.closeButton.transform =
      CGAffineTransformMakeTranslation(0, -(calculation * 100))

    if parentViewController.physics {
      if panGestureRecognizer.state == UIGestureRecognizerState.Began {
        animator.removeBehavior(snapBehavior)
        let centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMidX(imageView.bounds), boxLocation.y - CGRectGetMidY(imageView.bounds));
        attachmentBehavior = UIAttachmentBehavior(item: imageView, offsetFromCenter: centerOffset, attachedToAnchor: location)
        attachmentBehavior.frequency = 0
        animator.addBehavior(attachmentBehavior)
      } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
        attachmentBehavior.anchorPoint = location
      } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
        animator.removeBehavior(attachmentBehavior)
        snapBehavior = UISnapBehavior(item: imageView, snapToPoint: lightboxView.center)
        animator.addBehavior(snapBehavior)

        if translation.y > 150 || translation.y < -150 {
          animator.removeAllBehaviors()
          var gravity = UIGravityBehavior(items: [lightboxView])
          gravity.gravityDirection = CGVectorMake(0, translation.y/30)
          animator.addBehavior(gravity)

          parentViewController.dismissViewControllerAnimated(true, completion: { [unowned self] in
            self.animator.removeAllBehaviors()
            self.lightboxView.center = self.superview!.center
            self.snapBehavior = UISnapBehavior(item: imageView, snapToPoint: self.lightboxView.center)
            self.animator.addBehavior(self.snapBehavior)
            })
        } else {
          UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.parentViewController.view.alpha = 1
            self.parentViewController.pageLabel.transform = CGAffineTransformIdentity
            self.parentViewController.closeButton.transform = CGAffineTransformIdentity
          })
        }
      }
    } else {
      if panGestureRecognizer.state == .Began || panGestureRecognizer.state == .Changed {
        imageView.center = CGPointMake(imageView.center.x, UIScreen.mainScreen().bounds.height/2 + translation.y)
      } else {
        if translation.y > 150 || translation.y < -150 {
          UIView.animateWithDuration(0.3, animations: {
            imageView.center = CGPointMake(imageView.center.x, 10 * translation.y)
          })

          parentViewController.dismissViewControllerAnimated(true, completion: { [unowned self] in
            imageView.center = self.lightboxView.center
            })
        } else {
          UIView.animateWithDuration(0.3, animations: {
            self.parentViewController.view.alpha = 1
            self.parentViewController.pageLabel.transform = CGAffineTransformIdentity
            self.parentViewController.closeButton.transform = CGAffineTransformIdentity
            imageView.center = CGPointMake(imageView.center.x, UIScreen.mainScreen().bounds.height/2)
          })
        }
      }
    }
  }

  private func setupConstraints() {
    if !constraintsAdded {
      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Leading,
        relatedBy: .Equal, toItem: contentView, attribute: .Leading,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Trailing,
        relatedBy: .Equal, toItem: contentView, attribute: .Trailing,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Top,
        relatedBy: .Equal, toItem: contentView, attribute: .Top,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: lightboxView, attribute: .Bottom,
        relatedBy: .Equal, toItem: contentView, attribute: .Bottom,
        multiplier: 1, constant: 0))

      constraintsAdded = true
    }
  }
}
