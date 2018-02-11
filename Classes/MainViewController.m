//
//  MainViewController.m
//  databaseTest
//
//  Created by mac on 2017/9/15.
//  Copyright © 2017年 chinasns. All rights reserved.
//

#import "MainViewController.h"
#import "PersonDao.h"
#import "Person.h"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *uidLabel;

@end

@implementation MainViewController
{
    PersonDao *dao;
    int nameIndex;
    
    NSArray *arr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 50;
    self.tableView.editing = YES;
    
    int uid = [[[NSUserDefaults standardUserDefaults] objectForKey:@"login_userid"] intValue];
    self.uidLabel.text = [NSString stringWithFormat:@"当前用户：%d",uid];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(onLogoutClick:)];
    self.navigationController.navigationBar.backItem.backBarButtonItem = backItem;
    
    dao = [PersonDao sharedInstance];
    
    
    arr = [dao listAllPerson];
    
    nameIndex = (int)arr.count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onLogoutClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"login_userid"];
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onAddClicked:(id)sender {
    Person *p = [[Person alloc] init];
    p.name = [NSString stringWithFormat:@"name_%d",nameIndex];
    p.address = [NSString stringWithFormat:@"address_%d",nameIndex];
    p.gender = 1;
    [dao insertPerson:p block:^(BOOL b) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            nameIndex++;
            arr = [dao listAllPerson];
            [self.tableView reloadData];
        });
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    Person *p = arr[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@,%@",p.name,p.address];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *p = arr[indexPath.row];
    [dao deletePersonWithId:p.ID block:nil];
    arr = [dao listAllPerson];
    [self.tableView reloadData];
}

@end
