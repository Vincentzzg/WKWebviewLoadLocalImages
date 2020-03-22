//
//  ImageDownloader.m
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/21.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "ImageDownloader.h"

@implementation ImageDownloader

+ (void)downloadImageWithURL:(NSURL *)imageURL  completionHandler:(void (^)(NSData *data, NSError *error))completionHandler {
    NSURLRequest *fileUrlRequest = [[NSURLRequest alloc] initWithURL:imageURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:fileUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(data, error);
        }
    }];

    [dataTask resume];
}

@end
