//
//  WYPlaceholderTextView.h
//  WYKit
//
//  Created by yingwang on 2016/11/8.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface WYPlaceholderTextView : UITextView

@property (nonatomic, retain) IBInspectable NSString *placeholder;
@property (nonatomic, retain) IBInspectable UIColor *placeholderColor;

- (void)textChanged:(NSNotification*)notification;

@end
