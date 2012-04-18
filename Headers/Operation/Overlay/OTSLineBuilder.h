//
//  OTSLineBuilder.h
//

#import <Foundation/Foundation.h>

#import "OTSOverlayOp.h" // for OverlayOp::OpCode enum 

@class OTSGeometryFactory;
@class OTSCoordinateSequence;
@class OTSLineString;
@class OTSDirectedEdge;
@class OTSEdge;
@class OTSPointLocator;
@class OTSOverlayOp;

@interface OTSLineBuilder : NSObject {
	OTSOverlayOp *op;
	OTSGeometryFactory *geometryFactory;
	OTSPointLocator *ptLocator;
	NSMutableArray *lineEdgesList;
	NSMutableArray* resultLineList;	
}

@property (nonatomic, retain) OTSOverlayOp *op;
@property (nonatomic, retain) OTSGeometryFactory *geometryFactory;
@property (nonatomic, retain) OTSPointLocator *ptLocator;
@property (nonatomic, retain) NSMutableArray *lineEdgesList;
@property (nonatomic, retain) NSMutableArray* resultLineList;	

- (id)initWithOverlayOp:(OTSOverlayOp *)newOp 
		geometryFactory:(OTSGeometryFactory *)newGeometryFactory 
			  ptLocator:(OTSPointLocator *)newPtLocator;
- (NSMutableArray *)build:(OTSOverlayOpCode)opCode;
- (void)collectLineEdge:(OTSDirectedEdge *)de 
				 opCode:(OTSOverlayOpCode)opCode 
				  edges:(NSMutableArray *)edges;
- (void)findCoveredLineEdges;
- (void)collectLines:(OTSOverlayOpCode)opCode;
- (void)buildLines:(OTSOverlayOpCode)opCode;
- (void)labelIsolatedLines:(NSMutableArray *)edgesList;
- (void)collectBoundaryTouchEdge:(OTSDirectedEdge *)de 
						  opCode:(OTSOverlayOpCode)opCode 
						   edges:(NSMutableArray *)edges;
- (void)labelIsolatedLine:(OTSEdge *)e targetIndex:(int)targetIndex;
- (void)propagateZ:(OTSCoordinateSequence *)cs;

@end
