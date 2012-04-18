//
//  OTSSweepLineEvent.m
//

#import "OTSSweepLineEvent.h"
#import "OTSSweepLineEventOBJ.h"

@implementation OTSSweepLineEvent

@synthesize edgeSet;
@synthesize object;
@synthesize x;
@synthesize eventType;
@synthesize insertEvent;
@synthesize deleteEventIndex;	

- (id)initWithEdgeSet:(id)newEdgeSet 
					x:(double)_x 
		  insertEvent:(OTSSweepLineEvent *)newInsertEvent 
			   object:(OTSSweepLineEventOBJ *)newObj {
	if (self = [super init]) {
		self.edgeSet = newEdgeSet;
		self.object = newObj;
		x = _x;
		self.insertEvent = newInsertEvent;
		deleteEventIndex = 0;
		
		if (insertEvent != nil) eventType = kOTSSweepLineDeleteEvent;
		else eventType = kOTSSweepLineInsertEvent;
	}
	return self;
}

- (void)dealloc {
	[edgeSet release];
	[object release];
	[insertEvent release];
	[super dealloc];
}

- (int)compareTo:(OTSSweepLineEvent *)sle {
	if (x < sle.x) return -1;
	if (x > sle.x) return 1;
	if (eventType < sle.eventType) return -1;
	if (eventType > sle.eventType) return 1;
	return 0;
}

- (NSComparisonResult)compareForNSComparisonResult:(OTSSweepLineEvent *)other {
	int diff = [self compareTo:other];
	if (diff > 0) {
		return NSOrderedDescending;
	}	
	if (diff < 0) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

- (BOOL)isInsert { return insertEvent == nil; }
- (BOOL)isDelete { return insertEvent != nil; }

+ (BOOL)sweepLineEvent:(OTSSweepLineEvent *)f lessThan:(OTSSweepLineEvent *)s {
	if (f.x < s.x) return YES;
	if (f.x > s.x) return NO;
	if (f.eventType < s.eventType) return YES;
	return NO;
}

@end
