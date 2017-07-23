//
//  WYSearchFuzzyViewModel.h
//  WYKit_Example
//
//  Created by yingwang on 2017/7/23.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYSearchFuzzyViewController.h"

@interface WYSearchFuzzyViewModel : NSObject<WYSearchFuzzyViewProtocol>

@property (nonatomic, strong) NSString *keywork;
@property (nonatomic, readonly) NSArray<WYSearchFuzzyItem *> *items;

- (void)reloadDataWithComplete:(void(^)(BOOL success, NSError *error))complete;

@end
