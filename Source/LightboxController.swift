import UIKit
import Hue
import Sugar

public protocol LightboxControllerPageDelegate: class {

  func lightboxController(controller: LightboxController, didMoveToPage page: Int)
}

public protocol LightboxControllerDismissalDelegate: class {

  func lightboxControllerWillDismiss(controller: LightboxController)
}

public class LightboxController: UIViewController {

  // MARK: - Internal views

  lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.frame = self.screenBounds
    scrollView.pagingEnabled = false
    scrollView.delegate = self
    scrollView.userInteractionEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast

    return scrollView
    }()

  lazy var overlayTapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: "overlayViewDidTap:")

    return gesture
  }()

  lazy var effectView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .Dark)
    let view = UIVisualEffectView(effect: effect)
    view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

    return view
  }()

  lazy var backgroundView: UIImageView = {
    let view = UIImageView()
    view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]

    return view
  }()

  // MARK: - Public views

  public private(set) lazy var headerView: HeaderView = { [unowned self] in
    let view = HeaderView()
    view.delegate = self

    return view
    }()

  public private(set) lazy var footerView: FooterView = { [unowned self] in
    let view = FooterView()
    view.delegate = self

    return view
    }()

  public private(set) lazy var overlayView: UIView = { [unowned self] in
    let view = UIView(frame: CGRectZero)
    let gradient = CAGradientLayer()
    let colors = [UIColor.hex("090909").alpha(0), UIColor.hex("040404")]

    view.addGradientLayer(colors)
    view.alpha = 0

    return view
    }()

  var screenBounds: CGRect {
    return UIScreen.mainScreen().bounds
  }

  // MARK: - Properties

  public private(set) var currentPage = 0 {
    didSet {
      currentPage = min(numberOfPages - 1, max(0, currentPage))
      footerView.updatePage(currentPage + 1, numberOfPages)
      footerView.updateText(pageViews[currentPage].image.text)

      if currentPage == numberOfPages - 1 {
        seen = true
      }

      pageDelegate?.lightboxController(self, didMoveToPage: currentPage)

      if let image = images[currentPage].image where dynamicBackground {
        delay(0.125) {
          self.backgroundView.image = image
          self.backgroundView.layer.addAnimation(CATransition(), forKey: kCATransitionFade)
        }
      }
    }
  }

  public var numberOfPages: Int {
    return pageViews.count
  }

  public var dynamicBackground: Bool = false {
    didSet {
      if dynamicBackground == true {
        effectView.frame = view.frame
        backgroundView.frame = effectView.frame
        view.insertSubview(effectView, atIndex: 0)
        view.insertSubview(backgroundView, atIndex: 0)
      } else {
        effectView.removeFromSuperview()
        backgroundView.removeFromSuperview()
      }
    }
  }

  public var spacing: CGFloat = 20 {
    didSet {
      configureLayout()
    }
  }

  public var images: [LightboxImage] {
    get {
      return pageViews.map { $0.image }
    }
    set(value) {
      configurePages(value)
    }
  }

  public weak var pageDelegate: LightboxControllerPageDelegate?
  public weak var dismissalDelegate: LightboxControllerDismissalDelegate?
  public internal(set) var presented = true
  public private(set) var seen = false

  lazy var transitionManager: LightboxTransition = LightboxTransition()
  var pageViews = [PageView]()
  var statusBarHidden = false

  // MARK: - Initializers

  public init(images: [LightboxImage] = [], startIndex index: Int = 0) {

    super.init(nibName: nil, bundle: nil)

    configurePages(images)
    currentPage = index
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

    [scrollView, overlayView, headerView, footerView].forEach { view.addSubview($0) }
    overlayView.addGestureRecognizer(overlayTapGestureRecognizer)

    goTo(currentPage, animated: false)
    configureLayout()
  }

  public override func viewWillAppear(animated: Bool) {
    super.viewWillDisappear(animated)

    statusBarHidden = UIApplication.sharedApplication().statusBarHidden

    if LightboxConfig.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
  }

  public override func viewDidDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    if LightboxConfig.hideStatusBar {
      UIApplication.sharedApplication().setStatusBarHidden(statusBarHidden, withAnimation: .Fade)
    }
  }

  // MARK: - Rotation

  override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
      self.configureLayout(size)
      }, completion: nil)
  }

  // MARK: - Configuration

  func configurePages(images: [LightboxImage]) {
    pageViews.forEach { $0.removeFromSuperview() }
    pageViews = []

    for image in images {
      let pageView = PageView(image: image)
      pageView.pageViewDelegate = self

      scrollView.addSubview(pageView)
      pageViews.append(pageView)
    }

    configureLayout()
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

  // MARK: - Actions

  func overlayViewDidTap(tapGestureRecognizer: UITapGestureRecognizer) {
    footerView.expand(false)
  }

  // MARK: - Layout

  public func configureLayout(size: CGSize = UIScreen.mainScreen().bounds.size) {
    scrollView.frame.size = size
    scrollView.contentSize = CGSize(
      width: size.width * CGFloat(numberOfPages) + spacing * CGFloat(numberOfPages - 1),
      height: size.height)
    scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * (size.width + spacing), y: 0)

    for (index, pageView) in pageViews.enumerate() {
      var frame = scrollView.bounds
      frame.origin.x = (frame.width + spacing) * CGFloat(index)
      pageView.frame = frame
      pageView.configureLayout()
      if index != numberOfPages - 1 {
        pageView.frame.size.width += spacing
      }
    }

    let bounds = scrollView.bounds
    let headerViewHeight = headerView.closeButton.frame.height > headerView.deleteButton.frame.height
      ? headerView.closeButton.frame.height
      : headerView.deleteButton.frame.height

    headerView.frame = CGRect(x: 0, y: 16, width: bounds.width, height: headerViewHeight)
    footerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 70)

    [headerView, footerView].forEach { $0.configureLayout() }

    footerView.frame.origin.y = bounds.height - footerView.frame.height

    overlayView.frame = scrollView.frame
    overlayView.resizeGradientLayer()
  }
}

