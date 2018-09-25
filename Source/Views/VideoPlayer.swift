import UIKit

public protocol VideoPlayer {
  func playVideo(with url: URL)
  func resume()
  func pause()
}

public typealias VideoPlayerController = VideoPlayer & UIViewController
