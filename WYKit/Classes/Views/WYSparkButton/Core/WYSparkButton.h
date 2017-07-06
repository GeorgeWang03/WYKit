//
//  WYSparkButton.h
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/21.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYSparkButton : UIButton

@property (nonatomic) IBInspectable UIColor *iconNormalColor;
@property (nonatomic) IBInspectable UIColor *iconSelectedColor;

@property (nonatomic) IBInspectable UIColor *ringFromColor;
@property (nonatomic) IBInspectable UIColor *ringToColor;

@property (nonatomic) IBInspectable UIColor *firstDotColor;
@property (nonatomic) IBInspectable UIColor *secondDotColor;

@end
