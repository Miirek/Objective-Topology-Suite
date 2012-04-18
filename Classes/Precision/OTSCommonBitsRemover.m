//
//  OTSCommonBitsRemover.m
//

#import "OTSCommonBitsRemover.h"
#import "OTSCommonBits.h"
#import "OTSCoordinateFilter.h"
#import "OTSCoordinate.h"
#import "OTSGeometry.h"

@interface OTSTranslator : OTSCoordinateFilter {
	OTSCoordinate *trans;
}

@property (nonatomic, retain) OTSCoordinate *trans;

- (id)initWithTrans:(OTSCoordinate *)_trans;

@end

@interface OTSCommonCoordinateFilter : OTSCoordinateFilter {
	OTSCommonBits *commonBitsX;
	OTSCommonBits *commonBitsY;
}

@property (nonatomic, retain) OTSCommonBits *commonBitsX;
@property (nonatomic, retain) OTSCommonBits *commonBitsY;

- (void)getCommonCoordinate:(OTSCoordinate *)c;

@end

@implementation OTSTranslator

@synthesize trans;

- (id)initWithTrans:(OTSCoordinate *)_trans {
	if (self = [super init]) {
		self.trans = _trans;
	}
	return self;
}

- (void)dealloc {
	[trans release];
	[super dealloc];
}

- (void)filter_rw:(OTSCoordinate *)coord {
	coord.x += trans.x;
	coord.y += trans.y;
}

- (void)filter_ro:(OTSCoordinate *)coord {
}

@end

@implementation OTSCommonCoordinateFilter

@synthesize commonBitsX;
@synthesize commonBitsY;

- (id)init {
	if (self = [super init]) {
		commonBitsX = [[OTSCommonBits alloc] init];
		commonBitsY = [[OTSCommonBits alloc] init];
	}
	return self;
}

- (void)dealloc {
	[commonBitsX release];
	[commonBitsY release];
	[super dealloc];
}

- (void)filter_rw:(OTSCoordinate *)coord {
}

- (void)filter_ro:(OTSCoordinate *)coord {
	[commonBitsX add:coord.x];
	[commonBitsX add:coord.y];
}

- (void)getCommonCoordinate:(OTSCoordinate *)c {
	c.x = [commonBitsX getCommon];
	c.y = [commonBitsX getCommon];
}

@end

@implementation OTSCommonBitsRemover

@synthesize commonCoord;	
@synthesize ccFilter;

- (id)init {
	if (self = [super init]) {
		commonCoord = [[OTSCoordinate alloc] init];
		ccFilter = [[OTSCommonCoordinateFilter alloc] init];
	}
	return self;
}

- (void)dealloc {
	[commonCoord release];
	[ccFilter release];
	[super dealloc];
}

- (void)add:(OTSGeometry *)geom {
	[geom apply_roCoordinateFilter:ccFilter];
	[ccFilter getCommonCoordinate:commonCoord];
}

- (OTSCoordinate *)getCommonCoordinate {
	return commonCoord;
}

- (OTSGeometry *)removeCommonBits:(OTSGeometry *)geom {
	
	if (commonCoord.x == 0.0 && commonCoord.y == 0.0)
		return geom;
	
	OTSCoordinate *invCoord = [[OTSCoordinate alloc] initWithX:commonCoord.x Y:commonCoord.y];
	invCoord.x = -invCoord.x;
	invCoord.y = -invCoord.y;
	
	OTSTranslator *trans = [[OTSTranslator alloc] initWithTrans:invCoord];
	[invCoord release];
	[geom apply_roCoordinateFilter:trans];
	[geom geometryChanged];
	[trans release];	
	
	return geom;	
}

- (OTSGeometry *)addCommonBits:(OTSGeometry *)geom {
	
	OTSTranslator *trans = [[OTSTranslator alloc] initWithTrans:commonCoord];
	[geom apply_roCoordinateFilter:trans];
	[geom geometryChanged];
	[trans release];	
	
	return geom;
}

@end
