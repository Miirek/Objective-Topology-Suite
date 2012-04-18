//
//  OTSAbstractSTRtree.h
//

#import <Foundation/Foundation.h>

#import "OTSItemVisitor.h"
#import "OTSAbstractNode.h" // for inlines

@protocol OTSIntersectsOp

- (BOOL)intersects:(id)aBounds andBound:(id)bBounds;

@end

@interface OTSAbstractSTRtree : NSObject {
	BOOL built;
	NSMutableArray *itemBoundables;
	OTSAbstractNode *root;
	NSMutableArray *nodes;
	int nodeCapacity;
}

@property (nonatomic, assign) BOOL built;
@property (nonatomic, assign) int nodeCapacity;

- (id)initWithCapacity:(int)newNodeCapacity;

- (OTSAbstractNode *)createHigherLevelsFromBoundables:(NSArray *)boundables ofALevel:(int)level;
- (NSArray *)sortBoundables:(NSArray *)input;
- (BOOL)removeInSearchBounds:(id)searchBounds node:(OTSAbstractNode *)node item:(id)item;
- (BOOL)removeItem:(OTSAbstractNode *)node item:(id)item;
- (NSArray *)itemsTreeFrom:(OTSAbstractNode *)node;
- (OTSAbstractNode *)createNode:(int)level;
- (NSArray *)createParentBoundables:(NSArray *)childBoundables level:(int)newLevel;
- (OTSAbstractNode *)lastNode:(NSArray *)nodes;
- (OTSAbstractNode *)getRoot;
- (void)insert:(id)bounds item:(id)item;
- (void)query:(id)searchBounds outputInto:(NSMutableArray *)foundItems;
- (void)query:(id)searchBounds usingVisitor:(id <OTSItemVisitor>)visitor;
- (void)query:(id)searchBounds node:(OTSAbstractNode *)node usingVisitor:(id <OTSItemVisitor>)visitor;
- (BOOL)remove:(id)searchBounds item:(id)item;
- (NSArray *)boundablesAtLevel:(int)level;
- (id <NSObject, OTSIntersectsOp>)getIntersectsOp;

+ (BOOL)compareDouble:(double)a andDouble:(double)b;

- (void)build;
- (void)query:(id)searchBounds node:(OTSAbstractNode *)node outputInto:(NSMutableArray *)matches;
- (void)iterate:(id <OTSItemVisitor>)visitor;
- (void)boundablesAtLevel:(int)level top:(OTSAbstractNode *)top boundables:(NSMutableArray *)boundables;
- (NSArray *)itemsTree;

@end
