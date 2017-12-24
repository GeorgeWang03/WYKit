//
//  WYSearchViewController.m
//  WYKit
//
//  Created by yingwang on 2017/6/24.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  通用搜索控制器
//

//View
#import "WYSearchBar.h"

//Model

//Controller
#import "WYSearchViewController.h"
#import "WYSearchPopularViewController.h"

//Other
#import "WYPodDefine.h"
#import <Masonry/Masonry.h>
#import "UIView+WYInitialize.h"

typedef NS_ENUM(NSUInteger, WYSearchViewChildType) {
    WYSearchViewChildResult,
    WYSearchViewChildPopular,
    WYSearchViewChildTemprary
};

@interface WYSearchViewController () <WYSearchBarDelegate>
@property (nonatomic, strong) WYSearchBar *pSearchBar;

@property (nonatomic, strong) UIViewController<WYSearchViewControllerResultDelegate> *mainDisplayViewController;

@property (nonatomic, strong) UIViewController<WYSearchViewControllerPopularDelegate> *popularViewController;

@property (nonatomic, strong) UIViewController<WYSearchViewControllerTempraryDelegate> *tempResultViewController;

//Other
@property (nonatomic, strong) UIBarButtonItem *tempBackButtonItem;

@end

@implementation WYSearchViewController
#pragma mark - Getter and Setter
- (WYSearchBar *)pSearchBar {
    if (!_pSearchBar) {
        _pSearchBar = [WYSearchBar wy_loadFromNibByBundlePath:WYPodBundlePath];
        _pSearchBar.delegate = self;
        _pSearchBar.placeholder = @"请输入商家名称/地址";
    }
    return _pSearchBar;
}

- (WYSearchBar *)searchBar {
    return self.pSearchBar;
}

- (UIViewController<WYSearchViewControllerPopularDelegate> *)popularViewController {
    if (!_popularViewController) {
        _popularViewController = [[WYSearchPopularViewController alloc] init];
    }
    return _popularViewController;
}

//- (UIViewController<WYSearchViewControllerTempraryDelegate> *)tempResultViewController {
//    if (!_tempResultViewController) {
//        
//    }
//    return _tempResultViewController;
//}

#pragma mark - Intial
- (instancetype)initWithChildViewController:(UIViewController<WYSearchViewControllerResultDelegate> *)vc {
    return [self initWithChildViewController:vc
                       popularViewController:nil
                      tempraryViewController:nil];
}

- (instancetype)initWithChildViewController:(UIViewController<WYSearchViewControllerResultDelegate> *)vc tempraryViewController:(UIViewController<WYSearchViewControllerTempraryDelegate> *)tvc {
    return [self initWithChildViewController:vc
                       popularViewController:nil
                      tempraryViewController:tvc];
}

- (instancetype)initWithChildViewController:(UIViewController<WYSearchViewControllerResultDelegate> *)vc popularViewController:(UIViewController<WYSearchViewControllerPopularDelegate> *)pvc tempraryViewController:(UIViewController<WYSearchViewControllerTempraryDelegate> *)tvc {
    
    self = [super init];
    if (self) {
        NSAssert(vc, @"WYSearchViewController: ChildViewController confirm to WYSearchViewControllerResultDelegate protocol must desinated.");
        
        self.mainDisplayViewController = vc;
        [self addChildViewController:vc];
        
        __weak typeof(self) weakSelf = self;
        self.popularViewController = pvc;
        self.tempResultViewController = tvc;
        if (self.tempResultViewController) {
            self.tempResultViewController.internalHandleItemSelected = ^(NSString *keywork) {
                weakSelf.searchBar.textfield.text = keywork;
                [weakSelf searchBarConfirmSearch:weakSelf.searchBar];
            };
        }
    }
    return self;
}

