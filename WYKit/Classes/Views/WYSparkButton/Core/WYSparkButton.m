//
//  WYSparkButton.m
//  SwiftToObjcDemo
//
//  Created by yingwang on 2016/10/21.
//  Copyright © 2016年 yingwang. All rights reserved.
//

#import "WYSparkButton.h"
#import "WYSparkMainLayer.h"

@interface WYSparkButton ()

@property (nonatomic, strong) WYSparkMainLayer *mainLayer;

@end

@implementation WYSparkButton

- (void)drawRect:(CGRect)rect {
    
    if (!_mainLayer) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        if(_iconNormalColor) attributes[kWYSparkIconNormalColor] = _iconNormalColor;
        if(_iconSelectedColor) attributes[kWYSparkIconSelectedColor] = _iconSelectedColor;
        if(_ringFromColor) attributes[kWYSparkRingFromColor] = _ringFromColor;
        if(_ringToColor) attributes[kWYSparkRingToColor] = _ringToColor;
        if(_firstDotColor) attributes[kWYSparkDotFirstColors] = @[_firstDotColor,_firstDotColor,
                                                                  _firstDotColor,_firstDotColor,
                                                                  _firstDotColor,_firstDotColor,
                                                                  _firstDotColor,_firstDotColor];
        if(_secondDotColor) attributes[kWYSparkDotSecondColors] = @[_secondDotColor,_secondDotColor,
                                                                    _secondDotColor,_secondDotColor,
                                                                    _secondDotColor,_secondDotColor,
                                                                    _secondDotColor,_secondDotColor];
        WYSparkMainLayer *layer = [[WYSparkMainLayer alloc] initWithButton:self
                                                                attributes:attributes];
        _mainLayer = layer;
        [self.layer addSublayer:layer];
        [super addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    
    [super addTarget:target action:action forControlEvents:controlEvents];
    [super addTarget:self action:@selector(handleAction:) forControlEvents:controlEvents];
}

- (void)handleAction:(id)sender {
    self.selected = !self.selected;
    [_mainLayer animationWithSelected:self.selected];
}


@end
