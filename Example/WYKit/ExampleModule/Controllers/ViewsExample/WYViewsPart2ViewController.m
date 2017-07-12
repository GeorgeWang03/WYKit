//
//  WYViewsPart2ViewController.m
//  WYKit_Example
//
//  Created by yingwang on 2017/7/12.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYViewsPart2ViewController.h"

#import "WYCircleItemSelectedView.h"

@interface WYViewsPart2ViewController ()
{
    CGFloat _currrentTopEdgeY;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) WYCircleItemSelectedView *itemSelectedView;

@end

@implementation WYViewsPart2ViewController

- (UIScrollView *)mainScrollView {
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.alwaysBounceVertical = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
    }
    return _mainScrollView;
}

- (void)loadView {
    
    self.view = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainScrollView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _currrentTopEdgeY = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleCircleItemSelectedNotification:)
                                                 name:kWYCircleItemSelectedViewCellSelectedNotificationName
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.mainScrollView.frame = self.view.bounds;
        
        // setup WYCircleItemSelectedView
        [self setupCircleItemSelectedView];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - WYCircleItemSelectedView
- (void)setupCircleItemSelectedView {
    
    _itemSelectedView = [[WYCircleItemSelectedView alloc] init];
    _itemSelectedView.fontSize = 13;
    _itemSelectedView.exactItemSpacing = 5;
    _itemSelectedView.exactLineSpacing = 5;
    _itemSelectedView.mutableSelection = NO; // default is NO
    
    _itemSelectedView.itemsTitle = @[@"Apple", @"Hello World!", @"iPhone", @"macBookPro", @"AppleWatch"];
    
    _itemSelectedView.frame = CGRectMake(20, _currrentTopEdgeY+50, CGRectGetWidth(self.view.bounds)-40, 50);
    [self.mainScrollView addSubview:_itemSelectedView];
    
    _currrentTopEdgeY += (CGRectGetMaxY(_itemSelectedView.frame));
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
}

- (void)handleCircleItemSelectedNotification:(NSNotification *)notification {
    if (notification.object != self.itemSelectedView) return;
    
    NSUInteger idx = [notification.userInfo[kWYCircleItemSelectedViewCellNotifyInfoIndexPathKey] unsignedIntegerValue];
    // do something
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
