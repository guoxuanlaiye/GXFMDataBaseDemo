//
//  ViewController.m
//  GXFMDataBaseDemo
//
//  Created by yingcan on 17/3/7.
//  Copyright © 2017年 guoxuan. All rights reserved.
//

#import "ViewController.h"
#import "GXFMDatabaseManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary * personData = @{@"userId":@"100000688",
                                  @"name":@"hole",
                                  @"avatar":@"/avatar/1.png",
                                  @"phone":@"18842878603"};
    [[GXFMDatabaseManager shareDBManager] createPersonTable];
    [[GXFMDatabaseManager shareDBManager] savePersonDataWithDict:personData userId:@"100000688"];
    
    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"database.db"];
    NSLog(@"DB路径 ====== %@",path);
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
