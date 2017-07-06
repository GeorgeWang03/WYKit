//
//  WYImageSliderViewController.h
//  WYostApp
//
//  Created by yingwang on 2016/11/21.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYImageSliderViewController : UIViewController

@property (nonatomic, strong) NSArray *imageURLs;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) UIImage *placeholderImage;

/**
 图片初始位置
 */
@property (nonatomic) NSInteger initialImageIndex;

@end
