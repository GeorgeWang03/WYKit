//
//  WYMainIntroductionRichTextView+WYParser.h
//  WYKit
//
//  Created by yingwang on 2017/4/6.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  文章解析器
//

#import <UIKit/UIKit.h>
#import "WYMainIntroductionRichTextView.h"

@interface WYMainIntroductionRichTextView(WYParser)

/**
 寻找html中的<img>标签，并生成WYMainRichTextViewImage模型
 同时生成attributeString

 @param htmlString 源html
 @param attributeString 外部引用，有生成结果
 @param maxImageWidth 最大图片宽度
 @param options NSAttributeString的属性键值对
 @return 图片模型数组
 */
+ (NSArray *)parseImagesFromHTML:(NSString *)htmlString
                 attributeString:(NSMutableAttributedString **)attributeString
                   maxImageWidth:(CGFloat)maxImageWidth
                         options:(NSDictionary *)options
                           error:(NSError **)error;

@end

void import_WYMainIntroductionRichTextView_WYParser();
