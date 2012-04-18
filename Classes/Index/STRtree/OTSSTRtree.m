//
//  OTSSTRtree.m
//

#import "OTSSTRtree.h"
#import "OTSItemBoundable.h"

@interface OTSItemBoundable(OTSBoundSortable)

- (NSComparisonResult)compareForNSComparisonResult:(id <OTSBoundable>)other;

@end

@implementation OTSItemBoundable(OTSBoundSortable)

- (NSComparisonResult)compareForNSComparisonResult:(id <OTSBoundable>)other {
	
	OTSEnvelope *aEnv = (OTSEnvelope *)[self getBounds];
	OTSEnvelope *bEnv = (OTSEnvelope *)[other getBounds];
	
	double a = [OTSSTRtree centreY:aEnv];
	double b = [OTSSTRtree centreY:bEnv];
	
	if (a > b) {
		return NSOrderedDescending;
	}	
	if (a < b) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

@end

@interface OTSSTRAbstractNode : OTSAbstractNode {
}

- (id)initWithLevel:(int)newLevel capacity:(int)capacity;
- (NSComparisonResult)compareForNSComparisonResult:(id <OTSBoundable>)other;

@end

@implementation OTSSTRAbstractNode

- (id)initWithLevel:(int)newLevel capacity:(int)capacity {
	if (self = [super initWithLevel:newLevel capacity:capacity]) {
	}
	return self;
}

- (id)computeBounds {
	OTSEnvelope *_bounds = nil;
	if ([childBoundables count] == 0)
		return nil;
	
	for (id <OTSBoundable> childBoundable in childBoundables) {
		if (_bounds == nil) {
			_bounds = [[OTSEnvelope alloc] initWithEnvelope:(OTSEnvelope *)[childBoundable getBounds]];
		} else {
			[_bounds expandToInclude:(OTSEnvelope *)[childBoundable getBounds]];
		}
	}
	bounds = _bounds;
	return bounds;
}

- (NSComparisonResult)compareForNSComparisonResult:(id <OTSBoundable>)other {
	
	OTSEnvelope *aEnv = (OTSEnvelope *)[self getBounds];
	OTSEnvelope *bEnv = (OTSEnvelope *)[other getBounds];
	
	double a = [OTSSTRtree centreY:aEnv];
	double b = [OTSSTRtree centreY:bEnv];
	
	if (a > b) {
		return NSOrderedDescending;
	}	
	if (a < b) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

@end


@implementation OTSSTRIntersectsOp

- (BOOL)intersects:(id)aBounds andBound:(id)bBounds {
	return [(OTSEnvelope *)aBounds intersects:(OTSEnvelope *)bBounds];
}

@end

@implementation OTSSTRtree

- (id)init {
	if (self = [self initWithCapacity:10]) {
	}
	return self;
}

- (id)initWithCapacity:(int)newNodeCapacity {
	if (self = [super initWithCapacity:newNodeCapacity]) {
		intersectsOp = [[OTSSTRIntersectsOp alloc] init];
	}
	return self;
}

- (void)dealloc {
	[intersectsOp release];
	[super dealloc];
}

- (NSArray *)createParentBoundablesFromVerticalSlices:(NSArray *)verticalSlices level:(int)newLevel {
	
	NSAssert([verticalSlices count] != 0, @"Empty vertical slices");
	NSMutableArray *parentBoundables = [NSMutableArray array];
	
	for (NSArray *vsi in verticalSlices) {
		NSArray *toAdd = [self createParentBoundablesFromVerticalSlicesWithChildBoundables:vsi level:newLevel];
		NSAssert([toAdd count] != 0, @"Empty parent boundable");
		[parentBoundables addObjectsFromArray:toAdd];
	}
	return parentBoundables;
	
}

- (NSArray *)createParentBoundablesFromVerticalSlicesWithChildBoundables:(NSArray *)childBoundables level:(int)newLevel {
	return [super createParentBoundables:childBoundables level:newLevel];
}

- (NSArray *)verticalSlices:(NSArray *)childBoundables count:(int)sliceCount {
	int sliceCapacity = (int)ceil((double)[childBoundables count] / (double)sliceCount);
	NSMutableArray *slices = [NSMutableArray array];
	
	int i = 0, nchilds = [childBoundables count];
	
	for (int j = 0; j < sliceCount; j++) {
		NSMutableArray *slicesj = [NSMutableArray arrayWithCapacity:sliceCapacity];
		int boundablesAddedToSlice = 0;
		while (i < nchilds && boundablesAddedToSlice < sliceCapacity) {
			id <OTSBoundable> childBoundable = [childBoundables objectAtIndex:i];
			++i;
			[slicesj addObject:childBoundable];
			++boundablesAddedToSlice;
		}
		[slices addObject:slicesj];		
	}
	return slices;
}

+ (double)avgOfDouble:(double)a andDouble:(double)b {
	return (a + b) / 2.0;
}

+ (double)centreY:(OTSEnvelope *)e {
	return [OTSSTRtree avgOfDouble:e.miny andDouble:e.maxy];
}

- (NSArray *)createParentBoundables:(NSArray *)childBoundables level:(int)newLevel {

	NSAssert([childBoundables count] != 0, @"Empty child boundable");
	int minLeafCount = (int)ceil((double)[childBoundables count]/(double)nodeCapacity);
	
	NSArray *sortedChildBoundables = [self sortBoundables:childBoundables];
	NSArray *verticalSlicesV = [self verticalSlices:sortedChildBoundables count:(int)ceil(sqrt((double)minLeafCount))];
	
	return [self createParentBoundablesFromVerticalSlices:verticalSlicesV level:newLevel];	
}

- (NSArray *)sortBoundables:(NSArray *)input {
	NSAssert(input != nil, @"Sort input nil");
	return [input sortedArrayUsingSelector:@selector(compareForNSComparisonResult:)];
}

- (OTSAbstractNode *)createNode:(int)level {
	OTSAbstractNode *an = [[OTSSTRAbstractNode alloc] initWithLevel:level capacity:nodeCapacity];
	[nodes addObject:an];
	return [an autorelease];
}

- (id <NSObject, OTSIntersectsOp>)getIntersectsOp {
	return intersectsOp;
}

- (void)insert:(id)item havingEnvelope:(OTSEnvelope *)itemEnv {
	if ([itemEnv isNull]) { return; }
	[super insert:itemEnv item:item];
}

- (void)query:(OTSEnvelope *)searchEnv into:(NSMutableArray *)output {
	[super query:searchEnv outputInto:output];
}

- (void)query:(OTSEnvelope *)searchEnv with:(id <OTSItemVisitor>)visitor {
	[super query:searchEnv usingVisitor:visitor];
}

- (BOOL)remove:(id)item havingEnvelope:(OTSEnvelope *)itemEnv {
	return [super remove:itemEnv item:item];
}

@end
