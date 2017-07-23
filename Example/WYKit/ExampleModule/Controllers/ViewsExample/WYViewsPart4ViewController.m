//
//  WYViewsPart4ViewController.m
//  WYKit_Example
//
//  Created by yingwang on 2017/7/20.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYMarco.h"
#import "WYTimerButton.h"
#import "WYSegmentScrollView.h"
#import "UIView+WYBadge.h"
#import "UIButton+WYIndicator.h"
#import "UIView+WYCurryAnimation.h"
#import "WYViewsPart4ViewController.h"

@interface WYViewsPart4ViewController () <WYSegmentScrollViewDelegate, WYSegmentScrollViewDataSource>
{
    dispatch_once_t onceToken;
}

@property (nonatomic, strong) WYSegmentScrollView *segmentScrollView;

@property (nonatomic, strong) NSMutableArray *segmentTitles;
@property (nonatomic, strong) NSMutableArray *segmentViewControllers;

@property (nonatomic, strong) WYTimerButton *timerButton;

@end

@implementation WYViewsPart4ViewController
#pragma mark - Getter
- (NSMutableArray *)segmentTitles {
    if (!_segmentTitles) {
        _segmentTitles = [NSMutableArray array];
    }
    return _segmentTitles;
}

- (NSMutableArray *)segmentViewControllers {
    if (!_segmentViewControllers) {
        _segmentViewControllers = [NSMutableArray array];
    }
    return _segmentViewControllers;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    dispatch_once(&onceToken, ^{
        // setup SegmentScrollView
        [self setupSegmentScrollView];
        
        // setup WYTimerButton
        [self setupTimerButton];
        
        // setup MessageButton
        // use UIView+WYBadge
        // as well as UIView+WYCurryAnimation
        [self setupMessageButton];
        
        // setup Indicator
        // use UIButton+WYIndicator
        [self setupIndicatorButton];
        
        [self.segmentScrollView reloadData];
    });
}

// SegmentScrollView
- (void)setupSegmentScrollView {
    
    self.segmentScrollView = [[WYSegmentScrollView alloc] initWithFrame:self.view.bounds];
    self.segmentScrollView.delegate = self;
    self.segmentScrollView.dataSource = self;
    self.segmentScrollView.segmentorHeight = 60;
    self.segmentScrollView.highlightedColor = [UIColor redColor];
    self.segmentScrollView.normalColor = [UIColor darkGrayColor];
    self.segmentScrollView.titleFont = [UIFont systemFontOfSize:14];
    self.segmentScrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.segmentScrollView];
}

#pragma mark - WYSegmentScrollView Delegate
- (CGFloat)segmentScrollView:(WYSegmentScrollView *)segmentScrollView widthForSegmentorAtIndex:(NSInteger)index {
    NSString *title = self.segmentTitles[index];
    
    return title.length*14;
}
- (void)segmentScrollView:(WYSegmentScrollView *)segmentScrollView didScrollToPageAtIndex:(NSInteger)index {
    
}

#pragma mark - WYSegmentScrollView DataSource
- (NSInteger)numberOfItemInSegmentScrollView:(WYSegmentScrollView *)segmentScrollView {
    return self.segmentViewControllers.count;
}

- (UIView *)segmentScrollView:(WYSegmentScrollView *)segmentScrollView viewForSegmentorAtIndex:(NSInteger)index {
    return [self.segmentViewControllers[index] view];
}

- (NSString *)segmentScrollView:(WYSegmentScrollView *)segmentScrollView titleForSegmentorAtIndex:(NSInteger)index {
    return self.segmentTitles[index];
}

