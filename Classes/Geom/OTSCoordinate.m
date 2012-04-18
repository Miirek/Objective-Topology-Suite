//
//  OTSCoordinate.m
//

#import "OTSCoordinate.h"

//static OTSCoordinate * OTSNullCoordinate = nil;

@implementation OTSCoordinate

@synthesize x, y, z;

/*
+ (void)initialize {
    if (self == [OTSCoordinate class]) {
		OTSNullCoordinate = [[OTSCoordinate alloc] initWithX:NAN Y:NAN Z:NAN];
    }	
}
*/

- (id)initWithX:(double)_x Y:(double)_y {
	if (self = [super init]) {
		self.x = _x;
		self.y = _y;
	}
	return self;
}

- (id)initWithX:(double)_x Y:(double)_y Z:(double)_z {
	if (self = [super init]) {
		self.x = _x;
		self.y = _y;
		self.z = _z;
	}
	return self;	
}

- (id)initWithCoordinate:(OTSCoordinate * const)other {
	if (self = [super init]) {
		self.x = other.x;
		self.y = other.y;
		self.z = other.z;
	}
	return self;
}

+ (id)coordinateWithX:(double)_x Y:(double)_y {
	return [[[OTSCoordinate alloc] initWithX:_x Y:_y] autorelease];
}

+ (id)coordinateWithCoordinate:(OTSCoordinate * const)other {
	return [[[OTSCoordinate alloc] initWithCoordinate:other] autorelease];
}

- (OTSCoordinate *)clone {
	OTSCoordinate *ret = [[OTSCoordinate alloc] initWithCoordinate:self];
	return [ret autorelease];
	//return [[[OTSCoordinate alloc] initWithX:x Y:y] autorelease];
}

- (BOOL)isEqual2D:(OTSCoordinate *)other {
	if (x != other.x) return NO;
	if (y != other.y) return NO;
	return YES;
}

- (BOOL)isEqual:(id)anObject {
	if ([anObject isKindOfClass:[OTSCoordinate class]]) {
		OTSCoordinate *other = (OTSCoordinate *)anObject;
		return [self isEqual2D:other];
	}
	return NO;
}

+ (NSUInteger)oordinateHashCode:(double)d {
	int64_t f = (int64_t)(d);
	return (NSUInteger)(f^(f>>32));
}

- (NSUInteger)hash {
	//Algorithm from Effective Java by Joshua Bloch [Jon Aquino]
	NSUInteger result = 17;
	result = 37 * result + [OTSCoordinate oordinateHashCode:x];
	result = 37 * result + [OTSCoordinate oordinateHashCode:y];
	return result;	
}

- (double)distance:(OTSCoordinate *)p {
	double dx = x - p.x;
	double dy = y - p.y;
	return sqrt(dx * dx + dy * dy);
}

- (int)compareTo:(OTSCoordinate *)other {
	if (x < other.x) return -1;
	if (x > other.x) return 1;
	if (y < other.y) return -1;
	if (y > other.y) return 1;
	return 0;
}

+ (BOOL)coordinate:(OTSCoordinate *)c1 lessThan:(OTSCoordinate *)c2 {
	if ([c1 compareTo:c2] < 0) return YES;
	else return NO;
}

- (NSComparisonResult)compareForNSComparisonResult:(OTSCoordinate *)other {
	int diff = [self compareTo:other];
	if (diff > 0) {
		return NSOrderedDescending;
	}	
	if (diff < 0) {
		return NSOrderedAscending;
	}
	return NSOrderedSame;
}

- (id)copyWithZone:(NSZone *)zone {
	OTSCoordinate *copy = [[[self class] allocWithZone:zone] initWithX:[self x] Y:[self y] Z:[self z]];
    return copy;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"(%.6f, %.6f, %.6f)", x, y, z];
}

+ (OTSCoordinate * const)nullCoordinate {
	return [[[OTSCoordinate alloc] initWithX:NAN Y:NAN Z:NAN] autorelease];
}

- (BOOL)isNull {
	return (isnan(x) && isnan(y) && isnan(z));
}

@end
