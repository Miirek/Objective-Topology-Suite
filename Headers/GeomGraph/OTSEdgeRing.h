//
//  OTSEdgeRing.h
//

#import <Foundation/Foundation.h>

#import "OTSLabel.h" // for composition

@class OTSGeometryFactory;
@class OTSLinearRing;
@class OTSPolygon;
@class OTSCoordinate;
@class OTSCoordinateSequence;
@class OTSDirectedEdge;
//@class OTSLabel;
@class OTSEdge;

@interface OTSEdgeRing : NSObject {
	OTSDirectedEdge *startDe; // the directed edge which starts the list of edges for this EdgeRing
	OTSGeometryFactory *geometryFactory;
	/// a list of EdgeRings which are holes in this EdgeRing
	NSMutableArray *holes;
	int maxNodeDegree;
	/// the DirectedEdges making up this EdgeRing
	NSMutableArray *edges;
	OTSCoordinateSequence *pts;
	// label stores the locations of each geometry on the
	// face surrounded by this ring
	OTSLabel *label;
	OTSLinearRing *ring;  // the ring created for this EdgeRing
	BOOL isHoleVar;	
	/// if non-null, the ring is a hole and this EdgeRing is its containing shell
	OTSEdgeRing *shell;
}

@property (nonatomic, retain) OTSDirectedEdge *startDe;
@property (nonatomic, retain) OTSGeometryFactory *geometryFactory;
@property (nonatomic, retain) NSMutableArray *holes;
@property (nonatomic, retain) NSMutableArray *edges;
@property (nonatomic, retain) OTSCoordinateSequence *pts;
@property (nonatomic, retain) OTSLabel *label;
@property (nonatomic, retain) OTSLinearRing *ring;
@property (nonatomic, retain) OTSEdgeRing *shell;
@property (nonatomic, assign) BOOL isHoleVar;	
@property (nonatomic, assign) int maxNodeDegree;

- (id)initWithEdgeEnd:(OTSDirectedEdge *)newStart geometryFactory:(OTSGeometryFactory *)newGeometryFactory;
- (BOOL)isIsolated;
- (BOOL)isHole;
- (OTSLinearRing *)getLinearRing;
- (BOOL)isShell;
- (void)addHole:(OTSEdgeRing *)edgeRing;
- (OTSPolygon *)toPolygon:(OTSGeometryFactory *)geometryFactory;
- (void)computeRing;
- (OTSDirectedEdge *)getNext:(OTSDirectedEdge *)de;
- (void)setEdgeRing:(OTSDirectedEdge *)de edgeRing:(OTSEdgeRing *)er;
- (int)getMaxNodeDegree;
- (void)setInResult;
- (BOOL)containsPoint:(OTSCoordinate *)p;
- (void)computePoints:(OTSDirectedEdge *)newStart;
- (void)mergeLabel:(OTSLabel *)deLabel;
- (void)mergeLabel:(OTSLabel *)deLabel geomIndex:(int)geomIndex;
- (void)addPoints:(OTSEdge *)edge isForward:(BOOL)isForward isFirstEdge:(BOOL)isFirstEdge;
- (void)computeMaxNodeDegree;

@end
