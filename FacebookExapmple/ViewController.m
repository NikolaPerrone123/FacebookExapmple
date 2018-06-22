//
//  ViewController.m
//  FacebookExapmple
//
//  Created by Nikola Popovic on 6/22/18.
//  Copyright © 2018 Nikola Popovic. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setViews];
    [self addGesturUserImage];
}

-(void) addGesturUserImage
{
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setImageAction:)];
    [self.userImage addGestureRecognizer:tapGesture];
    [self.userImage setUserInteractionEnabled:YES];
}

-(void) setViews
{
    self.loginButton.layer.cornerRadius = 15;
    self.shareButton.layer.cornerRadius = 15;
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
}

-(void) getUserEmailAndId{
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    [parameters setValue:@"id,name,email" forKey:@"fields"];
    
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                  id result, NSError *error) {
         NSLog(@"Result %@:", result);
     }];

}

- (IBAction)loginAction:(id)sender
{
    
    // If user logedIn with facebook
    if ([FBSDKAccessToken currentAccessToken]){
        [self getUserEmailAndId];
        return;
    }
    
    // Login user
    FBSDKLoginManager* loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:@[@"public_profile", @"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if(error)
        {
            NSLog(@"Error %@",error.description);
        }
        else
        {
            NSLog(@"User is loged in..");
            [self getUserEmailAndId];
        }
    }];
}

- (void) setImageAction: (id)sender
{
    [self pickImage];
}

- (IBAction)shareAction:(id)sender
{
    if ([FBSDKAccessToken currentAccessToken]) {
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = _userImage.image;
        photo.userGenerated = YES;
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
    }
}



- (void) pickImage
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Choose image" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* actionDirectory = [UIAlertAction actionWithTitle:@"Photo libray" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction* actionCamera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:actionDirectory];
    [alert addAction:actionCamera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage* image = info[UIImagePickerControllerEditedImage];
    self.userImage.image = image;
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end
