//
//  OTSMultiLineString.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryCollection.h" // for inheritance
#import "OTSDimension.h"

@class OTSCoordinate;
@class OTSCoordinateSequence;

@interface OTSMultiLineString : OTSGeometryCollection {

}

- (id)initWithMultiLineString:(OTSMultiLineString *)mls;
- (id)initWithArray:(NSArray *)_geometries factory:(OTSGeometryFactory *)newFactory;
- (BOOL)isClosed;

@end
