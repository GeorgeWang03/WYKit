//
//  WYAlertAction.m
//  WYKit
//
//  Created by yingwang on 2016/12/27.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYAlertAction.h"

@interface WYAlertAction ()

@end

@implementation WYAlertAction

- (instancetype)initWithTitle:(NSString *)title style:(WYAlertActionStyle)style handler:(void (^)(WYAlertAction *))handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.style = style;
        self.handler = handler;
    }
    return self;
}

+ (instancetype)actionWithTitle:(NSString *)title style:(WYAlertActionStyle)style handler:(void (^)(WYAlertAction *))handler {
    return [[self alloc] initWithTitle:title style:style handler:handler];
}

@end



