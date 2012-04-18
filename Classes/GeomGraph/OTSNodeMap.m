//
//  OTSNodeMap.m
//

#import "OTSNodeMap.h"
#import "OTSNode.h"
#import "OTSNodeFactory.h"
#import "OTSEdgeEnd.h"
#import "OTSLabel.h"
#import "OTSLocation.h"
#import "OTSCoordinate.h"

@implementation OTSNodeMap

@synthesize nodeMap;
@synthesize nodeFact;

- (id)initWithNodeFactory:(OTSNodeFactory *)newNodeFact {
	if (self = [super init]) {
		self.nodeFact = newNodeFact;
		self.nodeMap = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)dealloc {
	[nodeMap release];
	[nodeFact release];
	[super dealloc];
}

- (OTSNode *)addNodeWithCoordinate:(OTSCoordinate *)coord {
	
	OTSNode *node = [nodeMap objectForKey:coord];
	if (node == nil) {
		node = [nodeFact nodeWithCoordinate:coord];
		[nodeMap setObject:node forKey:coord];
	} else {
		[node addZ:coord.z];
	}
	return node;
	
}

- (OTSNode *)addNode:(OTSNode *)n {
	
	OTSNode *node = [nodeMap objectForKey:[n getCoordinate]];	
	if (node == nil) {
		[nodeMap setObject:node forKey:[n getCoordinate]];
		return n;
	}
	[node mergeLabelWithNode:n];
	return node;
		
}

- (void)add:(OTSEdgeEnd *)e {	
	OTSNode *n = [self addNodeWithCoordinate:[e getCoordinate]];
	[n add:e];
}

- (OTSNode *)find:(OTSCoordinate *)coord {
	return [nodeMap objectForKey:coord];
}

- (void)getBoundaryNodes:(int)geomIndex bdyNodes:(NSMutableArray *)bdyNodes {
	
	NSArray *keyz = [nodeMap allKeys];
	NSArray *sortedKeyz = [keyz sortedArrayUsingSelector:@selector(compareForNSComparisonResult:)];
	for (OTSCoordinate *coord in sortedKeyz) {
		OTSNode *node = [nodeMap objectForKey:coord];
		if ([node.label locationAtGeometryIndex:geomIndex] == kOTSLocationBoundary)
			[bdyNodes addObject:node];
	}
	
}

- (void)getNodesAsArray:(NSMutableArray *)_nodes {
	NSArray *keyz = [nodeMap allKeys];
	NSArray *sortedKeyz = [keyz sortedArrayUsingSelector:@selector(compareForNSComparisonResult:)];
	for (OTSCoordinate *coord in sortedKeyz) {
		OTSNode *node = [nodeMap objectForKey:coord];
		[_nodes addObject:node];
	}	
}

@end
