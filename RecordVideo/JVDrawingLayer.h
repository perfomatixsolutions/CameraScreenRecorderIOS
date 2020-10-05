//
//  JVDrawingLayer.h
//  RecordVideo
//
//  Created by Manu on 07/09/20.
//  Copyright © 2020 perfomatix. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSInteger, JVDrawingType) {
    JVDrawingTypeArrow = 0,   
    JVDrawingTypeLine,
    JVDrawingTypeRulerArrow,
    JVDrawingTypeRulerLine,
    JVDrawingTypeGraffiti
};

typedef NS_ENUM(NSInteger, JVDrawingTouch) {
    JVDrawingTouchHead = 1,
    JVDrawingTouchMid,
    JVDrawingTouchEnd
};

@interface JVDrawingLayer : CAShapeLayer

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) JVDrawingType type;

+ (JVDrawingLayer *)createLayerWithStartPoint:(CGPoint)startPoint type:(JVDrawingType)type;

- (NSInteger)caculateLocationWithPoint:(CGPoint)point;

- (void)movePathWithStartPoint:(CGPoint)startPoint;
- (void)movePathWithEndPoint:(CGPoint)EndPoint;
- (void)movePathWithPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint;

- (void)movePathWithStartPoint:(CGPoint)startPoint isSelected:(BOOL)isSelected;
- (void)movePathWithEndPoint:(CGPoint)EndPoint isSelected:(BOOL)isSelected;
- (void)movePathWithPreviousPoint:(CGPoint)previousPoint
                     currentPoint:(CGPoint)currentPoint
                       isSelected:(BOOL)isSelected;

- (void)moveGrafiitiPathPreviousPoint:(CGPoint)previousPoint currentPoint:(CGPoint)currentPoint;

- (void)addToTrack;
- (BOOL)revokeUntilHidden;

@end
