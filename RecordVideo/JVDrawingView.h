//
//  JVDrawingView.h
//  RecordVideo
//
//  Created by Manu on 07/09/20.
//  Copyright © 2020 perfomatix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVDrawingLayer.h"

@interface JVDrawingView : UIView

@property (nonatomic, copy) void (^drawingLayerSelectedBlock)(BOOL isSelected);
@property (nonatomic, assign) JVDrawingType type;

- (BOOL)revoke;

@end
