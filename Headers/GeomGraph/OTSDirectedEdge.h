//
//  OTSDirectedEdge.h
//

#import <Foundation/Foundation.h>

#import "OTSEdgeEnd.h" // for inheritance

@class OTSEdge;
@class OTSEdgeRing;

@interface OTSDirectedEdge : OTSEdgeEnd {
	BOOL forward;
	BOOL inResult;
	BOOL visited;
	OTSDirectedEdge *sym;
	OTSDirectedEdge *next; 
	OTSDirectedEdge *nextMin; 	
	/// the EdgeRing that this edge is part of
	OTSEdgeRing *edgeRing; 
	/// the MinimalEdgeRing that this edge is part of
	OTSEdgeRing *minEdgeRing; 
	int depth[3];
}

@property (nonatomic, assign) BOOL forward;
@property (nonatomic, assign) BOOL inResult;
@property (nonatomic, assign) BOOL visited;
@property (nonatomic, retain) OTSDirectedEdge *sym; 
@property (nonatomic, retain) OTSDirectedEdge *next; 
@property (nonatomic, retain) OTSDirectedEdge *nextMin; 
@property (nonatomic, retain) OTSEdgeRing *edgeRing;
@property (nonatomic, retain) OTSEdgeRing *minEdgeRing;

+ (int)depthFactor:(int)currLocation nextLocation:(int)nextLocation;
- (id)initWithEdge:(OTSEdge *)newEdge isForward:(BOOL)newIsForward;
- (int)getDepthAt:(int)position;
- (void)setDepth:(int)newDepth at:(int)position;
- (int)getDepthDelta;
- (void)setVisitedEdge:(BOOL)newIsVisited;
- (BOOL)isLineEdge;
- (BOOL)isInteriorAreaEdge;
- (void)setEdgeDepths:(int)newDepth at:(int)position;
- (void)computeDirectedLabel;

@end
