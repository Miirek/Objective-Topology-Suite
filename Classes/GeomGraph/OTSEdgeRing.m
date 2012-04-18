//
//  OTSEdgeRing.m
//

#import "OTSCGAlgorithms.h"
#import "OTSEdgeRing.h"
#import "OTSDirectedEdge.h"
#import "OTSDirectedEdgeStar.h"
#import "OTSEdge.h"
#import "OTSNode.h"
#import "OTSLabel.h"
#import "OTSPosition.h"
#import "OTSCoordinateSequenceFactory.h"
#import "OTSCoordinateSequence.h"
#import "OTSGeometryFactory.h"
#import "OTSLinearRing.h"
#import "OTSLocation.h"
#import "OTSEnvelope.h"

@implementation OTSEdgeRing

@synthesize startDe;
@synthesize geometryFactory;
@synthesize holes;
@synthesize edges;
@synthesize pts;
@synthesize label;
@synthesize ring;
@synthesize shell;
@synthesize isHoleVar;	
@synthesize maxNodeDegree;

- (id)initWithEdgeEnd:(OTSDirectedEdge *)newStart geometryFactory:(OTSGeometryFactory *)newGeometryFactory {
	if (self = [super init]) {
		self.startDe = newStart;
		self.geometryFactory = newGeometryFactory;
		self.holes = [NSMutableArray array];
		maxNodeDegree = -1;
		self.edges = [NSMutableArray array];
		pts = [newGeometryFactory.coordinateSequenceFactory createWithArray:nil];
		label = [[OTSLabel alloc] initWithOnLocation:kOTSLocationUndefined];
		ring = nil;
		isHoleVar = NO;
		shell = nil;
	}
	return self;	
}

- (void)dealloc {
	[startDe release];
	[geometryFactory release];
	[holes release];
	[edges release];
	[pts release];
	[label release];
	[ring release];
	[shell release];
	[super dealloc];
}

- (BOOL)isIsolated {
	return ([label geometryCount] == 1);
}

- (BOOL)isHole {
	return isHoleVar;
}

- (OTSLinearRing *)getLinearRing {
	return ring;
}

- (BOOL)isShell {
	return (shell == nil);
}

- (void)addHole:(OTSEdgeRing *)edgeRing {
	[holes addObject:edgeRing];
}

- (OTSPolygon *)toPolygon:(OTSGeometryFactory *)_geometryFactory {
	int nholes = [holes count];
	NSMutableArray *holeLR = [NSMutableArray arrayWithCapacity:nholes];
	for (int i = 0; i < nholes; ++i) {
		OTSEdgeRing *er = [holes objectAtIndex:i];
		OTSGeometry *hole = [[er getLinearRing] clone];
		[holeLR addObject:hole];
	}
	
	// We don't use "clone" here because
	// GeometryFactory::createPolygon really
	// wants a LinearRing
	//
	OTSLinearRing *shellLR = [[OTSLinearRing alloc] initWithLinearRing:ring];
	OTSPolygon *ret = [_geometryFactory createPolygonWithShell:shellLR holes:holeLR];
	[shellLR release];
	return ret;
}

- (void)computeRing {
	if (ring != nil) return;   // don't compute more than once
	ring = [geometryFactory createLinearRingWithCoordinateSequence:pts];
	isHoleVar = [OTSCGAlgorithms isCCW:pts];
}

- (OTSDirectedEdge *)getNext:(OTSDirectedEdge *)de {
	// abstract
	return nil;
}

- (void)setEdgeRing:(OTSDirectedEdge *)de edgeRing:(OTSEdgeRing *)er {
	// abstract
}

- (int)getMaxNodeDegree {
	if (maxNodeDegree < 0) [self computeMaxNodeDegree];
	return maxNodeDegree;
}

- (void)setInResult {
	OTSDirectedEdge *de = startDe;
	do {
		[de.edge setInResult:YES];
		de = de.next;
	} while (de != startDe);	
}

- (BOOL)containsPoint:(OTSCoordinate *)p {
	
	OTSEnvelope *env = [ring getEnvelopeInternal];
	
	if (![env containsCoordinate:p]) return NO;
	
	if (![OTSCGAlgorithms isPoint:p inRing:[ring getCoordinatesRO]])
		return NO;
	
	for (OTSEdgeRing *hole in holes) {
		if ([hole containsPoint:p]) {
			return NO;
		}
	}
	
	return YES;
	
}

- (void)computePoints:(OTSDirectedEdge *)newStart {
	
	self.startDe = newStart;
	OTSDirectedEdge *de = newStart;
	BOOL isFirstEdge = YES;
	do {
		if (de == nil) {
			NSException *ex = [NSException exceptionWithName:@"TopologyException" 
													  reason:@"EdgeRing::computePoints: found null Directed Edge" 
													userInfo:nil];
			@throw ex;
		}
		if (de.edgeRing == self) {
			NSException *ex = [NSException exceptionWithName:@"TopologyException" 
													  reason:@"Directed Edge visited twice during ring-building" 
													userInfo:nil];
			@throw ex;
		}
		[edges addObject:de];
		OTSLabel *deLabel = de.label;
		[self mergeLabel:deLabel];
		[self addPoints:de.edge isForward:de.forward isFirstEdge:isFirstEdge];
		isFirstEdge = NO;
		[self setEdgeRing:de edgeRing:self];
		de = [self getNext:de];		
	} while (de != startDe);
	
}

- (void)mergeLabel:(OTSLabel *)deLabel {
	[self mergeLabel:deLabel geomIndex:0];
	[self mergeLabel:deLabel geomIndex:1];
}

- (void)mergeLabel:(OTSLabel *)deLabel geomIndex:(int)geomIndex {
	int loc = [deLabel locationAtGeometryIndex:geomIndex atPosIndex:kOTSPositionRight];
	// no information to be had from this label
	if (loc == kOTSLocationUndefined) return;
	
	// if there is no current RHS value, set it
	if ([label locationAtGeometryIndex:geomIndex] == kOTSLocationUndefined) {
		[label setLocation:loc atGeometryIndex:geomIndex];
		return;
	}	
}

- (void)addPoints:(OTSEdge *)edge isForward:(BOOL)isForward isFirstEdge:(BOOL)isFirstEdge {
	
	OTSCoordinateSequence *edgePts = [edge getCoordinates];
	
	int numEdgePts = [edgePts size];
	
	if (isForward) {
		int startIndex = 1;
		if (isFirstEdge) startIndex = 0;
		for (int i = startIndex; i < numEdgePts; ++i) {
			[pts add:[edgePts getAt:i]];
		}
	} else { // is backward
		int startIndex = numEdgePts - 1;
		if (isFirstEdge) startIndex = numEdgePts;
		for (int i = startIndex; i > 0; --i) {
			[pts add:[edgePts getAt:i - 1]];
		}
	}
	
}

- (void)computeMaxNodeDegree {
	
	maxNodeDegree = 0;
	OTSDirectedEdge *de = startDe;
	do {
		OTSNode *node = de.node;
		OTSEdgeEndStar* ees = node.edges;
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)ees;
		int degree = [des getOutgoingDegreeOf:self];		
		if (degree > maxNodeDegree) maxNodeDegree = degree;
		de = [self getNext:de];
	} while (de != startDe);
	maxNodeDegree *= 2;
	
}

@end
