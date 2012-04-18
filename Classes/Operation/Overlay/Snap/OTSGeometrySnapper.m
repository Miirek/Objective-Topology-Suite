//
//  OTSGeometrySnapper.m
//

#import "OTSGeometrySnapper.h"
#import "OTSLineStringSnapper.h"
#import "OTSGeometryTransformer.h" // inherit. of SnapTransformer
#import "OTSCoordinateSequence.h"
#import "OTSCoordinate.h"
#import "OTSGeometryFactory.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSPrecisionModel.h"
#import "OTSUniqueCoordinateArrayFilter.h"

static double kOTSSnapPrecisionFactor = 10e-10; 

@interface OTSSnapTransformer : OTSGeometryTransformer {
	double snapTol;	
	NSArray *snapPts;
}

@property (nonatomic, assign) double snapTol;	
@property (nonatomic, retain) NSArray *snapPts;

- (id)initWithSnapTolerance:(double)nSnapTol snapPoints:(NSArray *)nSnapPts;
- (OTSCoordinateSequence *)snapLine:(OTSCoordinateSequence *)srcPts;

@end

@implementation OTSGeometrySnapper

@synthesize srcGeom;

- (id)initWithGeometry:(OTSGeometry *)g {
	if (self = [super init]) {
		self.srcGeom = g;
	}
	return self;
}

- (void)dealloc {
	[srcGeom release];
	[super dealloc];
}

+ (void)snapGeometry1:(OTSGeometry *)g0
            geometry2:(OTSGeometry *)g1
        snapTolerance:(double)snapTolerance
              result1:(OTSGeometry **)ret0
              result2:(OTSGeometry **)ret1 {
	
	OTSGeometrySnapper *snapper0 = [[OTSGeometrySnapper alloc] initWithGeometry:g0];
	*ret0 = [snapper0 snapTo:g1 snapTolerance:snapTolerance];
	
	OTSGeometrySnapper *snapper1 = [[OTSGeometrySnapper alloc] initWithGeometry:g1];
	
	/**
	 * Snap the second geometry to the snapped first geometry
	 * (this strategy minimizes the number of possible different
	 * points in the result)
	 */
	*ret1 = [snapper1 snapTo:*ret0 snapTolerance:snapTolerance];
	
	[snapper0 release];
	[snapper1 release];
}

- (OTSGeometry *)snapTo:(OTSGeometry *)g snapTolerance:(double)snapTolerance {
	
	// Get snap points
	NSArray *snapPts = [self extractTargetCoordinates:g];
	
	// Apply a SnapTransformer to source geometry
	// (we need a pointer for dynamic polymorphism)
	OTSSnapTransformer *snapTrans = [[OTSSnapTransformer alloc] initWithSnapTolerance:snapTolerance snapPoints:snapPts];
	OTSGeometry *ret = [snapTrans transform:srcGeom];
	[snapTrans release];
	return ret;
}

+ (double)computeOverlaySnapTolerance:(OTSGeometry *)g {
	
	double snapTolerance = [OTSGeometrySnapper computeSizeBasedSnapTolerance:g];
	
	/**
	 * Overlay is carried out in the precision model
	 * of the two inputs.
	 * If this precision model is of type FIXED, then the snap tolerance
	 * must reflect the precision grid size.
	 * Specifically, the snap tolerance should be at least
	 * the distance from a corner of a precision grid cell
	 * to the centre point of the cell.
	 */
	OTSPrecisionModel *pm = g.precisionModel;
	if (pm.modelType == kOTSPrecisionFixed) {
		double fixedSnapTol = (1 / pm.scale) * 2 / 1.415;
		if (fixedSnapTol > snapTolerance)
			snapTolerance = fixedSnapTol;
	}
	return snapTolerance;	
	
}

+ (double)computeSizeBasedSnapTolerance:(OTSGeometry *)g {
	OTSEnvelope *env = [g getEnvelopeInternal];
	double minDimension = MIN([env height], [env width]);
	double snapTol = minDimension * kOTSSnapPrecisionFactor;
	return snapTol;
}

+ (double)computeOverlaySnapToleranceOfGeometry1:(OTSGeometry *)g1 
									   geometry2:(OTSGeometry *)g2 {
	return MIN([OTSGeometrySnapper computeOverlaySnapTolerance:g1], 
			   [OTSGeometrySnapper computeOverlaySnapTolerance:g2]);
}

- (NSArray *)extractTargetCoordinates:(OTSGeometry *)g {
	NSMutableArray *snapPts = [NSMutableArray array];
	OTSUniqueCoordinateArrayFilter *filter = [[OTSUniqueCoordinateArrayFilter alloc] initWithArray:snapPts];
	[g apply_roCoordinateFilter:filter];
	[filter release];
	return snapPts;	
}

@end

@implementation OTSSnapTransformer

@synthesize snapTol;	
@synthesize snapPts;

- (id)initWithSnapTolerance:(double)nSnapTol snapPoints:(NSArray *)nSnapPts {
	if (self = [super init]) {
		snapTol = nSnapTol;
		self.snapPts = nSnapPts;
	}
	return self;
}

- (void)dealloc {
	[snapPts release];
	[super dealloc];
}

- (OTSCoordinateSequence *)snapLine:(OTSCoordinateSequence *)srcPts {
	OTSLineStringSnapper *snapper = [[OTSLineStringSnapper alloc] initWithCoordinates:[srcPts toArray] snapTolerance:snapTol];
	NSArray *newPts = [snapper snapTo:snapPts];
  [snapper release];
	OTSCoordinateSequenceFactory *cfact = factory.coordinateSequenceFactory;
	return [cfact createWithArray:newPts];
}

- (OTSCoordinateSequence *)transformCoordinates:(OTSCoordinateSequence *)coords parent:(OTSGeometry *)parent {
	return [self snapLine:coords];
}

@end