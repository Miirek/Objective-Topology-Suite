//
//  OTSRectangleIntersects.m
//

#import "OTSRectangleIntersects.h"
#import "OTSSegmentIntersectionTester.h"
#import "OTSShortCircuitedGeometryVisitor.h"
#import "OTSLinearComponentExtractor.h"
#import "OTSEnvelope.h"
#import "OTSCoordinateSequence.h"
#import "OTSLineString.h"
#import "OTSIntersectionMatrix.h"
#import "OTSSimplePointInAreaLocator.h"

const int kOTSMaximumScanSegmentCount = 200;

@interface OTSEnvelopeIntersectsVisitor : OTSShortCircuitedGeometryVisitor {
	OTSEnvelope *rectEnv;
	BOOL intersects;
}

@property (nonatomic, retain) OTSEnvelope *rectEnv;
@property (nonatomic, assign) BOOL intersects;

- (id)initWithEnvelope:(OTSEnvelope *)env;

@end

@implementation OTSEnvelopeIntersectsVisitor

@synthesize rectEnv;
@synthesize intersects;

- (id)initWithEnvelope:(OTSEnvelope *)env {
	if (self = [super init]) {
		self.rectEnv = env;
		intersects = NO;
	}
	return self;
}

- (BOOL)isDone {
	return intersects;
}

- (void)visit:(OTSGeometry *)element {
	OTSEnvelope *elementEnv = [element getEnvelopeInternal];
	
	// disjoint
	if (![rectEnv intersects:elementEnv]) {
		return;
	}
	
	// fully contained - must intersect
	if ([rectEnv contains:elementEnv]) {
		intersects = YES;
		return;
	}
	
	/*
	 * Since the envelopes intersect and the test element is
	 * connected, if the test envelope is completely bisected by
	 * an edge of the rectangle the element and the rectangle
	 * must touch (This is basically an application of the
	 * Jordan Curve Theorem).  The alternative situation
	 * is that the test envelope is "on a corner" of the
	 * rectangle envelope, i.e. is not completely bisected.
	 * In this case it is not possible to make a conclusion
	 * about the presence of an intersection.
	 */
	if (elementEnv.minx >= rectEnv.minx
		&& elementEnv.maxx <= rectEnv.maxx) {
		intersects = YES;
		return;
	}
	if (elementEnv.miny >= rectEnv.miny
		&& elementEnv.maxy <= rectEnv.maxy) {
		intersects = YES;
		return;
	}	
}

@end

@interface OTSContainsPointVisitor : OTSShortCircuitedGeometryVisitor {
	OTSEnvelope *rectEnv;
	BOOL containsPoint;
	OTSCoordinateSequence *rectSeq;
}

@property (nonatomic, retain) OTSEnvelope *rectEnv;
@property (nonatomic, assign) BOOL containsPoint;
@property (nonatomic, retain) OTSCoordinateSequence *rectSeq;

- (id)initWithRectangle:(OTSPolygon *)rect;

@end

@implementation OTSContainsPointVisitor

@synthesize rectEnv;
@synthesize containsPoint;
@synthesize rectSeq;

- (id)initWithRectangle:(OTSPolygon *)rect {
	if (self = [super init]) {
		self.rectEnv = [rect getEnvelopeInternal];
		containsPoint = NO;
		self.rectSeq = [[rect getExteriorRing] getCoordinatesRO];
	}
	return self;
}

- (void)dealloc {
	[rectEnv release];
	[rectSeq release];
	[super dealloc];
}

- (BOOL)isDone {
	return containsPoint;
}

- (void)visit:(OTSGeometry *)geom {
	
	OTSPolygon *poly;
	
	if ([geom isKindOfClass:[OTSPolygon class]]) {
		poly = (OTSPolygon *)geom;
	} else {
		return;
	}
	
	OTSEnvelope *elementEnv = [geom getEnvelopeInternal];
	
	if (![rectEnv intersects:elementEnv]) {
		return;
	}
	
	// test each corner of rectangle for inclusion
	for (int i = 0; i < 4; i++) {
		
		OTSCoordinate *rectPt = [rectSeq getAt:i];
		
		if (![elementEnv containsCoordinate:rectPt]) {
			continue;
		}
		
		// check rect point in poly (rect is known not to
		// touch polygon at this point)
		if ([OTSSimplePointInAreaLocator containsPoint:rectPt inPolygon:poly]) {
			containsPoint = YES;
			return;
		}
	}
	
}

