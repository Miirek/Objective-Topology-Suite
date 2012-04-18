//
//  OTSAbstractSTRtree.m
//

#import "OTSAbstractSTRtree.h"
#import "OTSAbstractNode.h"
#import "OTSItemBoundable.h"

@implementation OTSAbstractSTRtree

@synthesize built;
@synthesize nodeCapacity;

- (id)initWithCapacity:(int)newNodeCapacity {
	if (self = [super init]) {
		NSAssert(newNodeCapacity > 1, @"Node capacity needs to be > 1");
		built = NO;
		nodeCapacity = newNodeCapacity;
		itemBoundables = [[NSMutableArray alloc] init];
		nodes = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc {
	[itemBoundables release];
	[root release];
	[nodes release];
	[super dealloc];
}

- (OTSAbstractNode *)createHigherLevelsFromBoundables:(NSArray *)boundables ofALevel:(int)level {
	NSAssert([boundables count] != 0, @"Boundables cannot be empty");
	NSArray *parentBoundables = [self createParentBoundables:boundables level:level + 1];
	if ([parentBoundables count] == 1) {
		// Cast from Boundable to AbstractNode
		OTSAbstractNode *ret = (OTSAbstractNode *)[parentBoundables objectAtIndex:0];
		return ret;
	}
	OTSAbstractNode *ret = [self createHigherLevelsFromBoundables:parentBoundables ofALevel:level + 1];
	return ret;
}

- (NSArray *)sortBoundables:(NSArray *)input {
	// abstract
	return nil;
}

- (BOOL)removeInSearchBounds:(id)searchBounds node:(OTSAbstractNode *)node item:(id)item {
	// first try removing item from this node	
	if ([self removeItem:node item:item]) return YES;
	
	NSMutableArray *boundables = node.childBoundables;
	for (int i = 0, n = [boundables count]; i < n; ++i) {
		id <NSObject, OTSBoundable> childBoundable = [boundables objectAtIndex:i];
		if (![[self getIntersectsOp] intersects:[childBoundable getBounds] andBound:searchBounds]) {
			continue;
		}
		if ([childBoundable isKindOfClass:[OTSAbstractNode class]]) {
			OTSAbstractNode *an = (OTSAbstractNode *)childBoundable;
			// if found, record child for pruning and exit
			if ([self removeInSearchBounds:searchBounds node:an item:item]) {
				if ([an.childBoundables count] == 0) {
					[boundables removeObjectAtIndex:i];
				}
				return YES;
			}
		}
	}
	return NO;
}

- (BOOL)removeItem:(OTSAbstractNode *)node item:(id)item {
	NSMutableArray *boundables = node.childBoundables;
	for (int i = 0, n = [boundables count]; i < n; ++i) {
		id <NSObject, OTSBoundable> childBoundable = [boundables objectAtIndex:i];
		if ([childBoundable isKindOfClass:[OTSItemBoundable class]]) {
			OTSItemBoundable *ib = (OTSItemBoundable *)childBoundable;
			if ([ib getItem] == item) {
				[boundables removeObjectAtIndex:i];
				return YES;
			}
		}
	}
	return NO;	
}

- (NSArray *)itemsTreeFrom:(OTSAbstractNode *)node {
	
	NSMutableArray *valuesTreeForNode = [NSMutableArray array];
	
	NSArray *boundables = node.childBoundables;
	for (id <NSObject, OTSBoundable> childBoundable in boundables) {
		if ([childBoundable isKindOfClass:[OTSAbstractNode class]]) {
			NSArray *valuesTreeForChild = [self itemsTreeFrom:(OTSAbstractNode *)childBoundable];
			// only add if not null (which indicates an item somewhere in this tree
            if (valuesTreeForChild != nil)
				[valuesTreeForNode addObjectsFromArray:valuesTreeForChild];
		} else if ([childBoundable isKindOfClass:[OTSItemBoundable class]]) {
			[valuesTreeForNode addObject:childBoundable];
		} else {
			NSAssert(NO, @"unsupported childBoundable type");
		}
	}
	
	if ([valuesTreeForNode count] == 0) 
        return nil;
	
    return valuesTreeForNode;
	
}

- (OTSAbstractNode *)createNode:(int)level {
	// abstract
	return nil;
}

- (NSArray *)createParentBoundables:(NSArray *)childBoundables level:(int)newLevel {
	NSAssert([childBoundables count] > 0, @"Child boundables is empty");
	NSMutableArray *parentBoundables = [NSMutableArray array];
	[parentBoundables addObject:[self createNode:newLevel]];
	
	NSArray *sortedChildBoundables = [self sortBoundables:childBoundables];
	for (id <NSObject, OTSBoundable> childBoundable in sortedChildBoundables) {
		OTSAbstractNode *last = [self lastNode:parentBoundables];
		if ([last.childBoundables count] == nodeCapacity) {
			last = [self createNode:newLevel];
			[parentBoundables addObject:last];
		}
		[last.childBoundables addObject:childBoundable];
	}
	return parentBoundables;
}

- (OTSAbstractNode *)lastNode:(NSArray *)_nodes {
	NSAssert([_nodes count] != 0, @"Empty nodes");
	// Cast from Boundable to AbstractNode
	return (OTSAbstractNode *)[_nodes lastObject];
}

- (OTSAbstractNode *)getRoot {
	NSAssert(built, @"Tree not built");
	return root;
}

- (void)insert:(id)bounds item:(id)item {
	// Cannot insert items into an STR packed R-tree after it has been built
	NSAssert(!built, @"Tree already built");
	OTSItemBoundable *ib = [[OTSItemBoundable alloc] initWithBounds:bounds item:item];
	[itemBoundables addObject:ib];
	[ib release];
}

- (void)query:(id)searchBounds outputInto:(NSMutableArray *)foundItems {
	if (!built) [self build];	
	if ([itemBoundables count] == 0) NSAssert([root getBounds] == nil, @"Root bound not nil");	
	if ([[self getIntersectsOp] intersects:[root getBounds] andBound:searchBounds]) {
		[self query:searchBounds node:root outputInto:foundItems];
	}
}

- (void)query:(id)searchBounds usingVisitor:(id <OTSItemVisitor>)visitor {
	if (!built) [self build];
	if ([itemBoundables count] == 0) NSAssert([root getBounds] == nil, @"Root bound not nil");	
	if ([[self getIntersectsOp] intersects:[root getBounds] andBound:searchBounds]) {
		[self query:searchBounds node:root usingVisitor:visitor];
	}
}

- (void)query:(id)searchBounds node:(OTSAbstractNode *)node usingVisitor:(id <OTSItemVisitor>)visitor {
	NSArray *boundables = node.childBoundables;
	for (id <NSObject, OTSBoundable> childBoundable in boundables) {
		if (![[self getIntersectsOp] intersects:[childBoundable getBounds] andBound:searchBounds]) {
			continue;
		}
		if ([childBoundable isKindOfClass:[OTSAbstractNode class]]) {
			[self query:searchBounds node:(OTSAbstractNode *)childBoundable usingVisitor:visitor];
		} else if ([childBoundable isKindOfClass:[OTSItemBoundable class]]) {
			OTSItemBoundable *ib = (OTSItemBoundable *)childBoundable;
			[visitor visitItem:[ib getItem]];
		} else {
			NSAssert(NO, @"unsupported childBoundable type");
		}
	}
}

- (BOOL)remove:(id)searchBounds item:(id)item {
	if (!built) [self build];
	if ([itemBoundables count] == 0) NSAssert([root getBounds] == nil, @"Root bound not nil");	
	if ([[self getIntersectsOp] intersects:[root getBounds] andBound:searchBounds]) {
		return [self removeInSearchBounds:searchBounds node:root item:item];
	}
	return NO;
}

- (NSArray *)boundablesAtLevel:(int)level {
	NSMutableArray *boundables = [NSMutableArray array];
	[self boundablesAtLevel:level top:root boundables:boundables];
	return boundables;
}

- (id <NSObject, OTSIntersectsOp>)getIntersectsOp {
	// abstract
	return nil;
}

+ (BOOL)compareDouble:(double)a andDouble:(double)b {
	return ( a < b ) ? YES : NO;
}

- (void)build {
	NSAssert(!built, @"Tree already built");
	root = ([itemBoundables count] == 0 ? [self createNode:0] : [self createHigherLevelsFromBoundables:itemBoundables ofALevel:-1]);
	[root retain];
	built = YES;
}

- (void)query:(id)searchBounds node:(OTSAbstractNode *)node outputInto:(NSMutableArray *)matches {
	NSAssert(node != nil, @"Node is nil");
	NSArray *boundables = node.childBoundables;
	id <NSObject, OTSIntersectsOp> io = [self getIntersectsOp];	
	for (id <NSObject, OTSBoundable> childBoundable in boundables) {
		if (![io intersects:[childBoundable getBounds] andBound:searchBounds]) {
			continue;
		}
		if ([childBoundable isKindOfClass:[OTSAbstractNode class]]) {
			[self query:searchBounds node:(OTSAbstractNode *)childBoundable outputInto:matches];
		} else if ([childBoundable isKindOfClass:[OTSItemBoundable class]]) {
			OTSItemBoundable *ib = (OTSItemBoundable *)childBoundable;
			[matches addObject:[ib getItem]];
		} else {
			NSAssert(NO, @"unsupported childBoundable type");
		}
	}
}

- (void)iterate:(id <OTSItemVisitor>)visitor {
	for (id <NSObject, OTSBoundable> boundable in itemBoundables) {
		if ([boundable isKindOfClass:[OTSItemBoundable class]]) {
			OTSItemBoundable *ib = (OTSItemBoundable *)boundable;
			[visitor visitItem:[ib getItem]];
		}
	}
}

- (void)boundablesAtLevel:(int)level top:(OTSAbstractNode *)top boundables:(NSMutableArray *)boundables {
	
	NSAssert(level > -2, @"Invalid level");
	
	if (top.level == level) {		
		[boundables addObject:top];
		return;
	}
	
	NSMutableArray *childBoundables = top.childBoundables;
	for (id <NSObject, OTSBoundable> boundable in childBoundables) {
		if ([boundable isKindOfClass:[OTSAbstractNode class]]) {
			[self boundablesAtLevel:level top:(OTSAbstractNode *)boundable boundables:boundables];
		} else {
			NSAssert([boundable isKindOfClass:[OTSItemBoundable class]], @"Expecting OTSItemBoundable class");
			if (level == -1) {
				[boundables addObject:boundable];
			}
		}
	}
	
}

- (NSArray *)itemsTree {
	if (!built) { 
        [self build]; 
    }
	
	NSArray *valuesTree = [self itemsTreeFrom:root];
    if (valuesTree == nil)
        return [NSArray array];
    return valuesTree;
}

@end
