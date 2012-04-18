//
//  OTSEdgeEndBundleStar.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeEndStar.h" // for EdgeEndBundleStar inheritance

@class OTSIntersectionMatrix;
@class OTSEdgeEnd;

@interface OTSEdgeEndBundleStar : OTSEdgeEndStar {

}

- (void)insert:(OTSEdgeEnd *)e;
- (void)updateIM:(OTSIntersectionMatrix *)im;

@end
