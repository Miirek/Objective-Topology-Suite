//
//  OTSGeometryList.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometry.h" // for auto_ptr

@interface OTSGeometryList : NSObject {
	NSMutableArray *geoms;
}

@property (nonatomic, retain) NSMutableArray *geoms;

+ (OTSGeometryList *)create;
- (void)add:(OTSGeometry *)geom;
- (int)size;
- (OTSGeometry *)getAt:(int)i;

@end
