//
//  OTSNodeMap.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h" // for CoordinateLessThen
#import "OTSNode.h" // for testInvariant

@class OTSNode;
@class OTSEdgeEnd;
@class OTSNodeFactory;

@interface OTSNodeMap : NSObject {
	NSMutableDictionary *nodeMap;
	OTSNodeFactory *nodeFact;
}

@property (nonatomic, retain) NSMutableDictionary *nodeMap;
@property (nonatomic, retain) OTSNodeFactory *nodeFact;

- (id)initWithNodeFactory:(OTSNodeFactory *)newNodeFact;
- (OTSNode *)addNodeWithCoordinate:(OTSCoordinate *)coord;
- (OTSNode *)addNode:(OTSNode *)n;
- (void)add:(OTSEdgeEnd *)e;
- (OTSNode *)find:(OTSCoordinate *)coord;
- (void)getBoundaryNodes:(int)geomIndex bdyNodes:(NSMutableArray *)bdyNodes;
- (void)getNodesAsArray:(NSMutableArray *)_nodes;

@end
