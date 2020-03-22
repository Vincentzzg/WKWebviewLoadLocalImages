//
//  NSString+md5.h
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/21.
//  Copyright © 2020 周中广. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (md5)

/**
 MD5（消息摘要算法，MD5 Message-Digest Algorithm）

 @return
 */
- (NSString *)md5;

@end

NS_ASSUME_NONNULL_END
