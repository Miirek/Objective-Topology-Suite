//
//  OTSLineStringSnapper.m
//

#import "OTSLineStringSnapper.h"
#import "OTSCoordinateSequence.h"
#import "OTSCoordinate.h"
#import "OTSLineSegment.h"

@implementation OTSLineStringSnapper

@synthesize srcPts;
@synthesize snapTolerance;	
@synthesize closed;

- (id)initWithCoordinates:(NSArray *)nSrcPts snapTolerance:(double)nSnapTol {
	if (self = [super init]) {
		self.srcPts = nSrcPts;
		snapTolerance = nSnapTol;		
		OTSCoordinate *ptAt0 = [srcPts objectAtIndex:0];
		OTSCoordinate *ptAtN = [srcPts lastObject];		
		closed = ( [srcPts count] < 2 || [ptAt0 isEqual2D:ptAtN] );		
	}
	return self;
}

- (void)dealloc {
	[srcPts release];
	[super dealloc];
}

- (NSArray *)snapTo:(NSArray *)snapPts {
	NSMutableArray *coordList = [NSMutableArray arrayWithArray:srcPts];
	[self snapVertices:coordList snapPts:snapPts];
	[self snapSegments:coordList snapPts:snapPts];
	return coordList;
}

- (void)snapVertices:(NSMutableArray *)srcCoords snapPts:(NSArray *)snapPts {

	// try snapping vertices
	// assume src list has a closing point (is a ring)
	for (int i = 0, n = [srcCoords count]; i < n; ++i) {
		OTSCoordinate *srcPt = [srcCoords objectAtIndex:i];
		int found = [self findSnapForVertex:srcPt snapPts:snapPts];
		if (found == -1) {
			// no snaps found (or no need to snap)
			continue;
		}
		
		OTSCoordinate *snapPt = [snapPts objectAtIndex:found];
		
		// update src with snap pt
		[srcCoords replaceObjectAtIndex:i withObject:snapPt];
		
		// keep final closing point in synch (rings only)
		if (i == n - 1 && closed) {
			[srcCoords replaceObjectAtIndex:n - 2 withObject:snapPt];
		}
	}
	
}

- (int)findSnapForVertex:(OTSCoordinate *)pt snapPts:(NSArray *)snapPts {
	
	for (int i = 0, n = [snapPts count]; i < n; ++i) {
		OTSCoordinate *snapPt = [snapPts objectAtIndex:i];
		if ([snapPt isEqual2D:pt]) {
			return -1;
		}
		double dist = [snapPt distance:pt];
		if (dist < snapTolerance) {
			return i;
		}
	}
	return -1;
	
}

- (void)snapSegments:(NSMutableArray *)srcCoords snapPts:(NSArray *)snapPts {
	
	for (int i = 0, n = [snapPts count]; i < n; ++i) {
		OTSCoordinate *snapPt = [snapPts objectAtIndex:i];
		
		int segpos = [self findSegmentToSnap:snapPt coords:srcCoords];
		if (segpos == -1) {
			continue;
		}
		
		// insert must happen one-past first point (before next point)
		++segpos;
		[srcCoords insertObject:snapPt atIndex:segpos];
	}
	
}

- (int)findSegmentToSnap:(OTSCoordinate *)snapPt coords:(NSArray *)coords {
	
	double minDist = snapTolerance + 1; // make sure the first closer then
	int match = -1;
	
	for (int i = 0, n = [coords count] - 1; i < n; ++i) {
		OTSLineSegment *seg = [[OTSLineSegment alloc] initWithCoordinate:[coords objectAtIndex:i] toCoordinate:[coords objectAtIndex:i + 1]];		
		if ([seg.p0 isEqual2D:snapPt] || [seg.p1 isEqual2D:snapPt]) {
			// If the snap pt is already in the src list,
			// don't snap
      [seg release];
			return -1;
		}
		
		double dist = [seg distance:snapPt];
		if (dist < minDist && dist < snapTolerance) {
			match = i;
			minDist = dist;
		}		
		[seg release];
	}
	
	return match;
		
}

@end
