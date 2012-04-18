//
//  OTSShortCircuitedGeometryVisitor.m
//

#import "OTSShortCircuitedGeometryVisitor.h"
#import "OTSGeometry.h"
#import "OTSGeometryCollection.h"

@implementation OTSShortCircuitedGeometryVisitor

@synthesize done;

- (id)init {
	if (self = [super init]) {
		done = NO;
	}
	return self;
}

- (BOOL)isDone {
	return done;
}

- (void)visit:(OTSGeometry *)element {
	// abstract
}

- (void)applyTo:(OTSGeometry *)geom {
	for (int i=0, n = [geom getNumGeometries]; i < n; ++i) {
		OTSGeometry *element = [geom getGeometryN:i];
		if ([geom isKindOfClass:[OTSGeometryCollection class]]) {
			[self applyTo:geom];
		} else {
			// calls the abstract virtual
			[self visit:element];
			if (!done) done = YES;
		}		
		if (done) return;
	}
}

@end
