//
//  Solution2ViewController.m
//  WKWebviewLoadLocalImages
//
//  Created by zzg on 2020/3/21.
//  Copyright © 2020 周中广. All rights reserved.
//

#import "Solution2ViewController.h"

#import <WebKit/WebKit.h>

#import "ImageDownloader.h"
#import "NSURL+chageScheme.h"
#import "NSString+imageURLsInHTML.h"
#import "NSString+md5.h"

#define MyLocalImageScheme @"localimages"

@interface Solution2ViewController () <WKUIDelegate, WKNavigationDelegate, WKURLSchemeHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *localPath;//缓存用于页面关闭时清空数据

@end

@implementation Solution2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"方案2：设置自定义的scheme";

    [self.view addSubview:self.webView];
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"index2" withExtension:@"html"];
    
    NSString *html = [[NSString alloc] initWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *imageurlArray = [html imageURLs];
    
    NSString *imageUrl = [imageurlArray firstObject];
    self.localPath = [self localPathForImageUrl:imageUrl];
    NSURL *localPathURL = [NSURL fileURLWithPath:self.localPath];
    // 修改scheme
    localPathURL = [localPathURL changeURLScheme:MyLocalImageScheme];
    // url替换成本地地址
    html = [html stringByReplacingOccurrencesOfString:imageUrl withString:localPathURL.absoluteString];
        
    // 下载图片
    [ImageDownloader downloadImageWithURL:[NSURL URLWithString:imageUrl] completionHandler:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        // 写入沙盒
        if (![data writeToFile:self.localPath atomically:NO]) {
           NSLog(@"写入本地失败：%@", self.localPath);
        } else {
            NSLog(@"写入图片成功：%@", self.localPath);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 加载html文件
            [self.webView loadHTMLString:html baseURL:nil];
        });
    }];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    // 清空数据，保证测试效果
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:self.localPath error:&error];
    if (error) {
        NSLog(@"清空数据失败：%@", error);
    } else {
        NSLog(@"清空数据成功");
    }
}

#pragma mark - WKURLSchemeHandler

/*! @abstract Notifies your app to start loading the data for a particular resource
 represented by the URL scheme handler task.
 @param webView The web view invoking the method.
 @param urlSchemeTask The task that your app should start loading data for.
 */
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)) {
    NSURL *requestURL = urlSchemeTask.request.URL;
    NSString *filter = [NSString stringWithFormat:MyLocalImageScheme];

    if (![requestURL.absoluteString containsString:filter]) {
        return;
    }

    NSURL *fileURL = [requestURL changeURLScheme:@"file"];//file是本地文件协议
    NSURLRequest *fileUrlRequest = [[NSURLRequest alloc] initWithURL:fileURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:fileUrlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
       NSURLResponse *response2 = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];
       if (error) {
           [urlSchemeTask didFailWithError:error];
       } else {
           [urlSchemeTask didReceiveResponse:response2];
           [urlSchemeTask didReceiveData:data];
           [urlSchemeTask didFinish];
       }
    }];

    [dataTask resume];
}

/*! @abstract Notifies your app to stop handling a URL scheme handler task.
 @param webView The web view invoking the method.
 @param urlSchemeTask The task that your app should stop handling.
 @discussion After your app is told to stop loading data for a URL scheme handler task
 it must not perform any callbacks for that task.
 An exception will be thrown if any callbacks are made on the URL scheme handler task
 after your app has been told to stop loading for it.
 */
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)) {
    
}

#pragma mark - private method

// 图片本地存储的地址
- (NSString *)localPathForImageUrl:(NSString *)imageUrl {
    // Caches
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    // Library
    //    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    // tmp
//    NSString *docPath = NSTemporaryDirectory();
    NSString *localPath = [docPath stringByAppendingPathComponent:[imageUrl md5]];

    return localPath;
}

#pragma mark - setter and getter

- (WKWebView *)webView {
    if (_webView == nil) {
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        if (@available(iOS 11.0, *)) {
            [configuration setURLSchemeHandler:self forURLScheme:MyLocalImageScheme];
        } else {
            // Fallback on earlier versions
        }
        _webView = [[WKWebView alloc] initWithFrame:[self.view frame] configuration:configuration];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    
    return _webView;
}

@end
