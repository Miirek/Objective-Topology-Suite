//
//  OTSNode.h
//

#import <Foundation/Foundation.h>

#import "OTSGraphComponent.h" // for inheritance
#import "OTSCoordinate.h" // for member

@class OTSIntersectionMatrix;
@class OTSNode;
@class OTSEdgeEndStar;
@class OTSEdgeEnd;
@class OTSLabel;
@class OTSNodeFactory;

@interface OTSNode : OTSGraphComponent {
	OTSEdgeEndStar *edges;
	OTSCoordinate *coord;
	NSMutableArray *zvals;	
	double ztot;
}

@property (nonatomic, retain) OTSEdgeEndStar* edges;
@property (nonatomic, retain) OTSCoordinate *coord;
@property (nonatomic, retain) NSMutableArray *zvals;	
@property (nonatomic, assign) double ztot;

- (id)initWithCoordinate:(OTSCoordinate *)newCoord edges:(OTSEdgeEndStar *)newEdges;
- (OTSCoordinate *)getCoordinate;
- (void)add:(OTSEdgeEnd *)e;
- (void)mergeLabelWithNode:(OTSNode *)n;
- (void)mergeLabel:(OTSLabel *)label2;
- (void)setLabel:(int)argIndex onLocation:(int)onLocation;
- (void)setLabelBoundary:(int)argIndex;
- (int)computeMergedLocation:(OTSLabel *)label2 eltIndex:(int)eltIndex;
- (NSArray *)getZ;
- (void)addZ:(double)z;
- (BOOL)isIncidentEdgeInResult;
- (void)computeIM:(OTSIntersectionMatrix *)im;

@end
