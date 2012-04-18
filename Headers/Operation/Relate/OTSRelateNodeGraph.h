//
//  OTSRelateNodeGraph.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinate;
@class OTSNode;
@class OTSGeometryGraph;
@class OTSEdgeEnd;
@class OTSNodeMap;

@interface OTSRelateNodeGraph : NSObject {
	OTSNodeMap *nodes;
}

@property (nonatomic, retain) OTSNodeMap *nodes;

- (NSDictionary *)getNodeMap;
- (void)build:(OTSGeometryGraph *)geomGraph;
- (void)computeIntersectionNodes:(OTSGeometryGraph *)geomGraph argIndex:(int)argIndex;
- (void)copyNodesAndLabels:(OTSGeometryGraph *)geomGraph argIndex:(int)argIndex;
- (void)insertEdgeEnds:(NSArray *)ee;

@end
