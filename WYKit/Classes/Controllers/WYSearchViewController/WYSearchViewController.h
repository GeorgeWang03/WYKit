//
//  WYSearchViewController.h
//  WYKit
//
//  Created by yingwang on 2017/6/24.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  通用搜索控制器
//

#import <UIKit/UIKit.h>
#import "WYSearchBar.h"
#import "WYSearchPopularViewController.h"

@class WYSearchViewController;
@protocol WYSearchViewControllerResultDelegate <NSObject>
@required
- (void)wy_searchController:(WYSearchViewController *)searchController
  didStartSearchWithKeyword:(NSString *)keyword;

@optional

@end

@protocol WYSearchViewControllerPopularDelegate <NSObject>
@required

@property (nonatomic, copy) void(^quickSearchForKeyword)(NSString *keyword);

- (void)wy_searchControllerWillShowPopularView:(WYSearchViewController *)searchController;

@optional
- (void)wy_searchController:(WYSearchViewController *)searchController
  didStartSearchWithKeyword:(NSString *)keyword;

@end

@protocol WYSearchViewControllerTempraryDelegate <NSObject>
@required
- (void)wy_searchController:(WYSearchViewController *)searchController changeKeyword:(NSString *)keyword;

@optional

@end

@interface WYSearchViewController : UIViewController

@property (nonatomic, readonly) WYSearchBar *searchBar;

- (instancetype)initWithChildViewController:(UIViewController<WYSearchViewControllerResultDelegate> *)vc;

- (instancetype)initWithChildViewController:(UIViewController<WYSearchViewControllerResultDelegate> *)vc
                      popularViewController:(UIViewController<WYSearchViewControllerPopularDelegate> *)pvc tempraryViewController:(UIViewController<WYSearchViewControllerTempraryDelegate> *)tvc;

@end
