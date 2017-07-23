//
//  WYSearchPopularViewController.h
//  CPCS
//
//  Created by yingwang on 2017/6/24.
//  Copyright © 2017年 全国邮政电子商务运营中心. All rights reserved.
//
//  搜索控制器-热门搜索／历史搜索子控制器
//

#import <UIKit/UIKit.h>
#import "WYSearchViewController.h"

typedef NS_OPTIONS(NSUInteger, WYSearchPopularComponentOption) {
    WYSearchPopularComponentOptionHot = 1 << 0, // 热门搜索
    WYSearchPopularComponentOptionHistory = 1 << 1 // 历史搜索
};

@interface WYSearchPopularViewController : UIViewController

@property (nonatomic, copy) void(^quickSearchForKeyword)(NSString *keyword);

- (instancetype)initWithOption:(WYSearchPopularComponentOption)option;

- (instancetype)initWithHistoryIdentifier:(NSString *)historyIdentifier
                                   option:(WYSearchPopularComponentOption)option;

@end
