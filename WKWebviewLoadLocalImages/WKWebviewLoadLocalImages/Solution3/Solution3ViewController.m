//
//  Solution3ViewController.m
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/22.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "Solution3ViewController.h"

#import <WebKit/WebKit.h>

#import "ImageDownloader.h"
#import "NSString+md5.h"
#import "NSString+imageURLsInHTML.h"

@interface Solution3ViewController () <WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation Solution3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"方案3：使用base64图片数据";

    [self.view addSubview:self.webView];

    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"index3" withExtension:@"html"];
    
    __block NSString *html = [[NSString alloc] initWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *imageurlArray = [html imageURLs];
    
    NSString *imageUrl = [imageurlArray firstObject];
    // 下载图片
    [ImageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        UIImage *image = [UIImage imageWithData:data];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
       
        NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@", [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
                                                   
        // url替换成本图片base64数据
        html = [html stringByReplacingOccurrencesOfString:imageUrl withString:imageSource];
       
        dispatch_async(dispatch_get_main_queue(), ^{
            // 加载html文件
            [self.webView loadHTMLString:html baseURL:nil];
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
