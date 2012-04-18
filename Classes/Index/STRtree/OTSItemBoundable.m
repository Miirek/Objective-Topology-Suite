//
//  OTSItemBoundable.m
//

#import "OTSItemBoundable.h"


@implementation OTSItemBoundable

- (id)initWithBounds:(id)newBounds item:(id)newItem {
	if (self = [super init]) {
		bounds = [newBounds retain];
		item = [newItem retain];
	}
	return self;
}

- (void)dealloc {
	[bounds release];
	[item release];
	[super dealloc];
}

- (id)getBounds {
	return bounds;
}

- (id)getItem {
	return item;
}

@end
