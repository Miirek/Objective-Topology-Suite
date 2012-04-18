//
//  OTSLinearComponentExtractor.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryComponentFilter.h"

@class OTSGeometry;

@interface OTSLinearComponentExtractor : OTSGeometryComponentFilter {
	NSMutableArray *comps; // array of line strings
}

@property (nonatomic, retain) NSMutableArray *comps;

+ (void)getLinesFromGeometry:(OTSGeometry *)geom into:(NSMutableArray *)ret;
- (id)initWithArray:(NSMutableArray *)newComps;

@end
