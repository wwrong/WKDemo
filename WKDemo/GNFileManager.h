//
//  GNFileManager.h
//  WKDemo
//
//  Created by Guan Nan Wang on 16/6/22.
//  Copyright © 2016年 Guan Nan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GNFileManager : NSObject


@property (nonatomic,strong) NSURL *htmlURL;
@property (nonatomic,strong) NSURL *resourceURL;
-(void)addResources;
-(void)checkResources;

@end
