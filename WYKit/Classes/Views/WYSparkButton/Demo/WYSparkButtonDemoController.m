//
//  WYsparkButtonDemoController.m
//  WYKit
//
//  Created by yingwang on 2016/10/22.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYSparkButtonDemoController.h"
#import "UIButton+WYSpark.h"
#import "WYSparkButton.h"
#import "WYMorphingLabel.h"
#import "WYPodDefine.h"

@interface WYSparkButtonDemoController ()
//@property (weak, nonatomic) IBOutlet WYSparkButton *privateButton; //连接到ib上的button outlet
@end

@implementation WYSparkButtonDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.view.bounds);
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(boundsWidth/2-20, 100, 40, 40)];
    [button setImage:WYPodImageNamed(@"ic_basic_cir_s")
            forState:UIControlStateNormal]; // tips:这个一定要设置UIControlStateNormal
    [self.view addSubview:button];
    [button wy_addTarget:self action:@selector(handleAction) forControlEvents:UIControlEventTouchUpInside animationAttributes:nil];
    
    // xib 设置
//    [_privateButton addTarget:self action:@selector(handleAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleAction {
    NSLog(@"target tap");
}

@end
