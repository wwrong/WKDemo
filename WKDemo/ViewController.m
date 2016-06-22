//
//  ViewController.m
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/22.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//

#import "ViewController.h"
#import "GNFileManager.h"

@interface ViewController ()
@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) NSURL *htmlURL;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView = [[WKWebView alloc]initWithFrame:self.view.bounds];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    GNFileManager *manager = [[GNFileManager alloc]init];
    [manager addResources];
    self.htmlURL = manager.htmlURL;
    NSString *str = [NSString stringWithContentsOfURL:self.htmlURL encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:str baseURL:manager.resourceURL];

    
    
    
//    NSURL *url = [self fileURLForBuggyWKWebView8:[[NSBundle mainBundle] URLForResource:@"index" withExtension:@"html"]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];

    NSString *bunPath =  [[NSBundle mainBundle]bundlePath];
    NSString *wPath = [bunPath stringByAppendingPathComponent:@"www/"];
    NSLog(@"\n www path  is %@ \n",wPath);
    NSArray *resourceArray = [self allFilesAtPath:wPath];
    NSLog(@"the array is \n   %@   \n",resourceArray);
    
    NSURL *css = [self fileURLForBuggyWKWebView8:resourceArray];

    if (self.htmlURL != nil) {
    }
    else{
        NSLog(@"html未找到");
    }
    
//    NSString *str = [NSString stringWithContentsOfURL:self.htmlURL encoding:NSUTF8StringEncoding error:nil];
    
//    [self.webView loadHTMLString:str baseURL:css];

}




- (NSURL *)fileURLForBuggyWKWebView8:(NSArray *)fileURL {
    NSFileManager *fileManager= [NSFileManager defaultManager];
    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    for (NSString *cssStr in fileURL) {
  
        
        NSLog(@"temDirURL is %@",temDirURL);
        NSURL *dstURL = [temDirURL URLByAppendingPathComponent:cssStr.lastPathComponent];
        NSLog(@"dstURL is %@",dstURL);
        // Now copy given file to the temp directory
        
        NSString *cssURLStr = [@"file://" stringByAppendingString:cssStr];
        [fileManager removeItemAtURL:dstURL error:nil];
        [fileManager copyItemAtURL:[NSURL URLWithString:cssURLStr] toURL:dstURL error:nil];
        if ([cssStr.lastPathComponent containsString:@"html"]) {
            NSLog(@"\n bingo %@\n",cssStr.lastPathComponent);
            self.htmlURL = [NSURL URLWithString:cssURLStr];
            NSLog(@"\nand the html is %@ \n",self.htmlURL);
        } 
        
    }
    return temDirURL;
}



//- (NSURL *)fileURLForBuggyWKWebView8:(NSArray *)fileURL {
//    NSFileManager *fileManager= [NSFileManager defaultManager];
//    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
//    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    for (NSURL *cssURL in fileURL) {
//        
//        NSLog(@"temDirURL is %@",temDirURL);
//        NSURL *dstURL = [temDirURL URLByAppendingPathComponent:cssURL.lastPathComponent];
//        NSLog(@"dstURL is %@",dstURL);
//        // Now copy given file to the temp directory
//        [fileManager removeItemAtURL:dstURL error:nil];
//        [fileManager copyItemAtURL:cssURL toURL:dstURL error:nil];
//
//    }
//         return temDirURL;
//}




- (NSArray*) allFilesAtPath:(NSString*) dirString {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSArray* tempArray = [fileMgr contentsOfDirectoryAtPath:dirString error:nil];
    
    for (NSString* fileName in tempArray) {
        
        BOOL flag = YES;
        
        NSString* fullPath = [dirString stringByAppendingPathComponent:fileName];
        
        if ([fileMgr fileExistsAtPath:fullPath isDirectory:&flag]) {
            
            if (!flag) {
                
                [array addObject:fullPath];
                
            }
            
        }
        
    }
    
    return array;
    
}




//- (NSURL *)fileURLForBuggyWKWebView8:(NSURL *)fileURL {
//    NSError *error = nil;
//    if (!fileURL.fileURL || ![fileURL checkResourceIsReachableAndReturnError:&error]) {
//        return nil;
//    }
//    // Create "/temp/www" directory
//    NSFileManager *fileManager= [NSFileManager defaultManager];
//    NSURL *temDirURL = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:@"www"];
//    [fileManager createDirectoryAtURL:temDirURL withIntermediateDirectories:YES attributes:nil error:&error];
//    NSLog(@"temDirURL is %@",temDirURL);
//    NSURL *dstURL = [temDirURL URLByAppendingPathComponent:fileURL.lastPathComponent];
//    NSLog(@"dstURL is %@",dstURL);
//    // Now copy given file to the temp directory
//    [fileManager removeItemAtURL:dstURL error:&error];
//    [fileManager copyItemAtURL:fileURL toURL:dstURL error:&error];
////    NSURL *cssDstURL = [temDirURL URLByAppendingPathComponent:@"/index.css"];
//////    NSLog(@"\nand %@",cssDstURL);
////    NSURL *cssURL = [[NSBundle mainBundle]URLForResource:@"index" withExtension:@"css"];
////    [fileManager removeItemAtURL:cssDstURL error:nil];
////    [fileManager copyItemAtURL:cssURL toURL:cssDstURL error:nil];
////    
//    // Files in "/temp/www" load flawlesly :)
//    return dstURL;
//}



-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//直接读取文件夹中所有文件    ---accomplished

//新建一个临时目录，里面有备份，move进www文件夹，如果成功删除备份，如果不成功就把备份的拷进www文件夹。

@end
