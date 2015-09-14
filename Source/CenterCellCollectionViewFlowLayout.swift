import UIKit

class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
  
  override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
    
    if let collectionView = self.collectionView {
      let collectionViewBounds = collectionView.bounds
      let halfWidth = collectionViewBounds.size.width / 2
      let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth
      
      if let attributesForVisibleCells = layoutAttributesForElementsInRect(collectionViewBounds) {
        var candidateAttributes : UICollectionViewLayoutAttributes?
        
        for attributes in attributesForVisibleCells.filter({
          $0.representedElementCategory == UICollectionElementCategory.Cell}) {
          
          if let candAttrs = candidateAttributes {
            let a = attributes.center.x - proposedContentOffsetCenterX
            let b = candAttrs.center.x - proposedContentOffsetCenterX
            
            if velocity.x < 0 {
              continue
            } else if velocity.x > 0 {
              candidateAttributes = attributes
            } else if fabsf(Float(a)) < fabsf(Float(b)) {
              candidateAttributes = attributes
            }
            
          } else { // First time in the loop
            candidateAttributes = attributes
            continue
          }
        }
        return CGPoint(
          x: candidateAttributes!.center.x - halfWidth,
          y: proposedContentOffset.y)
      }
    }

    return super.targetContentOffsetForProposedContentOffset(proposedContentOffset)
  }
}
