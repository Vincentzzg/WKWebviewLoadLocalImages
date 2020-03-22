//
//  ViewController.m
//  WKWebviewLoadLocalImages
//
//  Created by 周中广 on 2020/3/20.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "Solution1ViewController.h"

#import <WebKit/WebKit.h>

#import "ImageDownloader.h"
#import "NSString+md5.h"
#import "NSString+imageURLsInHTML.h"
#import "NSURL+chageScheme.h"

@interface Solution1ViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation Solution1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"方案1：资源放到沙盒tmp文件夹下";
    
    [self.view addSubview:self.webView];
    
    NSURL *htmlFilePath = [[NSBundle mainBundle] URLForResource:@"index1" withExtension:@"html"];
    
    NSString *html = [[NSString alloc] initWithContentsOfURL:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *imageurlArray = [html imageURLs];
    
    dispatch_group_t group = dispatch_group_create();
    
    /* ======================= 第一张图，沙盒tmp目录下 ================================*/
    
    NSString *imageUrl = [imageurlArray objectAtIndex:0];
    NSString *localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[imageUrl md5]];
    NSURL *localPathURL = [NSURL fileURLWithPath:localPath];
    // 替换成沙盒路径：file:///****
    html = [html stringByReplacingOccurrencesOfString:imageUrl withString:localPathURL.absoluteString];

    // 异步下载图片
    dispatch_group_enter(group);
    [ImageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        // 写入沙盒
        if (![data writeToFile:localPath atomically:NO]) {
           NSLog(@"图片写入本地失败：%@\n", localPath);
        } else {
            NSLog(@"图片写入本地成功：%@\n", localPath);
        }
        dispatch_group_leave(group);
    }];
    
    
    /* ======================= 第二张图，沙盒cache目录下 ================================*/

    NSString *imageUrl2 = [imageurlArray objectAtIndex:1];
    // 只有tmp文件夹中的图片可以加载，其他目录下的图片都不能加载
    NSString *cachesDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];

    NSString *localPath2 = [cachesDir stringByAppendingPathComponent:[imageUrl2 md5]];
    NSURL *localPathURL2 = [NSURL fileURLWithPath:localPath2];
    // 替换成沙盒路径：file:///****
    html = [html stringByReplacingOccurrencesOfString:imageUrl2 withString:localPathURL2.absoluteString];

    dispatch_group_enter(group);
    // 异步下载图片
    [ImageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl2] completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        // 写入沙盒
        if (![data writeToFile:localPath2 atomically:NO]) {
           NSLog(@"图片写入本地失败：%@\n", localPath2);
        } else {
            NSLog(@"图片写入本地成功：%@\n", localPath2);
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"加载的html:\n%@\n", html);
//        // 加载htmlString
        [self.webView loadHTMLString:html baseURL:[NSURL URLWithString:@"file://"]];
    });
}

- (void)dealloc {
    // 清空数据，保证测试效果
    NSString *docPath = NSTemporaryDirectory();
    [[NSFileManager defaultManager] removeItemAtPath:docPath error:nil];
}

#pragma mark - private method

// 图片本地存储的地址
- (NSString *)localPathForImageUrl:(NSString *)imageUrl docName:(NSString *)docName {
    NSString *docPath = [NSTemporaryDirectory() stringByAppendingPathComponent:docName];
    //创建文件管理对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docPath]) {//文件夹不存在，创建文件夹
        NSError *error = nil;
        [fileManager createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:@{} error:&error];
        if (error) {
            NSLog(@"创建文件夹失败:%@", error);
        }
    }
    
    NSString *localPath = [docPath stringByAppendingPathComponent:[imageUrl md5]];
    
    return localPath;
}


#pragma mark - setter and getter

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        
        _webView = [[WKWebView alloc] initWithFrame:[self.view frame] configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    
    return _webView;
}

@end
