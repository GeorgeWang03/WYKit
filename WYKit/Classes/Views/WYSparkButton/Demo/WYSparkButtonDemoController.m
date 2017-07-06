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

@interface WYSparkButtonDemoController ()
//@property (weak, nonatomic) IBOutlet WYSparkButton *privateButton; //连接到ib上的button outlet
@end

@implementation WYSparkButtonDemoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat boundsWidth = CGRectGetWidth(self.view.bounds);
    CGFloat boundsHeight = CGRectGetHeight(self.view.bounds);
    
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(boundsWidth/2-50, boundsHeight/2, 40, 40)];
    [button setImage:[UIImage imageNamed:@"app_ic_tabbar_find_on"]
            forState:UIControlStateNormal]; // tips:这个一定要设置UIControlStateNormal
    [self.view addSubview:button];
    [button wy_addTarget:self action:@selector(handleAction) forControlEvents:UIControlEventTouchUpInside animationAttributes:nil];
    
    WYMorphingLabel *label = [[WYMorphingLabel alloc] initWithFrame:CGRectMake(20, 0, 300, 300)];
    label.text = @"ABCDEF";
    label.font = [UIFont systemFontOfSize:80];
    [self.view addSubview:label];
    label.repetable = YES;
    [label startAnimation];
    
    // xib 设置
//    [_privateButton addTarget:self action:@selector(handleAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)handleAction {
    NSLog(@"target tap");
}

@end
