//
//  WYSearchFuzzyViewController.h
//  WYKit
//
//  Created by yingwang on 2017/7/11.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WYSearchViewController.h"

@interface WYSearchFuzzyItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;

@end

@protocol WYSearchFuzzyViewProtocol
@required
@property (nonatomic, strong) NSString *keywork;
@property (nonatomic, readonly) NSArray<WYSearchFuzzyItem *> *items;

- (void)reloadDataWithComplete:(void(^)(BOOL success, NSError *error))complete;

@end

@interface WYSearchFuzzyViewController : UIViewController

@property (nonatomic, copy) void(^internalHandleItemSelected)(NSString *keywork);
@property (nonatomic, copy) void(^handleItemSelected)(NSUInteger idx);

- (instancetype)initWithViewModel:(id<WYSearchFuzzyViewProtocol>)viewModel;

@end
