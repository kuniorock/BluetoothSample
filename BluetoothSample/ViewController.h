//
//  ViewController.h
//  BluetoothSample
//
//  Created by katsuhisa.ishii on 2013/03/27.
//  Copyright (c) 2013年 katsuhisa.ishii. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface ViewController : UIViewController
<
GKPeerPickerControllerDelegate,
GKSessionDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate
>
@end
