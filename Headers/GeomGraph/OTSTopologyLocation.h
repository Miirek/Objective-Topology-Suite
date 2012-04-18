//
//  OTSTopologyLocation.h
//

#import <Foundation/Foundation.h>

@interface OTSTopologyLocation : NSObject {
	NSMutableArray *locations;
}

@property (nonatomic, retain) NSMutableArray *locations;

- (id)initWithNewLocation:(NSArray *)newValue;
- (id)initWithOnPosition:(int)on 
			leftPosition:(int)left 
		   rightPosition:(int)right;
- (id)initWithOnLocation:(int)on;
- (id)initWithTopologyLocation:(OTSTopologyLocation *)gl;
- (int)getAt:(int)posIndex;
- (BOOL)isNull;
- (BOOL)isAnyNull;
- (BOOL)isEqualOnSide:(OTSTopologyLocation *)le onLocationIndex:(int)locIndex;
- (BOOL)isArea;
- (BOOL)isLine;
- (void)flip;
- (void)setAllLocationsWith:(int)locValue;
- (void)setAllLocationsIfNullWith:(int)locValue;
- (void)setAt:(int)posIndex withLocation:(int)locValue;
- (void)setLocation:(int)locValue;
- (void)setWithOnLocation:(int)on 
			 leftPosition:(int)left 
			rightPosition:(int)right;
- (BOOL)allPositionsEqualWith:(int)locValue;
- (void)mergeWith:(OTSTopologyLocation *)gl;

@end
