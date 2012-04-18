//
//  OTSGeometryComponentFilter.h
//

#import <Foundation/Foundation.h>

@class OTSGeometry;

@interface OTSGeometryComponentFilter : NSObject {

}

- (void)filter_rw:(OTSGeometry *)geom;
- (void)filter_ro:(OTSGeometry *)geom;

@end
