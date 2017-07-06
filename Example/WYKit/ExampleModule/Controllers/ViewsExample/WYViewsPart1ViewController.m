//
//  WYViewsPart1ViewController.m
//  WYKit
//
//  Created by yingwang on 2017/6/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "Masonry.h"
#import "WYViewsPart1ViewController.h"

@interface WYViewsPart1ViewController ()

@property (nonatomic, strong) UIScrollView *mainScrollView;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
