//
//  OTSPlanarGraph.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"
#import "OTSPlanarGraph.h"
#import "OTSNodeMap.h" // for typedefs

@class OTSCoordinate;
@class OTSEdge;
@class OTSNode;
@class OTSEdgeEnd;
@class OTSNodeFactory;

@interface OTSPlanarGraph : NSObject {
	NSMutableArray *edges;
	OTSNodeMap *nodes;
	NSMutableArray *edgeEndList;
}

@property (nonatomic, retain) NSMutableArray *edges;
@property (nonatomic, retain) OTSNodeMap *nodes;
@property (nonatomic, retain) NSMutableArray *edgeEndList;

+ (void)linkResultDirectedEdges:(NSArray *)v start:(int)start end:(int)end;
- (id)initWithNodeFactory:(OTSNodeFactory *)nodeFact;
- (NSArray *)getEdgeEnds;
- (BOOL)isBoundaryNode:(int)geomIndex coord:(OTSCoordinate *)coord;
- (void)add:(OTSEdgeEnd *)e;
- (void)getNodesAsArray:(NSMutableArray *)_nodes;
- (OTSNode *)addNode:(OTSNode *)node;
- (OTSNode *)addNodeWithCoordinate:(OTSCoordinate *)coord;
- (OTSNode *)find:(OTSCoordinate *)coord;
- (void)addEdgesWithArray:(NSArray *)edgesToAdd;
- (void)linkResultDirectedEdges;
- (void)linkAllDirectedEdges;
- (OTSEdgeEnd *)findEdgeEnd:(OTSEdge *)e;
- (OTSEdge *)findEdge:(OTSCoordinate *)p0 p1:(OTSCoordinate *)p1;
- (OTSEdge *)findEdgeInSameDirection:(OTSCoordinate *)p0 p1:(OTSCoordinate *)p1;
- (OTSNodeMap *)getNodeMap;
- (void)insertEdge:(OTSEdge *)e;
- (BOOL)matchInSameDirection:(OTSCoordinate *)p0 
						  p1:(OTSCoordinate *)p1 
						 ep0:(OTSCoordinate *)ep0 
						 ep1:(OTSCoordinate *)ep1;

@end
