//
//  OTSAbstractNode.m
//

#import "OTSAbstractNode.h"


@implementation OTSAbstractNode

@synthesize childBoundables;
@synthesize level;

- (id)initWithLevel:(int)newLevel {
	if (self = [self initWithLevel:newLevel capacity:10]) {
	}
	return self;
}

- (id)initWithLevel:(int)newLevel capacity:(int)capacity {
	if (self = [super init]) {
		level = newLevel;
		self.childBoundables = [NSMutableArray arrayWithCapacity:capacity];
		bounds = nil;
	}
	return self;
}

- (void)dealloc {
	[childBoundables release];
	[bounds release];
	[super dealloc];
}

- (void)addChildBoundable:(id <OTSBoundable>)childBoundable {
	NSAssert(bounds == nil, @"Bound already built");
	[childBoundables addObject:childBoundable];
}

- (id)computeBounds {
	// abstract
	return nil;
}

- (id)getBounds {
	if (bounds == nil) {
		bounds = [self computeBounds];
	}
	return bounds;
}

@end
