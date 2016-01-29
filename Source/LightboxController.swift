import UIKit
import Hue

public protocol LightboxControllerPageDelegate: class {

  func lightboxController(controller: LightboxController, didMoveToPage page: Int)
}

public protocol LightboxControllerDismissalDelegate: class {

  func lightboxControllerWillDismiss(controller: LightboxController)
}

public class LightboxController: UIViewController {

  public lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.frame = self.screenBounds
    scrollView.pagingEnabled = false
    scrollView.delegate = self
    scrollView.userInteractionEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast

    return scrollView
    }()

  lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.model.closeButton.text,
      attributes: self.model.closeButton.textAttributes)
    let button = UIButton(type: .System)

    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.model.closeButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.alpha = self.model.closeButton.enabled ? 1.0 : 0.0

    return button
    }()

  lazy var deleteButton: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    let title = NSAttributedString(
      string: self.model.deleteButton.text,
      attributes: self.model.deleteButton.textAttributes)

    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "deleteButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.model.deleteButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.alpha = self.model.deleteButton.enabled ? 1.0 : 0.0

    return button
    }()

  lazy var footerView: FooterView = { [unowned self] in
    let view = FooterView(model: self.model)
    return view
    }()

  lazy var overlayView: UIView = { [unowned self] in
    let view = UIView(frame: CGRectZero)
    let gradient = CAGradientLayer()
    var colors = [UIColor.hex("090909").CGColor, UIColor.hex("040404").CGColor]

    gradient.frame = view.bounds
    gradient.colors = colors
    view.layer.insertSublayer(gradient, atIndex: 0)
    view.hidden = !self.model.infoLabel.enabled
    view.alpha = 0

    return view
    }()

  var screenBounds: CGRect {
    return UIScreen.mainScreen().bounds
  }

  public private(set) var currentPage = 0 {
    didSet {
      currentPage = min(numberOfPages - 1, max(0, currentPage))
      footerView.updatePage(currentPage + 1, numberOfPages)

      if currentPage == numberOfPages - 1 {
        seen = true
      }

      pageDelegate?.lightboxController(self, didMoveToPage: currentPage)
    }
  }

  public var numberOfPages: Int {
    return pageViews.count
  }

  public var images: [UIImage] {
    return pageViews.filter{ $0.imageView.image != nil}.map{ $0.imageView.image! }
  }

  public var imageURLs: [NSURL] {
    return pageViews.filter{ $0.imageURL != nil}.map{ $0.imageURL! }
  }

  public weak var pageDelegate: LightboxControllerPageDelegate?
  public weak var dismissalDelegate: LightboxControllerDismissalDelegate?
  public var presented = true
  public private(set) var seen = false

  lazy var transitionManager: LightboxTransition = LightboxTransition()
  var pageViews = [PageView]()
  var statusBarHidden = false
  var model: LightboxModel

  // MARK: - Initializers

  public init(model: LightboxModel) {
    self.model = model
    LightboxModel.sharedModel = model

    super.init(nibName: nil, bundle: nil)

    for index in 0..<numberOfPages {
      let pageView = PageView(model: model, index: index)
      pageView.pageViewDelegate = self

      scrollView.addSubview(pageView)
      pageViews.append(pageView)
    }
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.blackColor()
    transitionManager.lightboxController = self
    transitionManager.scrollView = scrollView
    transitioningDelegate = transitionManager

    [scrollView, closeButton, deleteButton, overlayView, footerView].forEach { view.addSubview($0) }

    currentPage = 0
    configureLayout(screenBounds.size)
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillDisappear(animated)

    statusBarHidden = UIApplication.sharedApplication().statusBarHidden

    if model.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
  }

  public override func viewDidDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    if model.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(statusBarHidden, withAnimation: .Fade)
    }
  }

  // MARK: - Rotation

  override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    configureLayout(size)
  }

  // MARK: - Pagination

  public func goTo(page: Int, animated: Bool = true) {
    guard page >= 0 && page < numberOfPages else {
      return
    }

    currentPage = page

    var offset = scrollView.contentOffset
    offset.x = CGFloat(page) * scrollView.frame.width

    scrollView.setContentOffset(offset, animated: animated)
  }

  public func next(animated: Bool = true) {
    goTo(currentPage + 1, animated: animated)
  }

  public func previous(animated: Bool = true) {
    goTo(currentPage - 1, animated: animated)
  }

  // MARK: - Action methods

  func deleteButtonDidPress(button: UIButton) {
    button.enabled = false

    guard numberOfPages != 1 else {
      pageViews.removeAll()
      closeButtonDidPress(closeButton)
      return
    }

    let prevIndex = currentPage
    currentPage == numberOfPages - 1 ? previous() : next()

    self.currentPage--
    self.pageViews.removeAtIndex(prevIndex).removeFromSuperview()

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
      self.configureLayout(self.screenBounds.size)
      self.currentPage = Int(self.scrollView.contentOffset.x / self.screenBounds.width)
      button.enabled = true
    }
  }

  public func closeButtonDidPress(button: UIButton) {
    button.enabled = false
    presented = false
    dismissalDelegate?.lightboxControllerWillDismiss(self)
    dismissViewControllerAnimated(true, completion: nil)
  }

  // MARK: - Layout

  public func configureLayout(size: CGSize) {
    scrollView.frame.size = size
    scrollView.contentSize = CGSize(
      width: size.width * CGFloat(numberOfPages) + model.spacing * CGFloat(numberOfPages - 1),
      height: size.height)
    scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * (size.width + model.spacing), y: 0)

    for (index, pageView) in pageViews.enumerate() {
      var frame = scrollView.bounds
      frame.origin.x = (frame.width + model.spacing) * CGFloat(index)
      pageView.configureLayout(frame)
      if index != numberOfPages - 1 {
        pageView.frame.size.width += model.spacing
      }
    }

    let bounds = scrollView.bounds

    closeButton.frame = CGRect(
      x: bounds.width - model.closeButton.size.width - 17, y: 16,
      width: model.closeButton.size.width, height: model.closeButton.size.height)
    deleteButton.frame = CGRect(
      x: 17, y: 16,
      width: model.deleteButton.size.width, height: model.deleteButton.size.height)

    overlayView.frame = scrollView.frame
  }
}

// MARK: - UIScrollViewDelegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    var speed: CGFloat = velocity.x < 0 ? -2 : 2

    if velocity.x == 0 {
      speed = 0
    }

    let pageWidth = scrollView.bounds.width + model.spacing
    var x = scrollView.contentOffset.x + speed * 60.0

    if speed > 0 {
      x = ceil(x / pageWidth) * pageWidth
    } else if speed < -0 {
      x = floor(x / pageWidth) * pageWidth
    } else {
      x = round(x / pageWidth) * pageWidth
    }

    targetContentOffset.memory.x = x
    currentPage = Int(x / screenBounds.width)
  }
}

// MARK: - PageViewDelegate

extension LightboxController: PageViewDelegate {

  func pageVewDidZoom(pageView: PageView) {
    let hidden = pageView.zoomScale != 1.0
    let duration = hidden ? 0.0 : 1.0

    UIView.animateWithDuration(duration, delay: 0.5, options: [], animations: { () -> Void in
      self.closeButton.alpha = 1.0
      self.deleteButton.alpha = 1.0
      self.footerView.alpha = 1.0
      }, completion: nil)
  }
}
