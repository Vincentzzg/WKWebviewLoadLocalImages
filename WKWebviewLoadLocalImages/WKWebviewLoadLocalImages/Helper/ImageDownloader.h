//
//  ImageDownloader.h
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/21.
//  Copyright © 2020 周中广. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 图片下载类
@interface ImageDownloader : NSObject

+ (void)downloadImageWithURL:(NSURL *)imageURL  completionHandler:(void (^)(NSData *data, NSError *error))completionHandler;

@end

NS_ASSUME_NONNULL_END
