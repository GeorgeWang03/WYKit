//
//  WYSearchFuzzyViewModel.m
//  WYKit_Example
//
//  Created by yingwang on 2017/7/23.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYSearchFuzzyViewModel.h"

@interface WYSearchFuzzyViewModel()

@property (nonatomic, strong) NSMutableArray<WYSearchFuzzyItem *> *pItems;

@end

@implementation WYSearchFuzzyViewModel

- (NSArray<WYSearchFuzzyItem *> *)items {
    return self.pItems;
}

- (void)reloadDataWithComplete:(void(^)(BOOL success, NSError *error))complete {
    // search by keyWork by networking or local cache
    // here the example just return the same items
    
    self.pItems = [NSMutableArray array];
    
    WYSearchFuzzyItem *item;
    item = [[WYSearchFuzzyItem alloc] init];
    item.title = @"麦当劳";
    item.subtitle = @"约10个搜索结果";
    [self.pItems addObject:item];
    
    item = [[WYSearchFuzzyItem alloc] init];
    item.title = @"KFC";
    item.subtitle = @"约10个搜索结果";
    [self.pItems addObject:item];
    
    if (complete) {
        complete(YES, nil);
    }
}

@end
