import UIKit

public protocol LightboxControllerPageDelegate: class {

  func lightboxController(_ controller: LightboxController, didMoveToPage page: Int)
}

public protocol LightboxControllerDismissalDelegate: class {

  func lightboxControllerWillDismiss(_ controller: LightboxController)
}

public protocol LightboxControllerTouchDelegate: class {

  func lightboxController(_ controller: LightboxController, didTouch image: LightboxImage, at index: Int)
}

open class LightboxController: UIViewController {

  // MARK: - Internal views

  lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = false
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.decelerationRate = UIScrollViewDecelerationRateFast

    return scrollView
  }()

  lazy var overlayTapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
    let gesture = UITapGestureRecognizer()
    gesture.addTarget(self, action: #selector(overlayViewDidTap(_:)))

    return gesture
  }()

  lazy var effectView: UIVisualEffectView = {
    let effect = UIBlurEffect(style: .dark)
    let view = UIVisualEffectView(effect: effect)
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    return view
  }()

  lazy var backgroundView: UIImageView = {
    let view = UIImageView()
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    return view
  }()

  // MARK: - Public views

  open fileprivate(set) lazy var headerView: HeaderView = { [unowned self] in
    let view = HeaderView()
    view.delegate = self

    return view
  }()

  open fileprivate(set) lazy var footerView: FooterView = { [unowned self] in
    let view = FooterView()
    view.delegate = self

    return view
  }()

  open fileprivate(set) lazy var overlayView: UIView = { [unowned self] in
    let view = UIView(frame: CGRect.zero)
    let gradient = CAGradientLayer()
    let colors = [UIColor(hex: "090909").withAlphaComponent(0), UIColor(hex: "040404")]

    view.addGradientLayer(colors)
    view.alpha = 0

    return view
  }()

  // MARK: - Properties

  open fileprivate(set) var currentPage = 0 {
    didSet {
      currentPage = min(numberOfPages - 1, max(0, currentPage))
      footerView.updatePage(currentPage + 1, numberOfPages)
      footerView.updateText(pageViews[currentPage].image.text)

      if currentPage == numberOfPages - 1 {
        seen = true
      }

      reconfigurePagesForPreload()

      pageDelegate?.lightboxController(self, didMoveToPage: currentPage)

      if let image = pageViews[currentPage].imageView.image, dynamicBackground {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.125) {
          self.loadDynamicBackground(image)
        }
      }
    }
  }

  open var numberOfPages: Int {
    return pageViews.count
  }

  open var dynamicBackground: Bool = false {
    didSet {
      if dynamicBackground == true {
        effectView.frame = view.frame
        backgroundView.frame = effectView.frame
        view.insertSubview(effectView, at: 0)
        view.insertSubview(backgroundView, at: 0)
      } else {
        effectView.removeFromSuperview()
        backgroundView.removeFromSuperview()
      }
    }
  }

  open var spacing: CGFloat = 20 {
    didSet {
      configureLayout(view.bounds.size)
    }
  }

  open var images: [LightboxImage] {
    get {
      return pageViews.map { $0.image }
    }
    set(value) {
      initialImages = value
      configurePages(value)
    }
  }

  open weak var pageDelegate: LightboxControllerPageDelegate?
  open weak var dismissalDelegate: LightboxControllerDismissalDelegate?
  open weak var imageTouchDelegate: LightboxControllerTouchDelegate?
  open internal(set) var presented = false
  open fileprivate(set) var seen = false

  lazy var transitionManager: LightboxTransition = LightboxTransition()
  var pageViews = [PageView]()
  var statusBarHidden = false

  fileprivate var initialImages: [LightboxImage]
  fileprivate let initialPage: Int

  // MARK: - Initializers

  public init(images: [LightboxImage] = [], startIndex index: Int = 0) {
    self.initialImages = images
    self.initialPage = index
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  open override func viewDidLoad() {
    super.viewDidLoad()

    statusBarHidden = UIApplication.shared.isStatusBarHidden

    view.backgroundColor = UIColor.black
    transitionManager.lightboxController = self
    transitionManager.scrollView = scrollView
    transitioningDelegate = transitionManager

    [scrollView, overlayView, headerView, footerView].forEach { view.addSubview($0) }
    overlayView.addGestureRecognizer(overlayTapGestureRecognizer)

    configurePages(initialImages)

    goTo(initialPage, animated: false)
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !presented {
      presented = true
      configureLayout(view.bounds.size)
    }
  }

  open override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    scrollView.frame = view.bounds
    footerView.frame.size = CGSize(
      width: view.bounds.width,
      height: 100
    )

    footerView.frame.origin = CGPoint(
      x: 0,
      y: view.bounds.height - footerView.frame.height
    )

    headerView.frame = CGRect(
      x: 0,
      y: 16,
      width: view.bounds.width,
      height: 100
    )
  }

  open override var prefersStatusBarHidden: Bool {
    return LightboxConfig.hideStatusBar
  }

  // MARK: - Rotation

  override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { _ in
      self.configureLayout(size)
    }, completion: nil)
  }

  // MARK: - Configuration

  func configurePages(_ images: [LightboxImage]) {
    pageViews.forEach { $0.removeFromSuperview() }
    pageViews = []

    let preloadIndicies = calculatePreloadIndicies()

    for i in 0..<images.count {
      let pageView = PageView(image: preloadIndicies.contains(i) ? images[i] : LightboxImageStub())
      pageView.pageViewDelegate = self

      scrollView.addSubview(pageView)
      pageViews.append(pageView)
    }

    configureLayout(view.bounds.size)
  }

  func reconfigurePagesForPreload() {
    let preloadIndicies = calculatePreloadIndicies()

    for i in 0..<initialImages.count {
      let pageView = pageViews[i]
      if preloadIndicies.contains(i) {
        if type(of: pageView.image) == LightboxImageStub.self {
          pageView.update(with: initialImages[i])
        }
      } else {
        if type(of: pageView.image) != LightboxImageStub.self {
          pageView.update(with: LightboxImageStub())
        }
      }
    }
  }

  // MARK: - Pagination

  open func goTo(_ page: Int, animated: Bool = true) {
    guard page >= 0 && page < numberOfPages else {
      return
    }

    currentPage = page

    var offset = scrollView.contentOffset
    offset.x = CGFloat(page) * (scrollView.frame.width + spacing)

    let shouldAnimated = view.window != nil ? animated : false

    scrollView.setContentOffset(offset, animated: shouldAnimated)
  }

  open func next(_ animated: Bool = true) {
    goTo(currentPage + 1, animated: animated)
  }

  open func previous(_ animated: Bool = true) {
    goTo(currentPage - 1, animated: animated)
  }

  // MARK: - Actions

  @objc func overlayViewDidTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
    footerView.expand(false)
  }

  // MARK: - Layout

  open func configureLayout(_ size: CGSize) {
    scrollView.frame.size = size
    scrollView.contentSize = CGSize(
      width: size.width * CGFloat(numberOfPages) + spacing * CGFloat(numberOfPages - 1),
      height: size.height)
    scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * (size.width + spacing), y: 0)

    for (index, pageView) in pageViews.enumerated() {
      var frame = scrollView.bounds
      frame.origin.x = (frame.width + spacing) * CGFloat(index)
      pageView.frame = frame
      pageView.configureLayout()
      if index != numberOfPages - 1 {
        pageView.frame.size.width += spacing
      }
    }

    [headerView, footerView].forEach { ($0 as AnyObject).configureLayout() }

    overlayView.frame = scrollView.frame
    overlayView.resizeGradientLayer()
  }

  fileprivate func loadDynamicBackground(_ image: UIImage) {
    backgroundView.image = image
    backgroundView.layer.add(CATransition(), forKey: "fade")
  }

  func toggleControls(pageView: PageView?, visible: Bool, duration: TimeInterval = 0.1, delay: TimeInterval = 0) {
    let alpha: CGFloat = visible ? 1.0 : 0.0

    pageView?.playButton.isHidden = !visible

    UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
      self.headerView.alpha = alpha
      self.footerView.alpha = alpha
      pageView?.playButton.alpha = alpha
    }, completion: nil)
  }

  // MARK: - Helper functions
  func calculatePreloadIndicies () -> [Int] {
    var preloadIndicies: [Int] = []
    let preload = LightboxConfig.preload
    if preload > 0 {
      let lb = max(0, currentPage - preload)
      let rb = min(initialImages.count, currentPage + preload)
      for i in lb..<rb {
        preloadIndicies.append(i)
      }
    } else {
      preloadIndicies = [Int](0..<initialImages.count)
    }
    return preloadIndicies
  }
}

