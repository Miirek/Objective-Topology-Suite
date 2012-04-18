//
//  OTSRelateOp.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryGraphOperation.h" // for inheritance
#import "OTSRelateComputer.h" // for composition

@class OTSBoundaryNodeRule;
@class OTSIntersectionMatrix;
@class OTSGeometry;

@interface OTSRelateOp : OTSGeometryGraphOperation {
	OTSRelateComputer *relateComp;
}

@property (nonatomic, retain) OTSRelateComputer *relateComp;

+ (OTSIntersectionMatrix *)relateGeometry:(OTSGeometry *)a andGeometry:(OTSGeometry *)b;
+ (OTSIntersectionMatrix *)relateGeometry:(OTSGeometry *)a 
								 andGeometry:(OTSGeometry *)b 
										with:(OTSBoundaryNodeRule *)boundaryNodeRule;
- (id)initWithGeometry:(OTSGeometry *)g0 andGeometry:(OTSGeometry *)g1;
- (id)initWithGeometry:(OTSGeometry *)g0 
		   andGeometry:(OTSGeometry *)g1 
				  with:(OTSBoundaryNodeRule *)boundaryNodeRule;
- (OTSIntersectionMatrix *)getIntersectionMatrix;

@end
