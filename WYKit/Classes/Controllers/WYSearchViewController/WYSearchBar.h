//
//  WYSearchBar.h
//  WYKit
//
//  Created by yingwang on 2017/5/18.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WYSearchBar;
@protocol WYSearchBarDelegate <NSObject>
@optional
- (BOOL)searchBarShouldBeginEditing:(WYSearchBar *)searchBar;

- (void)searchBarDidBeginEditing:(WYSearchBar *)searchBar;

- (void)searchBarDidEndEditing:(WYSearchBar *)searchBar;

- (void)searchBarConfirmSearch:(WYSearchBar *)searchBar;

- (BOOL)searchBar:(WYSearchBar *)searchBar shouldChangeTextToString:(NSString *)newString;

@end

typedef NS_ENUM(NSUInteger, WYSearchBarStyle) {
    WYSearchBarStyleDefault,
    WYSearchBarStyleWhite
};

@interface WYSearchBar : UIView

@property (weak, nonatomic) IBOutlet UITextField *textfield;

@property (nonatomic, strong) NSString *placeholder;

@property (nonatomic, weak) id<WYSearchBarDelegate> delegate;

@property (nonatomic) WYSearchBarStyle style;

@end
