import Foundation

public protocol URLStringConvertible {
  var url: NSURL { get }
  var string: String { get }
}

extension String: URLStringConvertible {
  
  public var url: NSURL {
    let url = NSURL(string: self)!
    return url
  }
  
  public var string: String {
    return self
  }
}
