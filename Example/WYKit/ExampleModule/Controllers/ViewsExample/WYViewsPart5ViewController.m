//
//  WYViewsPart5ViewController.m
//  WYKit_Example
//
//  Created by yingwang on 2017/12/21.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//

#import "WYLikeButton.h"
#import "WYCheckinProgressView.h"
#import "WYViewsPart5ViewController.h"

@interface WYViewsPart5ViewController ()

@property (nonatomic, strong) WYCheckinProgressView *progressView;

@property (nonatomic, strong) WYLikeButton *likeButton;

@end

@implementation WYViewsPart5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubviews];
}

- (void)setupSubviews {
    
    // WYCheckinProgressView
    
    CGRect frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)/2-100, 100, 100);
    self.progressView = [[WYCheckinProgressView alloc] initWithFrame:frame];
    [self.view addSubview:self.progressView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //  Set default state
    [self.progressView reloadWithState:kWYCheckinProgressViewWaitCheckinState];
    
    __weak WYViewsPart5ViewController *weakSelf = self;
    self.progressView.handleButtonAction = ^{
        [weakSelf.progressView startAnimationToDay:4 progress:4/7.0];
    };
    
    // WYLikeButton
    frame = CGRectMake(CGRectGetWidth(self.view.bounds)/2-60, CGRectGetHeight(self.view.bounds)/2+50, 120, 30);
    self.likeButton = [WYLikeButton buttonWithType:UIButtonTypeCustom];
    [self.likeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.likeButton setImage:[UIImage imageNamed:@"img_demo_like_s"] forState:UIControlStateSelected];
    [self.likeButton setImage:[UIImage imageNamed:@"img_demo_like_u"] forState:UIControlStateNormal];
    self.likeButton.frame = frame;
    [self.view addSubview:self.likeButton];
    
    [self.likeButton changeNumberOfLike:9999 animated:NO];
    
    [self.likeButton addTarget:self
                        action:@selector(handleLikeButtonAction)
              forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleLikeButtonAction {
    if (!self.likeButton.isSelected) {
        self.likeButton.selected = YES;
        [self.likeButton changeNumberOfLike:11111 animated:YES];
    } else {
        self.likeButton.selected = NO;
        [self.likeButton changeNumberOfLike:9999 animated:YES];
    }
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