#pragma mark - Lifecyle
- (void)loadView {
    self.view = [[UIView alloc] init];
    
    [self.view addSubview:self.mainDisplayViewController.view];
    [self.view addSubview:self.popularViewController.view];
    [self.view addSubview:self.tempResultViewController.view];
    
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    __weak UIViewController *weakSelf = self;
    [self.mainDisplayViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong UIViewController *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
    }];
    
    [self.popularViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong UIViewController *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
    }];
    
    [self.tempResultViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong UIViewController *strongSelf = weakSelf;
        make.left.equalTo(strongSelf.view.mas_left).with.offset(padding.left);
        make.right.equalTo(strongSelf.view.mas_right).with.offset(-padding.right);
        make.top.equalTo(strongSelf.view.mas_top).with.offset(padding.top);
        make.bottom.equalTo(strongSelf.view.mas_bottom).with.offset(-padding.bottom);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    __weak WYSearchViewController *weakSelf = self;
    self.popularViewController.quickSearchForKeyword = ^(NSString *keyword) {
        weakSelf.pSearchBar.textfield.text = keyword;
        [weakSelf.searchBar endEditing:YES];
        [weakSelf changeFirstRespondControllerWithType:WYSearchViewChildResult];
        [weakSelf safePerformSelector:@selector(wy_searchController:didStartSearchWithKeyword:)
                           object:weakSelf.mainDisplayViewController
                        parameter:weakSelf parameter:weakSelf.searchBar.textfield.text];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.searchBar.textfield.text.length) {
        [self.pSearchBar.textfield becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.pSearchBar.textfield endEditing:YES];
    [self.pSearchBar removeFromSuperview];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
}

#pragma mark - Views Setup
- (void)setupNavigationBar {
    CGFloat boundsWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    self.pSearchBar.frame = CGRectMake(35, 0, boundsWidth-30-30, 32);
    self.pSearchBar.center = CGPointMake(CGRectGetMidX(self.pSearchBar.frame), 22);
    [self.navigationController.navigationBar addSubview:self.pSearchBar];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 30)];
    [editButton addTarget:self action:@selector(handleCancelButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];
    [editButton setTitle:@"取消" forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    self.navigationItem.rightBarButtonItem = item;
    
    editButton.alpha = 0;
    editButton.hidden = YES;
}

#pragma mark - Views Logic
- (void)changeFirstRespondControllerWithType:(WYSearchViewChildType)type {
    
    UIView *view;
    switch (type) {
        case WYSearchViewChildResult:
            [self animatingForResultState];
            view = self.mainDisplayViewController.view;
            break;
        case WYSearchViewChildPopular:
            [self animatingForSearchState];
            [self safePerformSelector:@selector(wy_searchControllerWillShowPopularView:)
                               object:self.popularViewController
                            parameter:self parameter:nil];
            view = self.popularViewController.view;
            break;
        case WYSearchViewChildTemprary:
            [self animatingForSearchState];
            view = self.tempResultViewController.view ?: self.popularViewController.view;
            break;
        default:
            break;
    }
    
    [self.view bringSubviewToFront:view];
}

static float kAnimationDuration = 0.4;

- (void)animatingForSearchState {
    
    self.tempBackButtonItem = self.navigationItem.backBarButtonItem;
    self.navigationItem.backBarButtonItem = nil;
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    UIView *customeView = item.customView;
    
    customeView.hidden = NO;
    CGFloat boundsWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         customeView.alpha = 1;
                         self.pSearchBar.frame = CGRectMake(8,
                                                            CGRectGetMinY(self.pSearchBar.frame)
                                                            , boundsWidth-30-45, 32);
                     }];
}

- (void)animatingForResultState {
    
    self.navigationItem.backBarButtonItem = self.tempBackButtonItem;
    
    UIBarButtonItem *item = self.navigationItem.rightBarButtonItem;
    UIView *customeView = item.customView;
    
    CGFloat boundsWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         customeView.alpha = 0;
                         self.pSearchBar.frame = CGRectMake(35, 0, boundsWidth-30-30, 32);
                         self.pSearchBar.center = CGPointMake(CGRectGetMidX(self.pSearchBar.frame), 22);
                     } completion:^(BOOL finished) {
                        customeView.hidden = finished;
                     }];
}

#pragma mark - Event
- (void)handleCancelButtonAction:(id)sender {
    
    if (!self.pSearchBar.textfield.text.length) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.pSearchBar.textfield endEditing:YES];
        [self changeFirstRespondControllerWithType:WYSearchViewChildResult];
    }
}

#pragma mark - WYSearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(WYSearchBar *)textField {
    
    return YES;
}

- (void)searchBarDidBeginEditing:(WYSearchBar *)searchBar {
    if (searchBar.textfield.text.length) {
        [self changeFirstRespondControllerWithType:WYSearchViewChildTemprary];
        [self safePerformSelector:@selector(wy_searchController:changeKeyword:)
                           object:self.tempResultViewController
                        parameter:self parameter:searchBar.textfield.text];
    } else {
        [self changeFirstRespondControllerWithType:WYSearchViewChildPopular];
        [self safePerformSelector:@selector(wy_searchControllerWillShowPopularView:)
                           object:self.popularViewController
                        parameter:self parameter:nil];
    }
}

- (void)searchBarConfirmSearch:(WYSearchBar *)searchBar {
    [searchBar.textfield endEditing:YES];
    
    [self changeFirstRespondControllerWithType:WYSearchViewChildResult];
    
//    NSAssert([self.mainDisplayViewController respondsToSelector:@selector(wy_searchController:didStartSearchWithKeyword:)],
//             @"WYSearchViewController: ChildViewController Confirm to WYSearchViewControllerResultDelegate protocol required respond to selector wy_searchController:didStartSearchWithKeyword:");
//    
    [self safePerformSelector:@selector(wy_searchController:didStartSearchWithKeyword:)
                       object:self.mainDisplayViewController
                    parameter:self parameter:searchBar.textfield.text];
    [self safePerformSelector:@selector(wy_searchController:didStartSearchWithKeyword:)
                       object:self.popularViewController
                    parameter:self parameter:searchBar.textfield.text];
}

- (BOOL)searchBar:(WYSearchBar *)searchBar shouldChangeTextToString:(NSString *)newString {
    
    if (newString.length) {
        [self changeFirstRespondControllerWithType:WYSearchViewChildTemprary];
        [self safePerformSelector:@selector(wy_searchController:changeKeyword:)
                           object:self.tempResultViewController
                        parameter:self parameter:newString];
    } else {
        [self changeFirstRespondControllerWithType:WYSearchViewChildPopular];
    }
    
    return YES;
}


#pragma mark - Notification

#pragma mark - Other
- (void)safePerformSelector:(SEL)selector object:(id)object
                  parameter:(id)parameter1 parameter:(id)parameter2 {
    if ([object respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [object performSelector:selector withObject:parameter1 withObject:parameter2];
#pragma clang diagnostic pop
    }
}

@end

















