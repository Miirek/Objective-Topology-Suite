//
//  OTSElevationMatrix.m
//

#import "OTSElevationMatrix.h"

#import "OTSGeometry.h"
#import "OTSCoordinate.h"
#import "OTSCoordinateSequence.h"

@implementation OTSElevationMatrixFilter

@synthesize em;
@synthesize avgElevation;

- (void)dealloc {
	[em release];
	[super dealloc];
}

- (void)filter_rw:(OTSCoordinate *)coord {
	
	// already has a Z value, nothing to do
	if (!isnan(coord.z)) return;
	
	double _avgElevation = [em getAvgElevation];
	
	@try {
		OTSElevationMatrixCell *emc = [em getCell:coord];
		coord.z = [emc getAvg];
		if (isnan(coord.z)) coord.z = _avgElevation;
	}
	@catch (NSException * e) {
		coord.z = _avgElevation;
	}
	
}

- (void)filter_ro:(OTSCoordinate *)coord {
	[em addCoordinate:coord];
}

@end


@implementation OTSElevationMatrix

@synthesize filter;
@synthesize env;
@synthesize cols;
@synthesize rows;
@synthesize cellwidth;
@synthesize cellheight;
@synthesize avgElevationComputed;
@synthesize avgElevation;
@synthesize cells;

- (id)initWithEnvelope:(OTSEnvelope *)extent rows:(int)_rows cols:(int)_cols {
	if (self = [super init]) {
		filter = [[OTSElevationMatrixFilter alloc] init];
		filter.em = self;
		self.env = extent;
		cols = _cols;
		rows = _rows;
		avgElevationComputed = NO;
		avgElevation = NAN;
		self.cells = [NSMutableArray arrayWithCapacity:_rows*_cols];
		for (int i = 0; i < _rows*_cols; i++) {
			[cells addObject:[NSNull null]];
		}
		
		cellwidth = [env width]/cols;
		cellheight = [env height]/rows;
		if (!cellwidth) cols = 1;
		if (!cellheight) rows = 1;
	}
	return self;
}

- (void)dealloc {
	[filter release];
	[env release];
	[cells release];
	[super dealloc];
}

- (void)add:(OTSGeometry *)geom {
	NSAssert(!avgElevationComputed, @"Cannot add Geometries to an ElevationMatrix after it's average elevation has been computed");
	[geom apply_roCoordinateFilter:filter];
}

- (void)elevate:(OTSGeometry *)geom {
	if (isnan(avgElevation)) return;	
	[geom apply_rwCoordinateFilter:filter];
}

- (double)getAvgElevation {
	if (avgElevationComputed) return avgElevation;
	double ztot = 0;
	int zvals = 0;
	for (int r = 0;  r < rows; r++) {
		for(int c = 0; c < cols; c++) {
			int celloffset = (r*cols)+c;
			id rawcell = [cells objectAtIndex:celloffset];
			OTSElevationMatrixCell *cell = nil;
			if (rawcell == [NSNull null]) {
				cell = [[OTSElevationMatrixCell alloc] init];
				[cells replaceObjectAtIndex:celloffset withObject:cell];
			} else {
				cell = (OTSElevationMatrixCell *)rawcell;
			}
			double e = [cell getAvg];
			if (!isnan(e)) {
				zvals++;
				ztot+=e;
			}
		}
	}
	if (zvals) avgElevation = ztot/zvals;
	else avgElevation = NAN;
	
	avgElevationComputed = true;
	
	return avgElevation;
}

- (OTSElevationMatrixCell *)getCell:(OTSCoordinate *)c {
	
	int col, row;
	
	if (!cellwidth) col = 0;
	else {
		double xoffset = c.x - env.minx;
		col = (int)(xoffset/cellwidth);
		if (col == (int)cols) col = cols - 1;
	}
	if (!cellheight) row = 0;
	else {
		double yoffset = c.y - env.miny;
		row = (int)(yoffset/cellheight);
		if ( row == (int)rows ) row = rows-1;
	}
	int celloffset = (cols*row) + col;
	
	if  (celloffset < 0 || celloffset >= (int)(cols*rows)) {
		NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" 
												  reason:@"getCell got a Coordinate out of grid extent" 
												userInfo:nil];
		@throw ex;
	}
	
	OTSElevationMatrixCell *ret = nil;
	id rawcell = [cells objectAtIndex:celloffset];
	if (rawcell == [NSNull null]) {
		ret = [[OTSElevationMatrixCell alloc] init];
		[cells replaceObjectAtIndex:celloffset withObject:ret];
	} else {
		ret = (OTSElevationMatrixCell *)rawcell;
	}
	return ret;
}

- (void)addCoordinateSequence:(OTSCoordinateSequence *)cs {
	int ncoords = [cs size];
	for (int i = 0; i < ncoords; i++) {
		[self addCoordinate:[cs getAt:i]];
	}	
}

- (void)addCoordinate:(OTSCoordinate *)c {
	if (isnan(c.z)) return;
	@try {
		OTSElevationMatrixCell *emc = [self getCell:c];
		[emc add:c];
	}
	@catch (NSException * e) {
		NSLog(@"Error: coordinate does not overlap grid extent");
		return;
	}
}

@end
