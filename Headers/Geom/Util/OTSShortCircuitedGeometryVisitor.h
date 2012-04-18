//
//  OTSShortCircuitedGeometryVisitor.h
//

#import <Foundation/Foundation.h>

@class OTSGeometry;

@interface OTSShortCircuitedGeometryVisitor : NSObject {
	BOOL done;
}

@property (nonatomic, assign) BOOL done;

- (BOOL)isDone;
- (void)visit:(OTSGeometry *)element;
- (void)applyTo:(OTSGeometry *)geom;


@end
