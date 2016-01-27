import UIKit

public protocol LightboxControllerPageDelegate: class {

  func lightboxController(controller: LightboxController, didMoveToPage page: Int)
}

public protocol LightboxControllerDismissalDelegate: class {

  func lightboxControllerWillDismiss(controller: LightboxController)
}

public class LightboxController: UIViewController {

  public lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.frame = UIScreen.mainScreen().bounds
    scrollView.pagingEnabled = false
    scrollView.delegate = self
    scrollView.userInteractionEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast

    return scrollView
    }()

  lazy var closeButton: UIButton = { [unowned self] in
    let title = NSAttributedString(
      string: self.config.closeButton.text,
      attributes: self.config.closeButton.textAttributes)
    let button = UIButton(type: .System)

    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.config.closeButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !self.config.deleteButton.enabled

    return button
    }()

  lazy var deleteButton: UIButton = { [unowned self] in
    let button = UIButton(type: .System)
    let title = NSAttributedString(
      string: self.config.deleteButton.text,
      attributes: self.config.deleteButton.textAttributes)

    button.setAttributedTitle(title, forState: .Normal)
    button.addTarget(self, action: "deleteButtonDidPress:",
      forControlEvents: .TouchUpInside)

    if let image = self.config.deleteButton.image {
      button.setBackgroundImage(image, forState: .Normal)
    }

    button.hidden = !self.config.deleteButton.enabled

    return button
    }()

  lazy var pageLabel: UILabel = { [unowned self] in
    let label = UILabel(frame: CGRectZero)
    label.hidden = !self.config.pageIndicator.enabled

    return label
    }()

  public private(set) var currentPage = 0 {
    didSet {
      currentPage = min(numberOfPages - 1, max(0, currentPage))

      let text = "\(currentPage + 1)/\(numberOfPages)"

      pageLabel.attributedText = NSAttributedString(string: text,
        attributes: config.pageIndicator.textAttributes)
      pageLabel.sizeToFit()

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
  var config: LightboxConfig

  // MARK: - Initializers

  public init(images: [UIImage], config: LightboxConfig = LightboxConfig.config,
    pageDelegate: LightboxControllerPageDelegate? = nil,
    dismissalDelegate: LightboxControllerDismissalDelegate? = nil) {
      self.config = config
      self.pageDelegate = pageDelegate
      self.dismissalDelegate = dismissalDelegate

      super.init(nibName: nil, bundle: nil)

      for image in images {
        let pageView = PageView(image: image)

        scrollView.addSubview(pageView)
        pageViews.append(pageView)
      }
  }

  public init(imageURLs: [NSURL], config: LightboxConfig = LightboxConfig.config,
    pageDelegate: LightboxControllerPageDelegate? = nil,
    dismissalDelegate: LightboxControllerDismissalDelegate? = nil) {
      self.config = config
      self.pageDelegate = pageDelegate
      self.dismissalDelegate = dismissalDelegate

      super.init(nibName: nil, bundle: nil)

      for imageURL in imageURLs {
        let pageView = PageView(imageURL: imageURL)

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

    [scrollView, closeButton, deleteButton, pageLabel].forEach { view.addSubview($0) }

    currentPage = 0
    configureLayout(UIScreen.mainScreen().bounds.size)
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillDisappear(animated)

    statusBarHidden = UIApplication.sharedApplication().statusBarHidden

    if config.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
  }

  public override func viewDidDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    if config.hideStatusBar {
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
      self.configureLayout(UIScreen.mainScreen().bounds.size)
      self.currentPage = Int(self.scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width)
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
      width: size.width * CGFloat(numberOfPages) + config.spacing * CGFloat(numberOfPages - 1),
      height: size.height)
    scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * (size.width + config.spacing), y: 0)

    for (index, pageView) in pageViews.enumerate() {
      var frame = scrollView.bounds
      frame.origin.x = (frame.width + config.spacing) * CGFloat(index)
      pageView.configureLayout(frame)
      if index != numberOfPages - 1 {
        pageView.frame.size.width += LightboxConfig.config.spacing
      }
    }

    let bounds = scrollView.bounds

    closeButton.frame = CGRect(
      x: bounds.width - config.closeButton.size.width - 17, y: 16,
      width: config.closeButton.size.width, height: config.closeButton.size.height)
    deleteButton.frame = CGRect(
      x: 17, y: 16,
      width: config.deleteButton.size.width, height: config.deleteButton.size.height)

    let pageLabelX: CGFloat = bounds.width < bounds.height
      ? (bounds.width - pageLabel.frame.width) / 2
      : deleteButton.center.x

    pageLabel.frame.origin = CGPoint(
      x: pageLabelX,
      y: bounds.height - pageLabel.frame.height - 20)
  }
}

// MARK: - UIScrollViewDelegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    var speed: CGFloat = velocity.x < 0 ? -2 : 2

    if velocity.x == 0 {
      speed = 0
    }

    let pageWidth = scrollView.bounds.width + config.spacing
    var x = scrollView.contentOffset.x + speed * 60.0

    if speed > 0 {
      x = ceil(x / pageWidth) * pageWidth
    } else if speed < -0 {
      x = floor(x / pageWidth) * pageWidth
    } else {
      x = round(x / pageWidth) * pageWidth
    }

    targetContentOffset.memory.x = x
    currentPage = Int(x / UIScreen.mainScreen().bounds.width)
  }
}
