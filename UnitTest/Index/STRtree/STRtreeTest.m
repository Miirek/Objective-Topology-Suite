//
//  STRtreeTest.m
//  OTS
//
//  Created by Purbo Mohamad on 3/8/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "STRtreeTest.h"
#import "OTSEnvelope.h"
#import "OTSSTRtree.h"

@implementation STRtreeTest

- (void)testSTRtree {
	
	OTSSTRtree *rtree = [[OTSSTRtree alloc] init];
	[rtree insert:@"0Zero" havingEnvelope:[OTSEnvelope envelopeWithFirstX:0.0 secondX:0.1 firstY:0.0 secondY:0.1]];
	[rtree insert:@"1Two" havingEnvelope:[OTSEnvelope envelopeWithFirstX:0.2 secondX:0.3 firstY:0.2 secondY:0.3]];
	[rtree insert:@"2Four" havingEnvelope:[OTSEnvelope envelopeWithFirstX:0.4 secondX:0.5 firstY:0.4 secondY:0.5]];
	[rtree insert:@"3Six" havingEnvelope:[OTSEnvelope envelopeWithFirstX:0.6 secondX:0.7 firstY:0.6 secondY:0.7]];
	[rtree insert:@"4Eight" havingEnvelope:[OTSEnvelope envelopeWithFirstX:0.8 secondX:0.9 firstY:0.8 secondY:0.9]];
	[rtree insert:@"5Ten" havingEnvelope:[OTSEnvelope envelopeWithFirstX:1.0 secondX:1.1 firstY:1.0 secondY:1.1]];
	[rtree insert:@"6Twelve" havingEnvelope:[OTSEnvelope envelopeWithFirstX:1.2 secondX:1.3 firstY:1.2 secondY:1.3]];
	[rtree insert:@"7Fourteen" havingEnvelope:[OTSEnvelope envelopeWithFirstX:1.4 secondX:1.5 firstY:1.4 secondY:1.5]];
	[rtree insert:@"8Sixteen" havingEnvelope:[OTSEnvelope envelopeWithFirstX:1.6 secondX:1.7 firstY:1.6 secondY:1.7]];
	[rtree insert:@"9Eighteen" havingEnvelope:[OTSEnvelope envelopeWithFirstX:1.8 secondX:1.9 firstY:1.8 secondY:1.9]];
	[rtree insert:@"10Twenty" havingEnvelope:[OTSEnvelope envelopeWithFirstX:2.0 secondX:2.1 firstY:2.0 secondY:2.1]];
	[rtree insert:@"11TwentyTwo" havingEnvelope:[OTSEnvelope envelopeWithFirstX:2.2 secondX:2.3 firstY:2.2 secondY:2.3]];
	[rtree insert:@"12TwentyFour" havingEnvelope:[OTSEnvelope envelopeWithFirstX:2.4 secondX:2.5 firstY:2.4 secondY:2.5]];
	
	NSMutableArray *result1 = [NSMutableArray array];
	[rtree query:[OTSEnvelope envelopeWithFirstX:0.7 secondX:1.4 firstY:0.7 secondY:1.4] into:result1];
	
	NSUInteger numResult = 5;
	STAssertEquals([result1 count], numResult, @"Expecting 5 results but got: %d instead", [result1 count]); 
	/*
	for (int i = 0; i < [result1 count]; i++) {
		NSLog(@"%@", [result1 objectAtIndex:i]);
	}
	*/
	 
	[rtree release];
}


@end
