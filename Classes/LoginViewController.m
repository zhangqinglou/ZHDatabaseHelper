//
//  ViewController.m
//  databaseTest
//
//  Created by mac on 2017/9/14.
//  Copyright © 2017年 chinasns. All rights reserved.
//

#import "LoginViewController.h"
#import "ZHDatabaseHelper.h"
#import "PersonDao.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.accountText.text = @"1001";
    self.pswText.text = @"0000";
    
    [self.navigationController setNavigationBarHidden:YES];
    
    
    //自动登录
    int uid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"login_userid"] intValue];
    if (uid > 0) {
        //进入主界面
        [self performSegueWithIdentifier:@"main_segue" sender:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onLoginClick:(id)sender {
    NSString *account =  self.accountText.text;
    NSString *psw = self.pswText.text;
    
    int uid = -1;
    if ([account isEqualToString:@"1001"] && [psw isEqualToString:@"0000"]) {
        uid = [account intValue];
    }else if([account isEqualToString:@"1002"] && [psw isEqualToString:@"0000"]){
        uid = [account intValue];
    }else if([account isEqualToString:@"1003"] && [psw isEqualToString:@"0000"]){
        uid = [account intValue];
    }
    
    if (uid==-1) {
        //登录失败
        return;
    }
    
    //自动登录
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:uid] forKey:@"login_userid"];
    
    //登录成功，初始化数据库，用户id
    [[ZHDatabaseHelper sharedInstance] createDatabaseWithUID:uid];
    
    //进入主界面
    [self performSegueWithIdentifier:@"main_segue" sender:nil];
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 //- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 //}
 
@end
