//
//  UserSettingsTableViewController.h
//  UITableViewStaticCells
//
//  Created by EnzoF on 11.09.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum{
    UserSettingsTableViewControllerTextFieldFirstName = 0,
    UserSettingsTableViewControllerTextFieldLastName  = 1,
    UserSettingsTableViewControllerTextFieldLogin     = 2,
    UserSettingsTableViewControllerTextFieldPassword  = 3,
    UserSettingsTableViewControllerTextFieldAge       = 4,
    UserSettingsTableViewControllerTextFieldTel       = 5,
    UserSettingsTableViewControllerTextFieldEmail     = 6
}UserSettingsTableViewControllerTextFieldType;
@interface UserSettingsTableViewController : UITableViewController
@property(strong,nonatomic)IBOutletCollection(UITextField) NSArray *arrayTextFields;
@property(strong,nonatomic)IBOutletCollection(UILabel) NSArray *arrayLabels;
-(IBAction)actionChangeTextLabel:(UITextField*)sender;
@end
