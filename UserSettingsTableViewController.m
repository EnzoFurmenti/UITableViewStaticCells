//
//  UserSettingsTableViewController.m
//  UITableViewStaticCells
//
//  Created by EnzoF on 11.09.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "UserSettingsTableViewController.h"

@interface UserSettingsTableViewController ()<UITextFieldDelegate>

@end
static NSString *kSettingFirstName   = @"firstName";
static NSString *kSettingLastName    = @"ladtName";
static NSString *kSettingLogin       = @"login";
static NSString *kSettingPassword    = @"password";
static NSString *kSettingAge         = @"age";
static NSString *kSettingPhoneNumber = @"phoneNumber";
static NSString *kSettingEmail       = @"email";

@implementation UserSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.edgesForExtendedLayout=UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars=NO;
//    self.automaticallyAdjustsScrollViewInsets=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationChangeTextInTextField:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    [self loadUserSettings];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag != UserSettingsTableViewControllerTextFieldEmail)
    {
        UITextField *currentTextField = [self.arrayTextFields objectAtIndex:textField.tag + 1];
        [currentTextField becomeFirstResponder];
    }
    else
    {
        UITextField *currentTextField = [self.arrayTextFields objectAtIndex:textField.tag];
        [currentTextField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    UILabel *currentLabel = [self.arrayLabels objectAtIndex:textField.tag];
    currentLabel.text = @"";
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if((textField.tag == UserSettingsTableViewControllerTextFieldTel))
    {
        NSString *newString = [self getValidNumberString:textField.text withRange:range withString:string];
        if(newString)
        {
            NSString *resultString =  [self createTeleStringFromString:newString];
            if(resultString)
            {
                textField.text = resultString;
                UILabel *currentLabel = [self.arrayLabels objectAtIndex:textField.tag];
                currentLabel.text = resultString;
                
            }
        }
        
        return NO;
    }
    
    if(textField.tag == UserSettingsTableViewControllerTextFieldEmail)
    {
        NSString *resultString = [self separateEmailString:textField.text withRange:range withString:string];
        if(resultString)
        {
            textField.text = resultString;
            UILabel *currentLabel = [self.arrayLabels objectAtIndex:textField.tag];
            currentLabel.text = resultString;
        }
        return NO;
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self saveUserSettings];
}

#pragma mark - ActionUILabel
-(IBAction)actionChangeTextLabel:(UITextField*)sender{
    UILabel *currentLabel = [self.arrayLabels objectAtIndex:sender.tag];
    currentLabel.text = sender.text;
}


#pragma mark - UITextFieldNotification

-(void)notificationChangeTextInTextField:(NSNotification*)notification{
    for (UITextField *currentTextField in self.arrayTextFields)
    {
        if([currentTextField isFirstResponder])
        {
//            if(currentTextField.tag == UserSettingsTableViewControllerTextFieldTel)
//            {
//                UILabel *currentLabel = [self.arrayLabels objectAtIndex:currentTextField.tag];
//                currentLabel.text = currentTextField.text;
//            }
//            
//            if(currentTextField.tag == UserSettingsTableViewControllerTextFieldEmail)
//            {
//                UILabel *currentLabel = [self.arrayLabels objectAtIndex:currentTextField.tag];
//                currentLabel.text = currentTextField.text;
//            }
        }
    }
    
}


#pragma mark - metods for TeleString
-(NSString*)getValidNumberString:(NSString*)currentString withRange:(NSRange)range withString:(NSString*)string{
    NSCharacterSet *validSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray *component = [string componentsSeparatedByCharactersInSet:validSet];
    NSString *newString;
    if(!([component count] > 1))
    {
        newString = [currentString stringByReplacingCharactersInRange:range withString:string];
        NSArray *validComponent = [newString componentsSeparatedByCharactersInSet:validSet];
        newString = [validComponent componentsJoinedByString:@""];
    }
    return newString;
}

-(NSString*)createTeleStringFromString:(NSString*)string{
    static const int localNumberMaxLength = 7;
    static const int areaCodeMaxLength = 3;
    static const int countrycCodeMaxLength = 3;
    NSInteger queueSymbolsBeforeDash = 3;
    NSMutableString *resultString = [NSMutableString string];
    if([string length] >localNumberMaxLength + areaCodeMaxLength + countrycCodeMaxLength)
    {
        resultString = nil;
    }
    else
    {
        NSInteger localNumberLength = MIN([string length],localNumberMaxLength);
        if(localNumberLength > 0)
        {
            NSString *number = [string substringFromIndex:(int)[string length] - localNumberLength];
            [resultString appendString:number];
            if([resultString length] > queueSymbolsBeforeDash)
            {
                [resultString insertString:@"-" atIndex:queueSymbolsBeforeDash];
            }
        }
        if([string length] > localNumberMaxLength)
        {
            NSInteger areaCodeLength = MIN((int)[string length] - localNumberMaxLength,areaCodeMaxLength);
            NSRange areaRange = NSMakeRange((int)[string length] - localNumberMaxLength - areaCodeLength, areaCodeLength);
            NSString *area = [string substringWithRange:areaRange];
            area = [NSString stringWithFormat:@"(%@)",area];
            [resultString insertString:area atIndex:0];
        }
        
        if([string length] > localNumberMaxLength + areaCodeMaxLength)
        {
            NSInteger countryCodeLength = MIN((int)[string length] - localNumberMaxLength - areaCodeMaxLength,countrycCodeMaxLength);
            NSRange countryCodeRange = NSMakeRange(0, countryCodeLength);
            NSString *countryCode = [string substringWithRange:countryCodeRange];
            countryCode = [NSString stringWithFormat:@"+%@",countryCode];
            [resultString insertString:countryCode atIndex:0];
        }
    }
    return resultString;
}

#pragma mark - metods for TextFieldEmail
-(NSString* _Nullable)separateEmailString:(NSString*)emailStr withRange:(NSRange)range withString:(NSString*)string{
    
    NSString *validCharactersString = @"@!#$%&'*+-/=?^_`{|}~.";
    NSInteger maxLengthEmail = 30;
    NSCharacterSet *numberCharSet = [NSCharacterSet decimalDigitCharacterSet];
    NSMutableCharacterSet *validMutableCharSet = [NSMutableCharacterSet letterCharacterSet];
    [validMutableCharSet formUnionWithCharacterSet:numberCharSet];
    [validMutableCharSet addCharactersInString:validCharactersString];
    [validMutableCharSet invert];
    
    NSArray *component = [string componentsSeparatedByCharactersInSet:validMutableCharSet];
    NSString *newString = nil;
    if(!([component count] > 1))
    {
        newString = [emailStr stringByReplacingCharactersInRange:range withString:string];
        NSArray *componentDog = [newString componentsSeparatedByString:@"@"];
        if(([componentDog count] <= 2)&
           ![newString containsString:@".."]&
           ([newString length] < maxLengthEmail))
        {
            NSArray *validComponent = [newString componentsSeparatedByCharactersInSet:validMutableCharSet];
            newString = [validComponent componentsJoinedByString:@""];
        }
        else
        {
            newString = nil;
        }
    }
    return newString;
}


#pragma mark - save and load NSUserDefaults

-(void)saveUserSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (UITextField*currentTextField in self.arrayTextFields)
    {
        switch (currentTextField.tag) {
            case UserSettingsTableViewControllerTextFieldFirstName:
                [userDefaults setObject:currentTextField.text forKey:kSettingFirstName];
                break;
            case UserSettingsTableViewControllerTextFieldLastName:
                [userDefaults setObject:currentTextField.text forKey:kSettingLastName];
                break;
            case UserSettingsTableViewControllerTextFieldLogin:
                [userDefaults setObject:currentTextField.text forKey:kSettingLogin];
                break;
            case UserSettingsTableViewControllerTextFieldPassword:
                [userDefaults setObject:currentTextField.text forKey:kSettingPassword];
                break;
            case UserSettingsTableViewControllerTextFieldAge:
                [userDefaults setObject:currentTextField.text forKey:kSettingAge];
                break;
            case UserSettingsTableViewControllerTextFieldTel:
                [userDefaults setObject:currentTextField.text forKey:kSettingPhoneNumber];
                break;
            case UserSettingsTableViewControllerTextFieldEmail:
                [userDefaults setObject:currentTextField.text forKey:kSettingEmail];
                break;
        }
    }
}

-(void)loadUserSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    for (UITextField*currentTextField in self.arrayTextFields)
    {
        switch (currentTextField.tag) {
            case UserSettingsTableViewControllerTextFieldFirstName:
                currentTextField.text = [userDefaults objectForKey:kSettingFirstName];
                break;
            case UserSettingsTableViewControllerTextFieldLastName:
                currentTextField.text = [userDefaults objectForKey:kSettingLastName];
                break;
            case UserSettingsTableViewControllerTextFieldLogin:
                currentTextField.text = [userDefaults objectForKey:kSettingLogin];
                break;
            case UserSettingsTableViewControllerTextFieldPassword:
                currentTextField.text = [userDefaults objectForKey:kSettingPassword];
                break;
            case UserSettingsTableViewControllerTextFieldAge:
                currentTextField.text = [userDefaults objectForKey:kSettingAge];
                break;
            case UserSettingsTableViewControllerTextFieldTel:
                currentTextField.text = [userDefaults objectForKey:kSettingPhoneNumber];
                break;
            case UserSettingsTableViewControllerTextFieldEmail:
                currentTextField.text = [userDefaults objectForKey:kSettingEmail];
                break;
        }
    }
}

@end
