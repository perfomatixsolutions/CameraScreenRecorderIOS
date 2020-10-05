//
//  JVDrawingView.m
//  RecordVideo
//
//  Created by Manu on 07/09/20.
//  Copyright © 2020 perfomatix. All rights reserved.
//


#import "JVDrawingView.h"

@interface JVDrawingView ()

@property (nonatomic, assign) BOOL isFirstTouch;
@property (nonatomic, assign) JVDrawingTouch isMoveLayer;
@property (nonatomic, strong) JVDrawingLayer *drawingLayer;
@property (nonatomic, strong) JVDrawingLayer *selectedLayer;
@property (nonatomic, strong) NSMutableArray *layerArray;
@property (nonatomic, strong) NSMutableArray *drawedLayerArray;

@end

@implementation JVDrawingView

- (instancetype)init {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        self.frame = [UIScreen mainScreen].bounds;
        self.layerArray = [[NSMutableArray alloc] init];
        self.type = JVDrawingTypeGraffiti;
    }
    return self;
}

- (BOOL)revoke {
    BOOL status = [self.selectedLayer revokeUntilHidden];
    if (status) {
        [self.selectedLayer removeFromSuperlayer];
        [self.layerArray removeObject:self.selectedLayer];
        self.selectedLayer = nil;
    }
    return status;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    self.isFirstTouch = YES;
    self.isMoveLayer = NO;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    if (self.isFirstTouch) {
        if (self.selectedLayer && [self.selectedLayer caculateLocationWithPoint:currentPoint]) {
            self.isMoveLayer = [self.selectedLayer caculateLocationWithPoint:currentPoint];
        } else {
            self.drawingLayer = [JVDrawingLayer createLayerWithStartPoint:previousPoint type:self.type];
            [self.layer addSublayer:self.drawingLayer];
        }
    } else {
        if (self.isMoveLayer) {
            if (self.selectedLayer.type == JVDrawingTypeGraffiti) {
                [self.selectedLayer moveGrafiitiPathPreviousPoint:previousPoint currentPoint:currentPoint];
            } else {
                switch (self.isMoveLayer) {
                    case JVDrawingTouchHead:
                        [self.selectedLayer movePathWithStartPoint:currentPoint];
                        break;
                    case JVDrawingTouchMid:
                        [self.selectedLayer movePathWithPreviousPoint:previousPoint currentPoint:currentPoint];
                        break;
                    case JVDrawingTouchEnd:
                        [self.selectedLayer movePathWithEndPoint:currentPoint];
                        break;
                        
                    default:
                        break;
                }
            }
        } else {
            [self.drawingLayer movePathWithEndPoint:currentPoint];
        }
    }
    
    self.isFirstTouch = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    
    [super touchesEnded:touches withEvent:event];
    if (![self.layerArray containsObject:self.drawingLayer] && !self.isFirstTouch) {
        [self.layerArray addObject:self.drawingLayer];
        [self.drawingLayer addToTrack];

        
        
    } else {
        if (self.isMoveLayer) {
            [self.selectedLayer addToTrack];
        }
        if (self.isFirstTouch) {
            self.selectedLayer.isSelected = NO;
            self.selectedLayer = nil;
            
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self];
            for (JVDrawingLayer *layer in self.layerArray) {
                if ([layer caculateLocationWithPoint:currentPoint]) {
                    self.selectedLayer = layer;
                    self.selectedLayer.isSelected = YES;
                    [self.layerArray removeObject:self.selectedLayer];
                    [self.layerArray addObject:self.selectedLayer];
                    break;
                }
            }
            
            if(self.selectedLayer)
            {
                self.drawingLayerSelectedBlock(self.selectedLayer);
            }
        }
    }
    
    
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self.drawingLayer addToTrack];
}


@end