@end

@interface OTSLineIntersectsVisitor : OTSShortCircuitedGeometryVisitor {
	OTSPolygon *rectangle;
	OTSEnvelope *rectEnv;
	BOOL intersects;
	OTSCoordinateSequence *rectSeq;
}

@property (nonatomic, retain) OTSPolygon *rectangle;
@property (nonatomic, retain) OTSEnvelope *rectEnv;
@property (nonatomic, assign) BOOL intersects;
@property (nonatomic, retain) OTSCoordinateSequence *rectSeq;

- (id)initWithRectangle:(OTSPolygon *)rect;
- (void)computeSegmentIntersection:(OTSGeometry *)geom;

@end

@implementation OTSLineIntersectsVisitor

@synthesize rectangle;
@synthesize rectEnv;
@synthesize intersects;
@synthesize rectSeq;

- (id)initWithRectangle:(OTSPolygon *)rect {
	if (self = [super init]) {
		self.rectangle = rect;
		self.rectEnv = [rect getEnvelopeInternal];
		intersects = NO;
		self.rectSeq = [[rect getExteriorRing] getCoordinatesRO];
	}
	return self;
}

- (void)dealloc {
	[rectangle release];
	[rectEnv release];
	[rectSeq release];
	[super dealloc];
}

- (BOOL)isDone {
	return intersects;
}

- (void)computeSegmentIntersection:(OTSGeometry *)geom {
	// check segment intersection
	// get all lines from geom (e.g. if it's a multi-ring polygon)
	NSMutableArray *lines = [NSMutableArray array];
	[OTSLinearComponentExtractor getLinesFromGeometry:geom into:lines];
	OTSSegmentIntersectionTester *si = [[OTSSegmentIntersectionTester alloc] init];	
	if ([si coordinateSequence:rectSeq hasIntersectionWithLineStrings:lines]) {
		intersects = YES;
	}
	[si release];
}

- (void)visit:(OTSGeometry *)geom {
	OTSEnvelope *elementEnv = [geom getEnvelopeInternal];
	if (![rectEnv intersects:elementEnv]) {
		return;
	}
	
	// check if general relate algorithm should be used,
	// since it's faster for large inputs
	if ([geom getNumPoints] > kOTSMaximumScanSegmentCount) {
		intersects = [[rectangle relate:geom] isIntersects];
		return;
	}
	
	// if small enough, test for segment intersection directly
	[self computeSegmentIntersection:geom];
}	

@end


@implementation OTSRectangleIntersects

@synthesize rectangle;
@synthesize rectEnv;

- (id)initWithPolygon:(OTSPolygon *)newRect {
	if (self = [super init]) {
		self.rectangle = newRect;
		self.rectEnv = [newRect getEnvelopeInternal];
	}
	return self;
}

- (void)dealloc {
	[rectangle release];
	[rectEnv release];
	[super dealloc];
}

- (BOOL)intersects:(OTSGeometry *)geom {
	if (![rectEnv intersects:[geom getEnvelopeInternal]])
		return NO;
	
	// test envelope relationships
	OTSEnvelopeIntersectsVisitor *visitor = [[OTSEnvelopeIntersectsVisitor alloc] initWithEnvelope:rectEnv];
	[visitor applyTo:geom];
	if (visitor.intersects) {
		[visitor release];
		return YES;
	} else {
		[visitor release];
	}
	
	// test if any rectangle corner is contained in the target
	OTSContainsPointVisitor *ecpVisitor = [[OTSContainsPointVisitor alloc] initWithRectangle:rectangle];	
	[ecpVisitor applyTo:geom];
	if (ecpVisitor.containsPoint) {
		[ecpVisitor release];
		return YES;
	} else {
		[ecpVisitor release];
	}

	// test if any lines intersect
	OTSLineIntersectsVisitor *liVisitor = [[OTSLineIntersectsVisitor alloc] initWithRectangle:rectangle];
	[liVisitor applyTo:geom];
	if (liVisitor.intersects) {
		[liVisitor release];
		return YES;
	} else {
		[liVisitor release];
	}
	
	return NO;
	
}

+ (BOOL)rectangle:(OTSPolygon *)rectangle intersects:(OTSGeometry *)b {
	OTSRectangleIntersects *rp = [[OTSRectangleIntersects alloc] initWithPolygon:rectangle];
	BOOL ret = [rp intersects:b];
	[rp release];
	return ret;
}

@end