// MARK: - UIScrollViewDelegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    var speed: CGFloat = velocity.x < 0 ? -2 : 2

    if velocity.x == 0 {
      speed = 0
    }

    let pageWidth = scrollView.bounds.width + spacing
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

  func pageViewDidZoom(pageView: PageView) {
    let hidden = pageView.zoomScale != 1.0
    let duration = hidden ? 0.1 : 1.0
    let alpha: CGFloat = hidden ? 0.0 : 1.0

    UIView.animateWithDuration(duration, delay: 0.5, options: [], animations: {
      self.headerView.alpha = alpha
      self.footerView.alpha = alpha
      }, completion: nil)
  }
}

// MARK: - HeaderViewDelegate

extension LightboxController: HeaderViewDelegate {

  func headerView(headerView: HeaderView, didPressDeleteButton deleteButton: UIButton) {
    deleteButton.enabled = false

    guard numberOfPages != 1 else {
      pageViews.removeAll()
      self.headerView(headerView, didPressCloseButton: headerView.closeButton)
      return
    }

    let prevIndex = currentPage
    currentPage == numberOfPages - 1 ? previous() : next()

    self.currentPage--
    self.pageViews.removeAtIndex(prevIndex).removeFromSuperview()

    delay(0.5) {
      self.configureLayout()
      self.currentPage = Int(self.scrollView.contentOffset.x / self.screenBounds.width)
      deleteButton.enabled = true
    }
  }

  func headerView(headerView: HeaderView, didPressCloseButton closeButton: UIButton) {
    closeButton.enabled = false
    presented = false
    dismissalDelegate?.lightboxControllerWillDismiss(self)
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - FooterViewDelegate

extension LightboxController: FooterViewDelegate {

  public func footerView(footerView: FooterView, didExpand expanded: Bool) {
    footerView.frame.origin.y = screenBounds.height - footerView.frame.height
    overlayView.alpha = expanded ? 1.0 : 0.0
    headerView.deleteButton.alpha = expanded ? 0.0 : 1.0
  }
}
