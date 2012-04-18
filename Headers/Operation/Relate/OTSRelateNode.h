//
//  OTSRelateNode.h
//

#import <Foundation/Foundation.h>

#import "OTSNode.h" // for inheritance

@class OTSIntersectionMatrix;
@class OTSCoordinate;
@class OTSEdgeEndStar;

@interface OTSRelateNode : OTSNode {

}

- (id)initWithCoordinate:(OTSCoordinate *)newCoord edges:(OTSEdgeEndStar *)newEdges;
- (void)updateIMFromEdges:(OTSIntersectionMatrix *)im;
- (void)computeIM:(OTSIntersectionMatrix *)im;

@end
