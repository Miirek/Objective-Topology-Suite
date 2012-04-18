//
//  OTSCoordinateSequence.m
//

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinateFilter.h"

@implementation OTSCoordinateSequence

@synthesize coordinates;

- (id)init {
	if (self = [super init]) {
		coordinates = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithArray:(NSArray *)_coordinates {
	if (self = [super init]) {
		if (_coordinates == nil) {
			coordinates = [[NSMutableArray alloc] init];
		} else {
			coordinates = [[NSMutableArray alloc] initWithArray:_coordinates];
		}
	}
	return self;
}

- (id)initWithCapacity:(int)capacity {
	if (self = [super init]) {
		self.coordinates = [NSMutableArray arrayWithCapacity:capacity];
	}
	return self;
}

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)other {
	if (self = [super init]) {
		self.coordinates = [NSMutableArray arrayWithArray:other.coordinates];
	}
	return self;
}

- (id)initWithCoordinateSequence:(OTSCoordinateSequence *)other allowRepeated:(BOOL)allowRepeated {
	if (self = [super init]) {
		self.coordinates = [NSMutableArray array];
		for (int i = 0, n = [other size]; i < n; i++) {
			if (allowRepeated || i == 0) {
				[coordinates addObject:[other getAt:i]];
			} else {
				OTSCoordinate *c = [other getAt:i];
				if (![[other getAt:i - 1] isEqual2D:c]) {
					[coordinates addObject:c];
				}
			}			
		}
	}
	return self;
}

+ (id)coordinateSequenceWithArray:(NSArray *)_coordinates {
	return [[[OTSCoordinateSequence alloc] initWithArray:_coordinates] autorelease];
}

+ (id)coordinateSequenceWithCoordinates:(OTSCoordinate *)firstObject, ... {
	OTSCoordinate *eachObject;
	OTSCoordinateSequence *ret = [[OTSCoordinateSequence alloc] init];
	va_list argumentList;
	if (firstObject) {                    // The first argument isn't part of the varargs list, so we'll handle it separately.
		[ret add:firstObject];
		va_start(argumentList, firstObject);          // Start scanning for arguments after firstObject.
		while (eachObject = va_arg(argumentList, OTSCoordinate *)) // As many times as we can get an argument of type "id"
			[ret add:eachObject]; // that isn't nil, add it to self's contents.
		va_end(argumentList);
	}
	return [ret autorelease];
}

/*
+ (id)coordinateSequenceWithArrayOfXY:(double)firstOordinate, ... {
	int i = 0;
	double oord;
	
	
	return nil;
}
*/

- (void)dealloc {
	[coordinates release];
	[super dealloc];
}

- (void)add:(OTSCoordinate *)coordinate {
	[coordinates addObject:coordinate];
}

- (void)set:(OTSCoordinate *)coordinate at:(NSUInteger)index {
	[coordinates replaceObjectAtIndex:index withObject:coordinate];
}

- (int)size {
	return [coordinates count];
}

- (OTSCoordinate *)getAt:(NSUInteger)index {
	return (OTSCoordinate *)[coordinates objectAtIndex:index];
}

+ (BOOL)hasRepeatedPoints:(OTSCoordinateSequence *)cl {
    for (int i = 1, n = [cl size]; i < n; i++) {
		if ([[cl getAt:i - 1] isEqual2D:[cl getAt:i]]) {
			return YES;
		}
    }
    return NO;
}

+ (OTSCoordinateSequence *)removeRepeatedPoints:(OTSCoordinateSequence *)cl {	
	/*
	NSSet *ns = [NSSet setWithArray:cl.coordinates];
	return [[[OTSCoordinateSequence alloc] initWithArray:[ns allObjects]] autorelease];
	 */
	if ([OTSCoordinateSequence hasRepeatedPoints:cl]) {
		return [[[OTSCoordinateSequence alloc] initWithCoordinateSequence:cl allowRepeated:NO] autorelease];
	} else {
		return [[[OTSCoordinateSequence alloc] initWithCoordinateSequence:cl] autorelease];
	}
}

+ (int)increasingDirection:(OTSCoordinateSequence *)pts {
	int ptsize = [pts size];
	for (int i = 0, n = ptsize/2; i < n; ++i) {
		int j = ptsize - 1 - i;
		// skip equal points on both ends
		int comp = [[pts getAt:i] compareTo:[pts getAt:j]];
		if (comp != 0) return comp;
	}
	// array must be a palindrome - defined to be in positive direction
	return 1;
}

- (OTSCoordinateSequence *)clone {
	return [[[OTSCoordinateSequence alloc] initWithArray:coordinates] autorelease];
}

- (NSArray *)toArray {
	return coordinates;
}

- (void)apply_rw:(OTSCoordinateFilter *)filter {
	for (OTSCoordinate *c in coordinates) {
		[filter filter_rw:c];
	}
}

- (void)apply_ro:(OTSCoordinateFilter *)filter {
	for (OTSCoordinate *c in coordinates) {
		[filter filter_ro:c];
	}
}

@end
