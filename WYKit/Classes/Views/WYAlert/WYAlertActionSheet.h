//
//  WYAlertActionSheet.h
//  WYostApp
//
//  Created by yingwang on 2016/12/11.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYAlertAction.h"

@class WYAlertAction;
@interface WYAlertActionSheet : NSObject

+ (instancetype)actionSheet;

- (void)addAction:(WYAlertAction *)action;

- (void)show;
- (void)hide;

@end