#pragma mark - Setup TimerButton
- (void)setupTimerButton {
    UIViewController *vc = [[UIViewController alloc] init];
    [self.segmentViewControllers addObject:vc];
    [self.segmentTitles addObject:@"WYTimerButton"];
    
    self.timerButton = [[WYTimerButton alloc] init];
    self.timerButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.timerButton.layer.borderWidth = .7;
    self.timerButton.layer.cornerRadius = 2;
    [self.timerButton setTitleColor:[UIColor darkGrayColor]
                           forState:UIControlStateNormal];
    self.timerButton.timingStateColor = [UIColor lightGrayColor];
    [self.timerButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    self.timerButton.touchableWhenTiming = NO; // can`t touch when timing
    self.timerButton.frame = CGRectMake(0, 0, 120, 35);
    self.timerButton.center = self.view.center;
    
    [self.timerButton addTarget:self
                         action:@selector(handleTimerButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [vc.view addSubview:self.timerButton];
}

- (void)handleTimerButtonAction:(WYTimerButton *)sender {
    WEAK_SELF
    [sender startTimerWithTimerInterval:10 completion:^(BOOL finish) {
        // .. do anything when timing stop
        if (finish) {
            [weakSelf.timerButton setTitle:@"再次发送" forState:UIControlStateNormal];
        }
    }];
}

#pragma mark - Setup MessageButton
//
// use UIView+WYBadge
// as well as UIView+WYCurryAnimation
//
- (void)setupMessageButton {
    UIViewController *vc = [[UIViewController alloc] init];
    [self.segmentViewControllers addObject:vc];
    [self.segmentTitles addObject:@"WYBadge+CurryAnimation"];
    
    UIButton *msgButton = [[UIButton alloc] init];
//    msgButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
//    msgButton.layer.borderWidth = .7;
//    msgButton.layer.cornerRadius = 2;
    [msgButton setTitleColor:[UIColor darkGrayColor]
                           forState:UIControlStateNormal];
    [msgButton setImage:[UIImage imageNamed:@"img_demo_msg"]
                      forState:UIControlStateNormal];
    msgButton.frame = CGRectMake(0, 0, 40, 40);
    msgButton.center = self.view.center;
    
    // UIView+WYBadge
    msgButton.wy_badge.text = @"112";
    msgButton.wy_badge.font = [UIFont systemFontOfSize:10];
    msgButton.wy_badge.backgroundColor = [UIColor redColor];
    msgButton.wy_badge.layer.cornerRadius = 3;
    // use badgeHeight to ser badge height
    msgButton.wy_badgeHeight = 15;
    // use badgeOffset to control the center align to the top-right corner
    msgButton.wy_badgeOffset = CGPointMake(-5, 5);
    // you can alse use the code below to hide badge
    // when the message count is 0 :
    // msgButton.wy_badge.hidden = YES;
    
    // UIView+WYCurryAnimation
    // a good parttern to work with WYBadge for interact animation
    [msgButton.wy_badge wy_addCurryWithCompleted:^(UIView *sender, BOOL dismiss) {
        // the complete block will call when you drag the badge to dismiss
        sender.hidden = dismiss;
    }];
    
    // use the code below to remove WYCurryAnimation
    // [msgButton.wy_badge wy_removeCurry];
    
    
    [vc.view addSubview:msgButton];
}

#pragma mark - Setup IndicatorButton
- (void)setupIndicatorButton {
    UIViewController *vc = [[UIViewController alloc] init];
    [self.segmentViewControllers addObject:vc];
    [self.segmentTitles addObject:@"UIButton+WYIndicator"];
    
    UIButton *idtButton = [[UIButton alloc] init];
    idtButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    idtButton.layer.borderWidth = .7;
    idtButton.layer.cornerRadius = 2;
    [idtButton setTitleColor:[UIColor darkGrayColor]
                           forState:UIControlStateNormal];
    [idtButton setTitle:@"确定发送" forState:UIControlStateNormal];
    [idtButton setImage:[UIImage imageNamed:@"img_demo_plane"]
               forState:UIControlStateNormal];
    idtButton.frame = CGRectMake(0, 0, 120, 35);
    idtButton.center = self.view.center;
    
    [idtButton addTarget:self
                         action:@selector(handleIndicatorButtonAction:)
               forControlEvents:UIControlEventTouchUpInside];
    
    [vc.view addSubview:idtButton];
}

- (void)handleIndicatorButtonAction:(UIButton *)sender {
    
    sender.wy_indicatorStyle = UIActivityIndicatorViewStyleGray;
    //        sender.wy_startIndicatorAnimation(kWYButtonIndicatorCenter);
    //        sender.wy_startIndicatorAnimation(kWYButtonIndicatorInsteadImage);
    sender.wy_startIndicatorAnimation(kWYButtonIndicatorInsteadTitle);
    
    // code below stop animation
    // sender.wy_stopIndicatorAnimation();
}

@end
