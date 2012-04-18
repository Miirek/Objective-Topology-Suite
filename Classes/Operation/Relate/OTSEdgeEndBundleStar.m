//
//  OTSEdgeEndBundleStar.m
//

#import "OTSEdgeEndBundleStar.h"
#import "OTSEdgeEndBundle.h"

@implementation OTSEdgeEndBundleStar

- (void)insert:(OTSEdgeEnd *)e {
	
	int found = [self find:e];
	OTSEdgeEndBundle *eb;
	if (found == -1) {
		eb = [[OTSEdgeEndBundle alloc] initWithEdgeEnd:e];
		[edgeMap addObject:eb];
		[eb release];
	} else {
		eb = (OTSEdgeEndBundle *)[edgeMap objectAtIndex:found];
		[eb insert:e];
	}
	
}

- (void)updateIM:(OTSIntersectionMatrix *)im {	
	for (OTSEdgeEndBundle *esb in edgeMap) {
		[esb updateIM:im];
	}
}

@end
