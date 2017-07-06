//
//  WYViewsPart1ViewController.m
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "Masonry.h"
#import "WYViewsPart1ViewController.h"

#import "WYAlertAction.h"
#import "WYAlertActionAlert.h"

@interface WYViewsPart1ViewController ()
{
    CGFloat _currrentTopEdgeY;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) WYAlertActionAlert *actionAlert;

@end

@implementation WYViewsPart1ViewController

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
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.mainScrollView.frame = self.view.bounds;
        
        // setup WYAlertActionAlert
        [self setupWYAlertActionAlert];
    });
}

/**
 WYAlertActionAlert
 */
- (void)setupWYAlertActionAlert {
    
    UIButton *showButton = [[UIButton alloc] init];
    [showButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    showButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-80, _currrentTopEdgeY+50, 160, 40);
    [showButton setTitle:@"WYAlertActionAlert" forState:UIControlStateNormal];
    [showButton addTarget:self
                   action:@selector(showWYAlertActionAlert)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:showButton];
    
    _currrentTopEdgeY += 100;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
    
    WYAlertActionAlert *alert = [[WYAlertActionAlert alloc] initWithTitle:@"Attention"
                                                                  message:@"Make sure to delete xxx file ?"
                                                                     icon:nil];
    
    __weak WYAlertActionAlert *weakAlert = alert;
    WYAlertAction *confirmAction = [WYAlertAction actionWithTitle:@"YES"
                                                           style:WYAlertActionCustom
                                                         handler:^(WYAlertAction *action) {
                                                             [weakAlert hide];
                                                         }];
    // custom confirm action button title textColor
    confirmAction.textColor = [UIColor orangeColor];
    confirmAction.backgroundColor = [UIColor whiteColor];
    
    WYAlertAction *cancelAction = [WYAlertAction actionWithTitle:@"NO"
                                                           style:WYAlertActionCancel
                                                         handler:^(WYAlertAction *action) {
                                                             [weakAlert hide];
                                                         }];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    self.actionAlert = alert;
}

- (void)showWYAlertActionAlert {
    // default showing
    [self.actionAlert show];
    
    // show with screen orientation
//    [self.actionAlert showWithOrientation:UIInterfaceOrientationLandscapeLeft];
    
    // show with screen orientation and in a desinated window
//    [self.actionAlert showWithOrientation:UIInterfaceOrientationPortrait
//                                   window:nil];
}

@end














