//
//  OTSDirectedEdgeStar.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeEndStar.h"  // for inheritance
#import "OTSLabel.h"  // for private member
#import "OTSCoordinate.h"  // for p0,p1

@class OTSDirectedEdge;
@class OTSEdgeRing;

/// States for linResultDirectedEdges
enum {
	kOTSEdgeScanningForIncoming=1,
	kOTSEdgeLinkingToOutgoing
};

@interface OTSDirectedEdgeStar : OTSEdgeEndStar {
	/**
	 * A list of all outgoing edges in the result, in CCW order
	 */
	NSMutableArray *resultAreaEdgeList;	
	OTSLabel *label;
}

@property (nonatomic, retain) NSMutableArray *resultAreaEdgeList;	
@property (nonatomic, retain) OTSLabel *label;

- (void)insert:(OTSEdgeEnd *)ee;
- (int)getOutgoingDegree;
- (int)getOutgoingDegreeOf:(OTSEdgeRing *)er;
- (OTSDirectedEdge *)getRightmostEdge;
- (void)computeLabelling:(NSArray *)geom;
- (void)mergeSymLabels;
- (void)updateLabelling:(OTSLabel *)nodeLabel;
- (void)linkResultDirectedEdges;
- (void)linkMinimalDirectedEdges:(OTSEdgeRing *)er;
- (void)linkAllDirectedEdges;
- (void)findCoveredLineEdges;
- (void)computeDepths:(OTSDirectedEdge *)de;
- (NSArray *)getResultAreaEdges;
- (int)computeDepths:(int)startIdx endIdx:(int)endIdx startDepth:(int)startDepth;

@end
