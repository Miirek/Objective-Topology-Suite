//
//  OTSTopologyLocation.m
//

#import "OTSLocation.h"
#import "OTSPosition.h"
#import "OTSTopologyLocation.h"


@implementation OTSTopologyLocation

@synthesize locations;

- (id)initWithNewLocation:(NSArray *)newValue {
	if (self = [super init]) {
		self.locations = [NSMutableArray array];
		for (int i = 0; i < [newValue count]; i++) {
			[locations addObject:[NSNumber numberWithInt:kOTSLocationUndefined]];
		}
	}
	return self;
}


- (id)initWithOnPosition:(int)on 
			leftPosition:(int)left 
		   rightPosition:(int)right {
	if (self = [super init]) {
		self.locations = [NSMutableArray arrayWithObjects:[NSNull null], [NSNull null], [NSNull null], nil];
		[locations replaceObjectAtIndex:kOTSPositionOn withObject:[NSNumber numberWithInt:on]];
		[locations replaceObjectAtIndex:kOTSPositionLeft withObject:[NSNumber numberWithInt:left]];
		[locations replaceObjectAtIndex:kOTSPositionRight withObject:[NSNumber numberWithInt:right]];
	}
	return self;
}

- (id)initWithOnLocation:(int)on {
	if (self = [super init]) {
		self.locations = [NSMutableArray array];		
		[locations insertObject:[NSNumber numberWithInt:on] atIndex:kOTSPositionOn];
	}
	return self;
}

- (id)initWithTopologyLocation:(OTSTopologyLocation *)gl {
	if (self = [super init]) {
		self.locations = [NSMutableArray arrayWithArray:[gl locations]];
	}
	return self;
}

- (int)getAt:(int)posIndex {
	if (posIndex < [locations count])
		return [(NSNumber *)[locations objectAtIndex:posIndex] intValue];
	return kOTSLocationUndefined;
}

- (BOOL)isNull {
	for (int i = 0; i < [locations count]; i++) {
		if ([(NSNumber *)[locations objectAtIndex:i] intValue] != kOTSLocationUndefined)
			return NO;
	}
	return TRUE;
}

- (BOOL)isAnyNull {
	for (int i = 0; i < [locations count]; i++) {
		if ([(NSNumber *)[locations objectAtIndex:i] intValue] == kOTSLocationUndefined)
			return YES;
	}
	return NO;
}

- (BOOL)isEqualOnSide:(OTSTopologyLocation *)le onLocationIndex:(int)locIndex {
	return ([(NSNumber *)[locations objectAtIndex:locIndex] intValue] == [(NSNumber *)[[le locations] objectAtIndex:locIndex] intValue]);
}

- (BOOL)isArea {
	return ([locations count] > 1);
}

- (BOOL)isLine {
	return ([locations count] == 1);
}

- (void)flip {
	if ([locations count] <= 1)
		return;
	NSNumber *temp = [locations objectAtIndex:kOTSPositionLeft];
	[locations replaceObjectAtIndex:kOTSPositionLeft withObject:[locations objectAtIndex:kOTSPositionRight]];
	[locations replaceObjectAtIndex:kOTSPositionRight withObject:temp];
}

- (void)setAllLocationsWith:(int)locValue {
	for (int i = 0; i < [locations count]; i++) {
		[locations replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:locValue]];
	}	
}

- (void)setAllLocationsIfNullWith:(int)locValue {
	for (int i = 0; i < [locations count]; i++) {
		if ([(NSNumber *)[locations objectAtIndex:i] intValue] == kOTSLocationUndefined)
			[locations replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:locValue]];
	}
}

- (void)setAt:(int)posIndex withLocation:(int)locValue {
	[locations replaceObjectAtIndex:posIndex withObject:[NSNumber numberWithInt:locValue]];
}

- (void)setLocation:(int)locValue {
	[self setAt:kOTSPositionOn withLocation:locValue];
}

- (void)setWithOnLocation:(int)on 
			 leftPosition:(int)left 
			rightPosition:(int)right {
	NSAssert([locations count] >= 3, @"Incompatible location, expecting >= 3 locations");
	[self setAt:kOTSPositionOn withLocation:on];
	[self setAt:kOTSPositionLeft withLocation:left];
	[self setAt:kOTSPositionRight withLocation:right];
}

- (BOOL)allPositionsEqualWith:(int)locValue {
	for (int i = 0; i < [locations count]; i++) {
		if ([(NSNumber *)[locations objectAtIndex:i] intValue] != locValue)
			return NO;
	}
	return TRUE;	
}

- (void)mergeWith:(OTSTopologyLocation *)gl {
	int sz = [locations count];
	int glsz = [[gl locations] count];
	if (glsz > sz) {
		NSNumber *temp = [locations objectAtIndex:kOTSPositionOn];
		self.locations = [NSMutableArray arrayWithCapacity:3];
		[locations replaceObjectAtIndex:kOTSPositionOn withObject:temp];
		[self setAt:kOTSPositionLeft withLocation:kOTSLocationUndefined];
		[self setAt:kOTSPositionRight withLocation:kOTSLocationUndefined];
	}
	for (int i = 0; i < sz; ++i) {
		if ([(NSNumber *)[locations objectAtIndex:i] intValue] == kOTSLocationUndefined)
			[locations replaceObjectAtIndex:i withObject:[[gl locations] objectAtIndex:i]];
	}
}

- (void)dealloc {
	[locations release];
	[super dealloc];
}

@end
