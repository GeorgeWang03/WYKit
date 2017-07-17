//
//  WYTagView.m
//  WYKit
//
//  Created by yingwang on 2017/5/24.
//  Copyright © 2017年 yingwang. All rights reserved.
//
//  标签视图
//

#import "WYTagView.h"

@interface WYTagView ()

@property (nonatomic, strong) NSMutableArray *tagLabels;

@end

@implementation WYTagView

#pragma mark - Intial
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

#pragma mark - Event

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];

    [self reloadData];
}

- (void)reloadData {
    
    [self layoutTagLabels];
}

- (void)layoutTagLabels {
    
    NSInteger count;
    CGFloat c_x, c_y;
    UIEdgeInsets tagInset, contentInset;
    CGSize targetSize;
    CGFloat tagHeight, tagWidth, cTagHeight;
    CGFloat lineSpacing, itemSpacing;
    CGFloat boundsWidth, boundsHeight, contentWidth, contentHeight;
    UILabel *cLabel, *previousLabel;
    CGRect cFrame;
    NSString *cString;
    NSInteger cLen;
    
    count = self.titles.count;
    tagInset = self.tagContentInset;
    contentInset = self.contentInset;
    c_x = contentInset.left; c_y = contentInset.top;
    tagHeight = self.font.pointSize + tagInset.top + tagInset.bottom;
    cTagHeight = tagHeight;
    lineSpacing = self.lineSpacing; itemSpacing = self.itemSpacing;
    boundsWidth = CGRectGetWidth(self.bounds); boundsHeight = CGRectGetHeight(self.bounds);
    contentWidth = boundsWidth - contentInset.left - contentInset.right;
    contentHeight = boundsHeight - contentInset.top - contentInset.bottom;
    
    for (NSInteger idx = 0; idx < MAX(count, self.tagLabels.count); ++idx) {
        if (idx >= self.tagLabels.count) {
            [self.tagLabels addObject:[[UILabel alloc] init]];
        }
        
        cLabel = self.tagLabels[idx];
        cLabel.text = self.titles[idx];
        [self setupLabel:cLabel];
        
        if (idx >= count) {
            [cLabel removeFromSuperview];
            continue;
        }
        
        cString = self.titles[idx];
        cLen = cString.length;
        targetSize = [cLabel textRectForBounds:CGRectMake(0, 0,
                                                          contentWidth-(tagInset.left + tagInset.right),
                                                          CGFLOAT_MAX)
                        limitedToNumberOfLines:0].size;
        tagWidth = targetSize.width + (tagInset.left + tagInset.right);
        // min tag width is 60
        tagWidth = fmax(tagWidth, 50);
        
        cTagHeight = targetSize.height + (tagInset.top + tagInset.bottom);
         
        // if tag frame out of view's bounds in horizontal
        // or the previous label numberOfLine greater than 1
        // start a new tag line and put the current tag close to the left edge
        if (c_x + tagWidth > boundsWidth - contentInset.right
            || CGRectGetHeight(previousLabel.bounds) - cTagHeight > 0.5) {
            c_x = contentInset.left;
            c_y += (CGRectGetHeight(previousLabel.bounds) + lineSpacing);
        }
        
        
        // if label frame out of view's bounds
        // stop layout
        if (c_y + cTagHeight > boundsHeight - contentInset.bottom) {
            break;
        }
        
        cFrame = CGRectMake(c_x, c_y, tagWidth, cTagHeight);
        
        cLabel.frame = cFrame;
        [self addSubview:cLabel];
        
        previousLabel = cLabel;
        c_x += (tagWidth + itemSpacing);
    }
}

- (void)setupLabel:(UILabel *)label {
    
    label.textColor = self.textColor;
    label.font = self.font;
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.borderWidth = .8;
    label.layer.borderColor = self.borderColor.CGColor;
    label.layer.cornerRadius = self.itemCornerRadius;
}

#pragma mark - Getter Setter
- (NSMutableArray *)tagLabels {
    if (!_tagLabels) {
        _tagLabels = [NSMutableArray array];
    }
    return _tagLabels;
}

- (UIFont *)font {
    if (!_font) {
        _font = [UIFont systemFontOfSize:12];
    }
    return _font;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor darkGrayColor];
    }
    return _textColor;
}

- (UIColor *)borderColor {
    if (!_borderColor) {
        _borderColor = [UIColor darkGrayColor];
    }
    return _borderColor;
}

@end
