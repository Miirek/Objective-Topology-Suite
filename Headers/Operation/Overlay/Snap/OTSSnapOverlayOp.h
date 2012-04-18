//
//  OTSSnapOverlayOp.h
//

#import <Foundation/Foundation.h>

#import "OTSOverlayOp.h" // for enums 
#import "OTSCommonBitsRemover.h" // for dtor visibility by auto_ptr

@class OTSGeometry;

@interface OTSSnapOverlayOp : NSObject {
	OTSGeometry *geom0;
	OTSGeometry *geom1;
	double snapTolerance;	
	OTSCommonBitsRemover *cbr;
}

@property (nonatomic, retain) OTSGeometry *geom0;
@property (nonatomic, retain) OTSGeometry *geom1;
@property (nonatomic, assign) double snapTolerance;	
@property (nonatomic, retain) OTSCommonBitsRemover *cbr;

+ (OTSGeometry *)overlayOpOfGeometry1:(OTSGeometry *)g0 
							   geometry2:(OTSGeometry *)g1 
								  opCode:(OTSOverlayOpCode)opCode;
+ (OTSGeometry *)intersectionOfGeometry1:(OTSGeometry *)g0 
								  geometry2:(OTSGeometry *)g1;
+ (OTSGeometry *)unionOfGeometry1:(OTSGeometry *)g0 
						   geometry2:(OTSGeometry *)g1;
+ (OTSGeometry *)differenceOfGeometry1:(OTSGeometry *)g0 
								geometry2:(OTSGeometry *)g1;
+ (OTSGeometry *)symDifferenceOfGeometry1:(OTSGeometry *)g0 
								   geometry2:(OTSGeometry *)g1;

- (id)initWithGeometry1:(OTSGeometry *)g0 
			  geometry2:(OTSGeometry *)g1;
- (void)computeSnapTolerance;
- (OTSGeometry *)getResultGeometry:(OTSOverlayOpCode)opCode;

- (void)snapGeometry1:(OTSGeometry **)ret0
            geometry2:(OTSGeometry **)ret1;

- (void)removeCommonBitsOfGeometry1:(OTSGeometry *)g0
                          geometry2:(OTSGeometry *)g1
                            result1:(OTSGeometry **)ret0
                            result2:(OTSGeometry **)ret1;

- (void)prepareResult:(OTSGeometry *)geom;

@end
