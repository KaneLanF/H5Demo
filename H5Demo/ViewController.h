//
//  ViewController.h
//  H5Demo
//
//  Created by kane on 2018/8/6.
//  Copyright © 2018年 JQX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlTF;
@property (weak, nonatomic) IBOutlet UIButton *openBtn;
@property (weak, nonatomic) IBOutlet UITextField *insideTF;
@property (weak, nonatomic) IBOutlet UITextField *externalTF;
@property (weak, nonatomic) IBOutlet UITextField *customTF;

@property (weak, nonatomic) IBOutlet UISwitch *insideSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *externalSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *customSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *logSwitch;
@property (weak, nonatomic) IBOutlet UIButton *httpBtn;
@property (weak, nonatomic) IBOutlet UIButton *httpsBtn;
@property (weak, nonatomic) IBOutlet UITableView *historyTable;



@end

