//
//  OTSLineStringSnapper.h
//

#import <Foundation/Foundation.h>

#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"

@class OTSGeometry;

@interface OTSLineStringSnapper : NSObject {
	NSArray *srcPts;
	double snapTolerance;	
	BOOL closed;	
}

@property (nonatomic, retain) NSArray *srcPts;
@property (nonatomic, assign) double snapTolerance;	
@property (nonatomic, assign) BOOL closed;

- (id)initWithCoordinates:(NSArray *)nSrcPts snapTolerance:(double)nSnapTol;
- (NSArray *)snapTo:(NSArray *)snapPts;
- (void)snapVertices:(NSMutableArray *)srcCoords snapPts:(NSArray *)snapPts;
- (int)findSnapForVertex:(OTSCoordinate *)pt snapPts:(NSArray *)snapPts;
- (void)snapSegments:(NSMutableArray *)srcCoords snapPts:(NSArray *)snapPts;
- (int)findSegmentToSnap:(OTSCoordinate *)snapPt coords:(NSArray *)coords;

@end
