//
//  OTSGraphComponent.m
//


#import "OTSLocation.h"
#import "OTSPosition.h"
#import "OTSTopologyLocation.h"
#import "OTSLabel.h"
#import "OTSIntersectionMatrix.h"
#import "OTSGraphComponent.h"


@implementation OTSGraphComponent

@synthesize label;
@synthesize inResult;
@synthesize visited;
@synthesize isolated;

- (id)init {
	if (self = [super init]) {
		self.label = nil;
		inResult = NO;
		covered = NO;
		coveredSet = NO;
		visited = NO;
	}
	return self;
}

- (id)initWithLabel:(OTSLabel *)_label {
	if (self = [self init]) {
		self.label = _label;
	}
	return self;
}

- (void)dealloc {
	[label release];
	[super dealloc];
}

- (void)updateIM:(OTSIntersectionMatrix *)im {
	NSAssert([label geometryCount] >= 2, @"found partial label");
	[self computeIM:im];
}

- (void)computeIM:(OTSIntersectionMatrix *)im {
}

- (void)setCovered:(BOOL)isCovered {
	covered = isCovered;
	coveredSet = YES;
}

- (BOOL)isCovered {
	return covered;
}

- (BOOL)isCoveredSet {
	return coveredSet;
}

- (BOOL)isIsolated {
	return isolated;
}

@end
