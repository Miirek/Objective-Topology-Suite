//
//  OTSPolygonBuilder.h
//

#import <Foundation/Foundation.h>

@class OTSGeometry;
@class OTSCoordinate;
@class OTSGeometryFactory;
@class OTSEdgeRing;
@class OTSNode;
@class OTSPlanarGraph;
@class OTSDirectedEdge;
@class OTSMaximalEdgeRing;
@class OTSMinimalEdgeRing;

@interface OTSPolygonBuilder : NSObject {
	OTSGeometryFactory *geometryFactory;
	NSMutableArray *shellList;
}

@property (nonatomic, retain) OTSGeometryFactory *geometryFactory;
@property (nonatomic, retain) NSMutableArray *shellList;

- (id)initWithGeometryFactory:(OTSGeometryFactory *)newGeometryFactory;
- (void)add:(OTSPlanarGraph *)graph;
- (void)addEdges:(NSArray *)dirEdges nodes:(NSArray *)nodes;
- (NSArray *)getPolygons;
- (BOOL)containsPoint:(OTSCoordinate *)p;

- (NSArray *)buildMaximalEdgeRings:(NSArray *)dirEdges;
- (NSArray *)buildMinimalEdgeRingsWithMaxEdgeRings:(NSArray *)maxEdgeRings 
										 shellList:(NSMutableArray *)newShellList 
									  freeHoleList:(NSMutableArray *)freeHoleList;
- (OTSEdgeRing *)findShell:(NSArray *)minEdgeRings;
- (void)placePolygonHoles:(OTSEdgeRing *)shell minEdgeRings:(NSArray *)minEdgeRings;
- (void)sortShellsAndHoles:(NSArray *)edgeRings 
				 shellList:(NSMutableArray *)newShellList 
			  freeHoleList:(NSMutableArray *)freeHoleList;
- (void)placeFreeHoles:(NSMutableArray *)newShellList 
		  freeHoleList:(NSMutableArray *)freeHoleList;
- (OTSEdgeRing *)findEdgeRingContaining:(OTSEdgeRing *)testEr shellList:(NSArray *)newShellList;
- (NSArray *)computePolygons:(NSArray *)newShellList;

@end