// MARK: - UIScrollViewDelegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
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

    targetContentOffset.pointee.x = x
    currentPage = Int(x / pageWidth)
  }
}

// MARK: - PageViewDelegate

extension LightboxController: PageViewDelegate {

  func remoteImageDidLoad(_ image: UIImage?, imageView: UIImageView) {
    guard let image = image, dynamicBackground else {
      return
    }

    let imageViewFrame = imageView.convert(imageView.frame, to: view)
    guard view.frame.intersects(imageViewFrame) else {
      return
    }

    loadDynamicBackground(image)
  }

  func pageViewDidZoom(_ pageView: PageView) {
    let duration = pageView.hasZoomed ? 0.1 : 0.5
    toggleControls(pageView: pageView, visible: !pageView.hasZoomed, duration: duration, delay: 0.5)
  }

  func pageView(_ pageView: PageView, didTouchPlayButton videoURL: URL) {
    LightboxConfig.handleVideo(self, videoURL)
  }

  func pageViewDidTouch(_ pageView: PageView) {
    guard !pageView.hasZoomed else { return }

    imageTouchDelegate?.lightboxController(self, didTouch: images[currentPage], at: currentPage)

    let visible = (headerView.alpha == 1.0)
    toggleControls(pageView: pageView, visible: !visible)
  }
}

// MARK: - HeaderViewDelegate

extension LightboxController: HeaderViewDelegate {

  func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton) {
    deleteButton.isEnabled = false

    guard numberOfPages != 1 else {
      pageViews.removeAll()
      self.headerView(headerView, didPressCloseButton: headerView.closeButton)
      return
    }

    let prevIndex = currentPage

    if currentPage == numberOfPages - 1 {
      previous()
    } else {
      next()
      currentPage -= 1
    }

    self.pageViews.remove(at: prevIndex).removeFromSuperview()

    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
      self.configureLayout(self.view.bounds.size)
      self.currentPage = Int(self.scrollView.contentOffset.x / self.view.bounds.width)
      deleteButton.isEnabled = true
    }
  }

  func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton) {
    closeButton.isEnabled = false
    presented = false
    dismissalDelegate?.lightboxControllerWillDismiss(self)
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - FooterViewDelegate

extension LightboxController: FooterViewDelegate {

  public func footerView(_ footerView: FooterView, didExpand expanded: Bool) {
    UIView.animate(withDuration: 0.25, animations: {
      self.overlayView.alpha = expanded ? 1.0 : 0.0
      self.headerView.deleteButton.alpha = expanded ? 0.0 : 1.0
    })
  }
}
