//
//  WYMainIntroductionRichTextView+WYParser.m
//  WYKit
//
//  Created by yingwang on 2017/4/6.
//  Copyright © 2017年 GeorgeWang03. All rights reserved.
//
//  文章解析器
//

#import "WYMainIntroductionRichTextView+WYParser.h"

@interface WYMainIntroductionRichTextView ()

@end

static NSString *defaultImageIdentifyPrefix = @"WYMainIntroductionRichTextViewImage";

@implementation WYMainIntroductionRichTextView(WYParser)

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
                           error:(NSError *__autoreleasing *)error {
    
    if (!htmlString || !htmlString.length) return @[];
    
    // 0. 定义
    __block NSInteger totalIdentifyLength = 0;
    NSMutableArray *images = [NSMutableArray array];
    NSMutableString *operateString = [NSMutableString stringWithString:htmlString];
    
    // 1. 先寻找<img>标签
    NSString *patternString = @"<img [^>]*src=\"([^\"]+)\"[^>]*width=\"([^\"]+)\"[^>]*>";//@"<img [^>]*src=\"([^\"]+)\"[^>]*>";
    NSRange range = NSMakeRange(0, operateString.length);
    
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:patternString
                                                                          options:0
                                                                            error:error];
    if (*error) return images;
    
    NSArray *results = [regx matchesInString:operateString
                                     options:0
                                       range:range];
    
    // 2. 替换<img>标签 并 生成Image模型
    //      注意这里从后往前遍历和替换
    [results enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult* match, NSUInteger idx, BOOL * _Nonnull stop) {
                                  
                                  WYMainRichTextViewImage *image = [[WYMainRichTextViewImage alloc] init];
                                  image.shouldResizeAfterLoading = YES;
                                  image.widthPercentage = 0.8;
                                  image.size = CGSizeMake(maxImageWidth, 0.618*maxImageWidth);
                                  image.margin = UIEdgeInsetsMake(0, 0, 15, 0);
                                  
                                  NSInteger numberOfRange = match.numberOfRanges;
                                  
                                  if (numberOfRange > 2) {
                                      NSString *widthString = [operateString substringWithRange:[match rangeAtIndex:2]];
                                      CGFloat widthPercentage = [widthString floatValue]/100.f;
                                      image.widthPercentage = widthPercentage;
                                  }
                                  
                                  if (numberOfRange > 1) {
                                      NSString *imageURL = [operateString substringWithRange:[match rangeAtIndex:1]];
                                      image.url = imageURL;
                                  }
                                  
                                  if (numberOfRange > 0) {
                                      NSString *identify = [NSString stringWithFormat:@"%@%lu", defaultImageIdentifyPrefix, idx];
                                      image.identify = identify;
                                      totalIdentifyLength += identify.length;
                                      [operateString replaceCharactersInRange:[match range]
                                                                   withString:identify];
                                  }
                                  
                                  [images insertObject:image atIndex:0];
                              }];
    
    
    
    // 3. 生成NSMutableAttributeString
    NSData *opData = [operateString dataUsingEncoding:NSUTF16StringEncoding];
    NSMutableAttributedString *opAttributeString = [[NSMutableAttributedString alloc] initWithData:opData
                                                                                           options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                                documentAttributes:nil
                                                                                             error:error];
    if (*error) return images;
    
    // 4.去除连续换行符，避免过大间隔
    
    // 5. 去除图片标示，并计算出image占位符的range
    unichar c = 0xFFFC;
    NSString *locChar = [NSString stringWithCharacters:&c length:1];
    
    // 逆向遍历
    [images enumerateObjectsWithOptions:NSEnumerationReverse
                             usingBlock:^(WYMainRichTextViewImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
                                 
                                 
                                 // image.identify.length-1，因为最终的占位符locChar长度为1
                                 totalIdentifyLength -= (image.identify.length);
                                 
                                 NSRange targetRange = [opAttributeString.string rangeOfString:image.identify];
                                 // 去除多余换行符
                                 NSInteger startIdx = targetRange.location-1;
                                 if (startIdx <= opAttributeString.length
                                     && [opAttributeString.string characterAtIndex:startIdx] == '\n') {
                                     // 跳过第一个'\n'，保留一个做换行符
                                     --startIdx;
                                     while (startIdx >= 0 && [opAttributeString.string characterAtIndex:startIdx] == '\n') {
                                         [opAttributeString replaceCharactersInRange:NSMakeRange(startIdx, 1) withString:@""];
                                         startIdx--;
                                     }
                                     // 如果文本第一个字符是\n，那么也替换掉
                                     if (startIdx+1 == 0) {
                                         [opAttributeString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
                                         startIdx = targetRange.length;
                                     } else {
                                         startIdx += (2+targetRange.length);
                                     }
                                     
                                 } else {
                                     startIdx += (1+targetRange.length);
                                 }
                                 
                                 while (startIdx <= opAttributeString.length
                                        && [opAttributeString.string characterAtIndex:startIdx] == '\n') {
                                     [opAttributeString replaceCharactersInRange:NSMakeRange(startIdx, 1) withString:@""];
                                 }
                                 
                                 targetRange = [opAttributeString.string rangeOfString:image.identify];
                                 
                                 // 替换原始identify为空格
                                 // targetRange.location 要 减去前面所有imageIdentify的长度
                                 if (targetRange.location != NSNotFound) {
                                     if (targetRange.location+targetRange.length < opAttributeString.length) {
                                         image.range = NSMakeRange(targetRange.location-totalIdentifyLength, 1);
                                         [opAttributeString replaceCharactersInRange:targetRange
                                                                          withString:@""];
                                     } else {
                                         // 如果是文本最后
                                         image.range = NSMakeRange(targetRange.location-totalIdentifyLength+1, 1);
                                         [opAttributeString replaceCharactersInRange:targetRange
                                                                          withString:[NSString stringWithFormat:@"\n%@", locChar]];
                                     }
                                 }
                             }];
    
    // 5. 成功
    *attributeString = opAttributeString;
    return images;
}

@end

void import_WYMainIntroductionRichTextView_WYParser(){}
