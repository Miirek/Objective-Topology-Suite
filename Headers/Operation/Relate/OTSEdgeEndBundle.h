//
//  OTSEdgeEndBundle.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeEnd.h" // for EdgeEndBundle inheritance

@class OTSBoundaryNodeRule;
@class OTSIntersectionMatrix;

@interface OTSEdgeEndBundle : OTSEdgeEnd {
	NSMutableArray *edgeEnds;
}

@property (nonatomic, retain) NSMutableArray *edgeEnds;

- (id)initWithEdgeEnd:(OTSEdgeEnd *)e;
- (void)insert:(OTSEdgeEnd *)e;
- (void)computeLabel:(OTSBoundaryNodeRule *)bnr;
- (void)updateIM:(OTSIntersectionMatrix *)im;
- (void)computeLabelOn:(int)geomIndex boundaryNodeRule:(OTSBoundaryNodeRule *)boundaryNodeRule;
- (void)computeLabelSidesAt:(int)geomIndex;
- (void)computeLabelSide:(int)side at:(int)geomIndex;

@end
