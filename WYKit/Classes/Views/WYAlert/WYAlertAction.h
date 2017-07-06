//
//  WYAlertAction.h
//  WYKit
//
//  Created by yingwang on 2016/12/27.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WYAlertActionStyle) {
    WYAlertActionDefault,
    WYAlertActionGray,
    WYAlertActionCancel,
    WYAlertActionHighlight,
    WYAlertActionCustom
};

@interface WYAlertAction : NSObject

@property (nonatomic) WYAlertActionStyle style;
@property (nonatomic) NSString *title;
@property (nonatomic, copy) void (^handler)(WYAlertAction *action);

// custom style attribute
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *textColor;

+ (instancetype)actionWithTitle:(NSString *)title style:(WYAlertActionStyle)style handler:(void (^)(WYAlertAction *))handler;

@end
