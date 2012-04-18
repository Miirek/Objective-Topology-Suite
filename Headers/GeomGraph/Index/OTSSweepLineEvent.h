//
//  OTSSweepLineEvent.h
//

#import <Foundation/Foundation.h>

@class OTSSweepLineEventOBJ;

enum {
	kOTSSweepLineInsertEvent = 1,
	kOTSSweepLineDeleteEvent
};

@interface OTSSweepLineEvent : NSObject {
	id edgeSet;    // used for red-blue intersection detection
	OTSSweepLineEventOBJ *object;
	double x;
	int eventType;
	OTSSweepLineEvent *insertEvent; // null if this is an INSERT_EVENT event
	int deleteEventIndex;	
}

@property (nonatomic, retain) id edgeSet;
@property (nonatomic, retain) OTSSweepLineEventOBJ *object;
@property (nonatomic, assign) double x;
@property (nonatomic, assign) int eventType;
@property (nonatomic, retain) OTSSweepLineEvent *insertEvent;
@property (nonatomic, assign) int deleteEventIndex;	

- (id)initWithEdgeSet:(id)newEdgeSet 
					x:(double)_x 
		  insertEvent:(OTSSweepLineEvent *)newInsertEvent 
			   object:(OTSSweepLineEventOBJ *)newObj;
- (BOOL)isInsert;
- (BOOL)isDelete;
- (int)compareTo:(OTSSweepLineEvent *)sle;
- (NSComparisonResult)compareForNSComparisonResult:(OTSSweepLineEvent *)other;
+ (BOOL)sweepLineEvent:(OTSSweepLineEvent *)f lessThan:(OTSSweepLineEvent *)s;

@end
