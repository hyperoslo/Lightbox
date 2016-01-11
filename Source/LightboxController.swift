import UIKit

public class LightboxController: UIViewController {

  public lazy var scrollView: UIScrollView = { [unowned self] in
    let scrollView = UIScrollView()
    scrollView.frame = UIScreen.mainScreen().bounds
    scrollView.pagingEnabled = true
    scrollView.delegate = self
    scrollView.userInteractionEnabled = true
    scrollView.delaysContentTouches = false
    scrollView.showsHorizontalScrollIndicator = false

    return scrollView
  }()

  public lazy var closeButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle("Close", forState: .Normal)
    button.addTarget(self, action: "closeButtonDidPress", forControlEvents: .TouchUpInside)

    return button
  }()

  public lazy var pageControl: UIPageControl = { [unowned self] in
    let pageControl = UIPageControl()
    pageControl.addTarget(self, action: "handlePageControl", forControlEvents: .TouchUpInside)
    pageControl.userInteractionEnabled = true

    return pageControl
  }()

  // MARK: - Initializers

  public init(images: [UIImage]) {
    super.init(nibName: nil, bundle: nil)

    [scrollView, closeButton, pageControl].forEach { view.addSubview($0) }
    pageControl.numberOfPages = images.count

    setupFrames(images.count)
    setupControllers(images)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - View lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.blackColor()
  }

  // MARK: - Main methods

  public func setupFrames(imageCount: Int) {
    scrollView.contentSize.width = UIScreen.mainScreen().bounds.width * CGFloat(imageCount)
    pageControl.frame.origin = CGPoint(
      x: (UIScreen.mainScreen().bounds.width - pageControl.frame.width) / 2,
      y: UIScreen.mainScreen().bounds.height - pageControl.frame.height - 10)

  }

  public func setupControllers(images: [UIImage]) {

    for (index, image) in images.enumerate() {
      let controller = LightboxImageController(image: image)
      controller.view.frame.origin.x = UIScreen.mainScreen().bounds.width * CGFloat(index)

      scrollView.addSubview(controller.view)
    }
  }

  // MARK: - Action methods

  public func handlePageControl() {
    UIView.animateWithDuration(0.35, animations: {
      self.scrollView.contentOffset.x = UIScreen.mainScreen().bounds.width * CGFloat(self.pageControl.currentPage)
    })
  }

  public func closeButtonDidPress() {
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: - ScrollView delegate

extension LightboxController: UIScrollViewDelegate {

  public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let page = scrollView.contentOffset.x / UIScreen.mainScreen().bounds.width

    pageControl.currentPage = Int(page)
  }
}
