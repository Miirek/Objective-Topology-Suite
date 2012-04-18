//
//  OTSPointBuilder.h
//

#import <Foundation/Foundation.h>

#import "OTSGeometryFactory.h" // for inlines
#import "OTSOverlayOp.h" // for OpCode enum

@class OTSGeometryFactory;
@class OTSPoint;
@class OTSNode;
@class OTSPointLocator;
@class OTSOverlayOp;

@interface OTSPointBuilder : NSObject {
	OTSOverlayOp *op;
	OTSGeometryFactory *geometryFactory;
	OTSPointLocator *ptLocator;
	NSMutableArray *resultPointList;
}

@property (nonatomic, retain) OTSOverlayOp *op;
@property (nonatomic, retain) OTSGeometryFactory *geometryFactory;
@property (nonatomic, retain) OTSPointLocator *ptLocator;
@property (nonatomic, retain) NSMutableArray *resultPointList;

- (id)initWithOverlayOp:(OTSOverlayOp *)newOp 
		geometryFactory:(OTSGeometryFactory *)newGeometryFactory 
			  ptLocator:(OTSPointLocator *)newPtLocator;
- (void)extractNonCoveredResultNodes:(OTSOverlayOpCode)opCode;
- (void)filterCoveredNodeToPoint:(OTSNode *)node;
- (NSMutableArray *)build:(OTSOverlayOpCode)opCode;

@end
