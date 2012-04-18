//
//  OTSEdgeEnd.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"  // for p0,p1

@class OTSBoundaryNodeRule;
@class OTSLabel;
@class OTSEdge;
@class OTSNode;

@interface OTSEdgeEnd : NSObject {
	OTSEdge *edge;// the parent edge of this edge end
	OTSLabel *label;
	/// the node this edge end originates at
	OTSNode *node;         
	/// points of initial line segment. FIXME: do we need a copy here ?
	OTSCoordinate *p0;
	OTSCoordinate *p1; 	
	/// the direction vector for this edge from its starting point
	double dx;
	double dy;	
	int quadrant;
}

@property (nonatomic, retain) OTSEdge *edge;
@property (nonatomic, retain) OTSLabel *label;
@property (nonatomic, retain) OTSNode *node;         
@property (nonatomic, retain) OTSCoordinate *p0;
@property (nonatomic, retain) OTSCoordinate *p1; 	
@property (nonatomic, assign) double dx;
@property (nonatomic, assign) double dy;	
@property (nonatomic, assign) int quadrant;

- (id)initWithEdge:(OTSEdge *)newEdge p0:(OTSCoordinate *)newP0 p1:(OTSCoordinate *)newP1 label:(OTSLabel *)newLabel;
- (id)initWithEdge:(OTSEdge *)newEdge;
- (OTSCoordinate *)getCoordinate;
- (OTSCoordinate *)getDirectedCoordinate;
- (int)compareTo:(OTSEdgeEnd *)e;
- (int)compareDirection:(OTSEdgeEnd *)e;
- (void)computeLabel:(OTSBoundaryNodeRule *)bnr;
- (void)setP0:(OTSCoordinate *)newP0 p1:(OTSCoordinate *)newP1;
+ (BOOL)edgeEnd:(OTSEdgeEnd *)s1 lessThan:(OTSEdgeEnd *)s2;

@end
