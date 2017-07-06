//
//  WYCircleProgressBar.h
//  WYKit
//
//  Created by yingwang on 2016/10/28.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WYCPCircleLayerType) {
    
    kWYCPCircleLayerTypeNormalSolid,
    
    kWYCPCircleLayerTypeNormalHollow,
    
    kWYCPCircleLayerTypeHighlighted
};

@interface WYCPCircleLayer : CAShapeLayer

@property (nonatomic, assign) BOOL animatable;

- (instancetype)initWithFrame:(CGRect)frame type:(WYCPCircleLayerType)type radius:(CGFloat)radius color:(UIColor *)color;

@end

@interface WYCircleProgressBar : UIView

@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, readonly) CGPoint currentPosition;
@property (nonatomic, assign) NSInteger progress;

@property (nonatomic, assign) BOOL animatable;

- (instancetype)initWithFrame:(CGRect)frame radius:(CGFloat)radius circlesCount:(NSInteger)circlesCount;

///////--------------------------------------- UNAVAILABLE ------------------------------------------///////

//- (instancetype)init UNAVAILABLE_ATTRIBUTE;
//- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;

@end
