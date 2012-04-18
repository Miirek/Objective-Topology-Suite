//
//  OTSSnapIfNeededOverlayOp.h
//

#import <Foundation/Foundation.h>

#import "OTSOverlayOp.h" // for enums 

@class OTSGeometry;

@interface OTSSnapIfNeededOverlayOp : NSObject {
	OTSGeometry *geom0;
	OTSGeometry *geom1;
}

@property (nonatomic, retain) OTSGeometry *geom0;
@property (nonatomic, retain) OTSGeometry *geom1;

- (id)initWithFirstGeometry:(OTSGeometry *)g0 
		  andSecondGeometry:(OTSGeometry *)g1;
- (OTSGeometry *)resultGeometryWithOp:(OTSOverlayOpCode)opCode;

+ (OTSGeometry *)overlayOpFirstGeometry:(OTSGeometry *)g0 
						 andSecondGeometry:(OTSGeometry *)g1 
									withOp:(OTSOverlayOpCode)opCode;

@end
