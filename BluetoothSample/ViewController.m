//
//  ViewController.m
//  BluetoothSample
//
//  Created by katsuhisa.ishii on 2013/03/27.
//  Copyright (c) 2013年 katsuhisa.ishii. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,strong) GKSession* session;
@property(nonatomic,strong) NSString* peerID;
@property(nonatomic) GKPeerConnectionState state;
@property(nonatomic,weak) IBOutlet UILabel* labelStatus;
@property(nonatomic,weak) IBOutlet UIImageView* imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapButtonConnect:(id)sender
{
    GKPeerPickerController* picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
 
    //接続タイプはBluetoothのみとする
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [picker show];
}

- (IBAction)tapButtonSendPhoto:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select Photo"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Camera Roll", nil];
	[sheet showInView:self.view];
}

#pragma mark - GKPeerPickerControllerDelegate
- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)peerID
                   toSession:(GKSession *)session
{
    NSLog(@"%s|peerID=%@", __PRETTY_FUNCTION__, peerID);
	
	_session = session;
	session.delegate = self;
    
    //ハンドラ設定
	[session setDataReceiveHandler:self withContext:nil];
    
    //ピッカーを閉じる
	picker.delegate = nil;
	[picker dismiss];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
	NSLog(@"%s|%@", __PRETTY_FUNCTION__, nil);
	
	picker.delegate = nil;
}

/*
 * データ受信ハンドラー
 */
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    self.imageView.image = [UIImage imageWithData:data];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSString* stateMessage = @"";
    
    _state = state;
    switch (state) {
        case GKPeerStateAvailable:{
            stateMessage = @"Available";
            [session connectToPeer:peerID withTimeout:10];
            break;
        }
        case GKPeerStateUnavailable:{
            stateMessage = @"Unavailable";
            break;
        }
        case GKPeerStateConnected:{
            stateMessage = @"Connected";
            _peerID = peerID;
            break;
        }
        case GKPeerStateDisconnected:{
            stateMessage = @"Disconnected";
            break;
        }
        case GKPeerStateConnecting:{
            stateMessage = @"Connecting";
            break;
        }
        default:
            break;
    }
    
    [_labelStatus setText:stateMessage];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSLog(@"%s|%@", __PRETTY_FUNCTION__, peerID);
	NSError* error = nil;
	[session acceptConnectionFromPeer:peerID error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"%s|%@|%@", __PRETTY_FUNCTION__, peerID, error);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"%s|%@", __PRETTY_FUNCTION__, error);
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1) {
        // canceld
		return;
	}
	
	UIImagePickerController* picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	picker.delegate = self;
	picker.allowsEditing = YES;
	picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
	
	UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
	
	NSError* error = nil;
	NSData* data = UIImageJPEGRepresentation(image, 0.5);
	
	[self.session sendData:data
				   toPeers:[NSArray arrayWithObject:_peerID]
			  withDataMode:GKSendDataReliable
					 error:&error];
	if (error) {
		NSLog(@"%@", error);
	}
	
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
