//
//  OTSEdge.h
//

#import <Foundation/Foundation.h>

#import "OTSGraphComponent.h" // for inheritance
#import "OTSDepth.h" // for member
#import "OTSEdgeIntersectionList.h" // for composition
#import "OTSCoordinateSequence.h" // for inlines

@class OTSEnvelope;
@class OTSIntersectionMatrix;
@class OTSCoordinate;
@class OTSLineIntersector;
@class OTSNode;
@class OTSEdgeEndStar;
@class OTSLabel;
@class OTSNodeFactory;
@class OTSMonotoneChainEdge;

@interface OTSEdge : OTSGraphComponent {
	NSString *name;
	/// Lazily-created, owned by Edge.
	OTSMonotoneChainEdge *mce;
	/// Lazily-created, owned by Edge.
	OTSEnvelope *env;
	OTSDepth *depth;
	int depthDelta;   // the change in area depth from the R to L side of this edge	
	/// Externally-set, owned by Edge. FIXME: refuse ownership
	OTSCoordinateSequence *pts;
	OTSEdgeIntersectionList *eiList;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) OTSMonotoneChainEdge *mce;
@property (nonatomic, retain) OTSEnvelope *env;
@property (nonatomic, retain) OTSDepth *depth;
@property (nonatomic, assign) int depthDelta;
@property (nonatomic, retain) OTSCoordinateSequence *pts;
@property (nonatomic, retain) OTSEdgeIntersectionList *eiList;

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)newPts;
- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)newPts label:(OTSLabel *)_label;
+ (void)updateIM:(OTSLabel *)lbl im:(OTSIntersectionMatrix *)im;
- (void)updateIMSuper:(OTSIntersectionMatrix *)im;
- (int)getNumPoints;
- (OTSCoordinateSequence *)getCoordinates;
- (OTSCoordinate *)getCoordinate:(int)i;
- (OTSCoordinate *)getCoordinate;
- (int)getMaximumSegmentIndex;
- (OTSEdgeIntersectionList *)getEdgeIntersectionList;
- (OTSMonotoneChainEdge *)getMonotoneChainEdge;
- (BOOL)isClosed;
- (BOOL)isCollapsed;
- (OTSEdge *)getCollapsedEdge;
- (void)addIntersections:(OTSLineIntersector *)li segmentIndex:(int)segmentIndex geomIndex:(int)geomIndex;
- (void)addIntersections:(OTSLineIntersector *)li segmentIndex:(int)segmentIndex geomIndex:(int)geomIndex intIndex:(int)intIndex;
- (void)computeIM:(OTSIntersectionMatrix *)im;
- (BOOL)isPointwiseEqual:(OTSEdge *)e;
- (BOOL)equalsTo:(OTSEdge*)e;
- (OTSEnvelope*)getEnvelope;

@end
