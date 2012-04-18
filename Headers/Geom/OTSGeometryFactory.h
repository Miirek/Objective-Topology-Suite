//
//  OTSGeometryFactory.h
//

#import <Foundation/Foundation.h>

@class OTSCoordinateSequenceFactory;
@class OTSCoordinate;
@class OTSCoordinateSequence;
@class OTSEnvelope;
@class OTSGeometry;
@class OTSGeometryCollection;
@class OTSLineString;
@class OTSLinearRing;
@class OTSMultiLineString;
@class OTSMultiPoint;
@class OTSMultiPolygon;
@class OTSPoint;
@class OTSPolygon;
@class OTSPrecisionModel;

@interface OTSGeometryFactory : NSObject {
	OTSPrecisionModel *precisionModel;
	int SRID;
	OTSCoordinateSequenceFactory *coordinateSequenceFactory;	
}

@property (nonatomic, retain) OTSPrecisionModel *precisionModel;
@property (nonatomic, assign) int SRID;
@property (nonatomic, retain) OTSCoordinateSequenceFactory *coordinateSequenceFactory;	

- (id)initWithPrecisionModel:(OTSPrecisionModel *)pm SRID:(int)newSRID coordinateSequenceFactory:(OTSCoordinateSequenceFactory *)nCoordinateSequenceFactory;
- (id)initWithCoordinateSequenceFactory:(OTSCoordinateSequenceFactory *)nCoordinateSequenceFactory;
- (id)initWithPrecisionModel:(OTSPrecisionModel *)pm;
- (id)initWithPrecisionModel:(OTSPrecisionModel *)pm SRID:(int)newSRID;
- (id)initWithGeometryFactory:(OTSGeometryFactory *)gf;
+ (OTSGeometryFactory *)getDefaultInstance;

- (OTSPoint *)createPointWithInternalCoord:(OTSCoordinate *)coord exemplar:(OTSGeometry *)exemplar;
- (OTSGeometry *)toGeometry:(OTSEnvelope *)envelope;
- (OTSPoint *)createPoint;
- (OTSPoint *)createPointWithCoordinate:(OTSCoordinate *)coordinate;
- (OTSPoint *)createPointWithCoordinateSequence:(OTSCoordinateSequence *)coordinates;
- (OTSGeometryCollection *)createGeometryCollection;
- (OTSGeometry *)createEmptyGeometry;
- (OTSGeometryCollection *)createGeometryCollectionWithArray:(NSArray *)newGeoms;
- (OTSMultiLineString *)createMultiLineString;
- (OTSMultiLineString *)createMultiLineStringWithArray:(NSArray *)newLines;
- (OTSMultiPolygon *)createMultiPolygon;
- (OTSMultiPolygon *)createMultiPolygonWithArray:(NSArray *)newPolys;
- (OTSLinearRing *)createLinearRing;
- (OTSLinearRing *)createLinearRingWithCoordinateSequence:(OTSCoordinateSequence *)newCoords;
- (OTSMultiPoint *)createMultiPoint;
- (OTSMultiPoint *)createMultiPointWithArray:(NSArray *)newPolys;
- (OTSMultiPoint *)createMultiPointWithCoordinateSequence:(OTSCoordinateSequence *)newCoords;
- (OTSPolygon *)createPolygon;
- (OTSPolygon *)createPolygonWithShell:(OTSLinearRing *)shell holes:(NSArray *)holes;
- (OTSLineString *)createLineString;
- (OTSLineString *)createLineStringWithLineString:(OTSLineString *)ls;
- (OTSLineString *)createLineStringWithCoordinateSequence:(OTSCoordinateSequence *)coordinates;

- (OTSGeometry *)buildGeometry:(NSArray *)geoms;
- (OTSGeometry *)createGeometryWithGeometry:(OTSGeometry *)g;

@end
