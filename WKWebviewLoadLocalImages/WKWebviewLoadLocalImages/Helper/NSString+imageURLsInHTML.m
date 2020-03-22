//
//  NSString+imageURLsInHTML.m
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/22.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "NSString+imageURLsInHTML.h"

@implementation NSString (imageURLsInHTML)

- (NSArray *)imageURLs {
    // 正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<(img|IMG)(.*?)(/>|></img>|>)" options:NSRegularExpressionAllowCommentsAndWhitespace error:nil];
    NSArray *result = [regex matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    NSMutableArray *urlArray = [NSMutableArray new];
        
    for (NSTextCheckingResult *item in result) {
        NSString *imageTag = [self substringWithRange:[item rangeAtIndex:0]];

        // 从图片标签中提取imageURL
        NSString *imageUrl = [self imageURLFromImageTag:imageTag];
        if (imageUrl && imageUrl.length > 0) {
            [urlArray addObject:imageUrl];
        }
        
        NSLog(@"正确解析出来的SRC为：%@\n", imageUrl);
    }
    
    return urlArray;
}

// 从图片标签中提取imageURL
- (NSString *)imageURLFromImageTag:(NSString *)imageTag {
    NSArray *tmpArray = nil;
    if ([imageTag rangeOfString:@"src=\""].location != NSNotFound) {
        tmpArray = [imageTag componentsSeparatedByString:@"src=\""];
    } else if ([imageTag rangeOfString:@"src="].location != NSNotFound) {
        tmpArray = [imageTag componentsSeparatedByString:@"src="];
    }

    if (tmpArray.count >= 2) {
        NSString *src = tmpArray[1];

        NSUInteger loc = [src rangeOfString:@"\""].location;
        if (loc != NSNotFound) {
            src = [src substringToIndex:loc];

            return src;
        }
    }
    
    return nil;
}

@end
