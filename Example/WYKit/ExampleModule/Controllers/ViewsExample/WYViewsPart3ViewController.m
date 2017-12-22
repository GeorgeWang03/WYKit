//
//  WYViewsPart3ViewController.m
//  WYKit_Example
//
//  Created by yingwang on 2017/7/13.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "Masonry.h"
#import "WYTagView.h"
#import "WYMorphingLabel.h"
#import "WYCircleProgressBar.h"
#import "WYViewsPart3ViewController.h"

@interface WYViewsPart3ViewController ()
{
    CGFloat _currrentTopEdgeY;
    dispatch_once_t onceToken;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) WYMorphingLabel *morphingLabel;

@property (nonatomic, strong) WYCircleProgressBar *progressBar;

@property (nonatomic, strong) WYTagView *tagView;

@end

@implementation WYViewsPart3ViewController

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
    
    dispatch_once(&onceToken, ^{
        self.mainScrollView.frame = self.view.bounds;
        
        // setup WYMorphingLabel
        [self setupWYMorphingLabel];
        
        // setup WYCircleProgressBar
        [self setupWYCircleProgressBar];
        
        // setup WYTagView
        [self setupWYTagView];
        [self.tagView reloadData];
    });
}

#pragma mark - WYMorphingLabel
- (void)setupWYMorphingLabel {
    
    self.morphingLabel = [[WYMorphingLabel alloc] init];
    self.morphingLabel.text = @"WYKitDemo";
    self.morphingLabel.repetable = YES;
    self.morphingLabel.textColor = [UIColor redColor];
    self.morphingLabel.font = [UIFont systemFontOfSize:30];
    self.morphingLabel.textAlignment = NSTextAlignmentCenter;
    self.morphingLabel.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-80, _currrentTopEdgeY+50, 160, 40);
    
    [self.mainScrollView addSubview:self.morphingLabel];
    
    _currrentTopEdgeY += 60;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
    
    UIButton *startButton = [[UIButton alloc] init];
    [startButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    startButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-100, _currrentTopEdgeY+50, 80, 40);
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton addTarget:self.morphingLabel
                   action:@selector(startAnimation)
         forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:startButton];
    
    UIButton *stopButton = [[UIButton alloc] init];
    [stopButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    stopButton.frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2+20, _currrentTopEdgeY+50, 80, 40);
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [stopButton addTarget:self.morphingLabel
                    action:@selector(stopAnimation)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainScrollView addSubview:stopButton];
    
    _currrentTopEdgeY += 100;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
}

#pragma mark - WYCircleProgressBar
- (void)setupWYCircleProgressBar {
    self.progressBar = [[WYCircleProgressBar alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-100, _currrentTopEdgeY+50, 200, 30)
                                                           radius:4.f
                                                     circlesCount:10];
    self.progressBar.highlightedColor = [UIColor redColor];
    self.progressBar.normalColor = [UIColor grayColor];
    self.progressBar.progress = 4;
    
    [self.mainScrollView addSubview:self.progressBar];
    
    _currrentTopEdgeY += 100;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
}

#pragma mark - WYTagView
- (void)setupWYTagView {
    
    self.tagView = [[WYTagView alloc] initWithFrame:CGRectMake(20, _currrentTopEdgeY+50, CGRectGetWidth(self.view.bounds)-40, 100)];
    self.tagView.itemSpacing = 5;
    self.tagView.lineSpacing = 5;
    self.tagView.itemCornerRadius = 2;
    self.tagView.tagContentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    
    self.tagView.titles = @[@"Hello World!", @"Objective-C", @"WYKit is a collection of code from daily develop!!!!", @"G"];
    
    [self.mainScrollView addSubview:self.tagView];
    
    _currrentTopEdgeY += 150;
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), _currrentTopEdgeY);
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
