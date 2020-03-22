//
//  Solution4ViewController.m
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/22.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "Solution4ViewController.h"

#import <WebKit/WebKit.h>

#import "ImageDownloader.h"
#import "NSString+md5.h"
#import "NSString+imageURLsInHTML.h"
#import "NSURL+chageScheme.h"

@interface Solution4ViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation Solution4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"方案4：html文件和图片放在同一个目录下";
    [self.view addSubview:self.webView];

    NSURL *bundlePath = [[NSBundle mainBundle] URLForResource:@"index4" withExtension:@"html"];
    
    NSString *html = [[NSString alloc] initWithContentsOfURL:bundlePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *imageurlArray = [html imageURLs];
    NSString *imageUrl = [imageurlArray firstObject];
        
    // cache
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *imagePath = [docPath stringByAppendingPathComponent:[imageUrl md5]];
    NSURL *imagePathURL = [NSURL fileURLWithPath:imagePath];
    // 替换成沙盒路径：file:///****
    html = [html stringByReplacingOccurrencesOfString:imageUrl withString:imagePathURL.absoluteString];

    // html保存到跟图片同一目录下
    NSError *error;
    NSString *htmlPath = [[docPath stringByAppendingPathComponent:@"index4"] stringByAppendingPathExtension:@"html"];
    NSLog(@"写入的HTML：%@", html);
    
    [html writeToFile:htmlPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"html写入失败");
    } else {
        NSLog(@"html写入成功");
    }
    
    // 异步下载图片
    [ImageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        // 写入沙盒
        if (![data writeToFile:imagePath atomically:NO]) {
           NSLog(@"图片写入本地失败：%@\n", imagePath);
        } else {
            NSLog(@"图片写入本地成功：%@\n", imagePath);
        }
        
        NSURL *localFileURL = [NSURL fileURLWithPath:htmlPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 下面两种方式都可以正常加载图片
            // loadRequest可以正常加载
//            [self.webView loadRequest:[NSURLRequest requestWithURL:localFileURL]];
            
            /*
             下面这种方式必须指定准确的文件地址或者图片文件所在的目录才能正常加载
             */
            [self.webView loadFileURL:localFileURL allowingReadAccessToURL:[localFileURL URLByDeletingLastPathComponent]];
        });
    }];
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
