//
//  OTSLineBuilder.m
//

#import "OTSLineBuilder.h"
#import "OTSOverlayOp.h"
#import "OTSPointLocator.h"
#import "OTSGeometryFactory.h"
#import "OTSNode.h"
#import "OTSEdge.h"
#import "OTSDirectedEdge.h"
#import "OTSDirectedEdgeStar.h"

@implementation OTSLineBuilder

@synthesize op;
@synthesize geometryFactory;
@synthesize ptLocator;
@synthesize lineEdgesList;
@synthesize resultLineList;	

- (id)initWithOverlayOp:(OTSOverlayOp *)newOp 
		geometryFactory:(OTSGeometryFactory *)newGeometryFactory 
			  ptLocator:(OTSPointLocator *)newPtLocator {
	if (self = [super init]) {
		self.op = newOp;
		self.geometryFactory = newGeometryFactory;
		self.ptLocator = newPtLocator;		
		self.lineEdgesList = [NSMutableArray array];
		self.resultLineList = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc {
	[op release];
	[geometryFactory release];
	[ptLocator release];
	[lineEdgesList release];
	[resultLineList release];
	[super dealloc];
}

- (NSMutableArray *)build:(OTSOverlayOpCode)opCode {
	[self findCoveredLineEdges];
	[self collectLines:opCode];
	[self buildLines:opCode];
	return resultLineList;
	
}

- (void)collectLineEdge:(OTSDirectedEdge *)de 
				 opCode:(OTSOverlayOpCode)opCode 
				  edges:(NSMutableArray *)edges {
	
	OTSLabel *label = de.label;
	OTSEdge *e = de.edge;
	// include L edges which are in the result
	if ([de isLineEdge]) {
		if (!de.visited && [OTSOverlayOp isResultOfOp:label opCode:opCode] && ![e isCovered]) {
			[edges addObject:e];
			[de setVisitedEdge:YES];
		}
	}
	
}

- (void)findCoveredLineEdges {
	
	// first set covered for all L edges at nodes which have A edges too
	NSMutableArray *nodes = [NSMutableArray array];
	[[op.graph getNodeMap] getNodesAsArray:nodes];
	for (OTSNode *node in nodes) {
		NSAssert([node.edges isKindOfClass:[OTSDirectedEdgeStar class]], @"Expecting OTSDirectedEdgeStar class");
		OTSDirectedEdgeStar *des = (OTSDirectedEdgeStar *)node.edges;
		[des findCoveredLineEdges];
	}
	
	/*
	 * For all L edges which weren't handled by the above,
	 * use a point-in-poly test to determine whether they are covered
	 */
	NSArray *ee = [op.graph getEdgeEnds];
	for (OTSDirectedEdge *de in ee) {
		OTSEdge *e = de.edge;
		if ([de isLineEdge] && ![e isCoveredSet]) {
			[e setCovered:[op isCoveredByA:[de getCoordinate]]];
		}
	}

}

- (void)collectLines:(OTSOverlayOpCode)opCode {
	
	NSArray *ee = [op.graph getEdgeEnds];
	int bubu = 0;
	for (OTSDirectedEdge *de in ee) {
		//if (bubu == 8)
			//NSLog(@"bubu = %d", bubu);
		[self collectLineEdge:de opCode:opCode edges:lineEdgesList];
		[self collectBoundaryTouchEdge:de opCode:opCode edges:lineEdgesList];
		bubu++;
	}
	
}

- (void)buildLines:(OTSOverlayOpCode)opCode {
	
	for (OTSEdge *e in lineEdgesList) {
		
		OTSCoordinateSequence *cs = [[e getCoordinates] clone];
//#if COMPUTE_Z
//		[self propagateZ:cs];
//#endif
		OTSLineString *line = [geometryFactory createLineStringWithCoordinateSequence:cs];
		[resultLineList addObject:line];
		[e setInResult:YES];
	}
	
}

- (void)labelIsolatedLines:(NSMutableArray *)edgesList {
	for (OTSEdge *e in edgesList) {
		OTSLabel *label = e.label;
		if (e.isolated) {
			if ([label isNullAtGeometryIndex:0])
				[self labelIsolatedLine:e targetIndex:0];
			else
				[self labelIsolatedLine:e targetIndex:1];
		}
	}
}

- (void)collectBoundaryTouchEdge:(OTSDirectedEdge *)de 
						  opCode:(OTSOverlayOpCode)opCode 
						   edges:(NSMutableArray *)edges {
	
	if ([de isLineEdge]) return;  // only interested in area edges
	if (de.visited) return;  // already processed
	
	// added to handle dimensional collapses
	if ([de isInteriorAreaEdge]) return;
	
	// if the edge linework is already included, don't include it again
	if (de.edge.inResult) return; 
	
	// sanity check for labelling of result edgerings
	NSAssert( ! ( de.inResult || de.sym.inResult )
		   ||
		   ! de.edge.inResult , @"labelling of result edgerings is insane");
		
	// include the linework if it's in the result of the operation
	OTSLabel *label = de.label;
	if ([OTSOverlayOp isResultOfOp:label opCode:opCode] 
		&& opCode == kOTSOverlayIntersection ) {
		[edges addObject:de.edge];
		[de setVisitedEdge:YES];
	}
	
}

- (void)labelIsolatedLine:(OTSEdge *)e targetIndex:(int)targetIndex {
	int loc = [ptLocator locate:[e getCoordinate] relativeTo:[op getArgGeometry:targetIndex]];
	[e.label setLocation:loc atGeometryIndex:targetIndex];	
}

- (void)propagateZ:(OTSCoordinateSequence *)cs {
//	
//	size_t i;
//	
//	vector<int>v3d; // vertex 3d
//	size_t cssize = cs->getSize();
//	for (i=0; i<cssize; i++)
//	{
//		if ( !ISNAN(cs->getAt(i).z) ) v3d.push_back(i);
//	}
//		
//	if ( v3d.size() == 0 )
//	{
//		return;
//	}
//	
//	Coordinate buf;
//	
//	// fill initial part
//	if ( v3d[0] != 0 )
//	{
//		double z = cs->getAt(v3d[0]).z;
//		for (int j=0; j<v3d[0]; j++)
//		{
//			buf = cs->getAt(j);
//			buf.z = z;
//			cs->setAt(buf, j);
//		}
//	}
//	
//	// interpolate inbetweens
//	size_t prev=v3d[0];
//	for (i=1; i<v3d.size(); i++)
//	{
//		int curr=v3d[i];
//		int dist = curr-prev;
//		if (dist > 1)
//		{
//			const Coordinate &cto = cs->getAt(curr);
//			const Coordinate &cfrom = cs->getAt(prev);
//			double gap = cto.z-cfrom.z;
//			double zstep = gap/dist;
//			double z = cfrom.z;
//			for (int j=prev+1; j<curr; j++)
//			{
//				buf = cs->getAt(j);
//				z+=zstep;
//				buf.z = z;
//				cs->setAt(buf, j);
//			}
//		}
//		prev = curr;
//	}
//	
//	// fill final part
//	if ( prev < cssize-1 )
//	{
//		double z = cs->getAt(prev).z;
//		for (size_t j=prev+1; j<cssize; j++)
//		{
//			buf = cs->getAt(j);
//			buf.z = z;
//			cs->setAt(buf, j);
//		}
//	}
//	
}

@end
