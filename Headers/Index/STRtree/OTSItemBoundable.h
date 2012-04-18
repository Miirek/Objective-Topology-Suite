//
//  OTSItemBoundable.h
//

#import <Foundation/Foundation.h>

#import "OTSBoundable.h"

@interface OTSItemBoundable : NSObject <OTSBoundable> {
	id bounds;
	id item;
}

- (id)initWithBounds:(id)newBounds item:(id)newItem;
- (id)getItem;

@end
