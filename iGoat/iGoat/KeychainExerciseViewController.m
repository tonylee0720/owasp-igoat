#import "KeychainExerciseViewController.h"

@interface KeychainExerciseViewController()

-(void) storeCredentialsInSettingsApp;
-(void) storeCredentialsInKeychain;

@end

@implementation KeychainExerciseViewController

NSString *alertMessage ; 
@synthesize userName = _userName;
@synthesize password = _password;
@synthesize rememberMe = _rememberMe;



-(IBAction)storeButtonPressed:(id)sender
    {
       
   NSLog(@"In storeButtonPressed");
   
    [userName setText:userName.text];
    [password setText:password.text];
    
    NSLog(@"Username is %@ and password is %@ and remember me is %d", self.userName.text, self.password.text, self.rememberMe.on);
    
    if(self.rememberMe.on) {
        
        // Stores/Updates credentials in NSUserDefaults
        [self storeCredentialsInSettingsApp];
       
/*
 * SOLUTION
 * Uncomment the method call below to store crediatials in Keychain.
 * Don't forget to comment above function call to store credentials in NSUserDefaults.
 */
       
     //   [self storeCredentialsInKeychain];
    }
    else
    {
        alertMessage = @"Not to be Remembered" ;
    }
        
    UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Password"
                        message:alertMessage
                        delegate: nil
                        cancelButtonTitle:@"Cancel"
                        otherButtonTitles:@"OK",nil
                        ];
    [alert show]; 
}

- (void) storeCredentialsInSettingsApp
{
    NSUserDefaults *credentials = [NSUserDefaults standardUserDefaults];
    
    [credentials setObject:self.userName.text forKey:@"username"];
    [credentials setObject:self.password.text forKey:@"password"];
    
    [credentials synchronize];
    
    // setting message for UIAlert
    alertMessage = @"stored in NSUserDefaults";
    
}

- (void) storeCredentialsInKeychain
{
    NSMutableDictionary *storeCredentials = [NSMutableDictionary dictionary];
    
    // Prepare keychain dict for storing credentials
    [storeCredentials setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
    //Store password encoded
    [storeCredentials setObject:[self.password.text dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
    [storeCredentials setObject: self.userName.text forKey:(id)kSecAttrAccount];
    //Access keychain data for this app, only when unlocked. Imp to have this while adding as well as updating keychain item.
    // This is the default, but best practice to specify if apple changes its API.
    [storeCredentials setObject:(id)kSecAttrAccessibleWhenUnlocked forKey:(id)kSecAttrAccessible];
    
    // Query Keychain to see if credentials exists
    OSStatus results = SecItemCopyMatching((CFDictionaryRef) storeCredentials, nil);
    
    // if username exists in keychain
    if (results == errSecSuccess)
    {    
        NSDictionary *dataFromKeyChain = NULL;
        // There will always be one matching entry, thus limit resultset size to 1
        [storeCredentials setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
        [storeCredentials setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
        
        // Query keychain, with entered credentials and this will retrieve only 1 matching entry.
        results = SecItemCopyMatching((CFDictionaryRef) storeCredentials, (CFTypeRef *) &dataFromKeyChain);
        
        // encoded passsword.
        NSData *encodePassword = [NSData dataWithData:(NSData *)dataFromKeyChain];

        if(results == errSecSuccess)
        {
            
            NSString *passwordFromKeychain = [[NSString alloc] initWithData:encodePassword encoding:NSUTF8StringEncoding] ;
            NSLog(@"Password from keychain %@",passwordFromKeychain);
            
            
            NSMutableDictionary *updateQuery = [NSMutableDictionary dictionary];
            
           //  Setting up updateQuery dictionary to query existing keychain entries.
            [updateQuery setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
            [updateQuery setObject: self.userName.text forKey:(id)kSecAttrAccount];
            

           // Making dictionary with information to update "SecItemUpdate" ready. It needed both updateQuery and storeCredentials dictionary to be similar.     
            [storeCredentials removeObjectForKey:kSecClass];
            [storeCredentials removeObjectForKey:kSecMatchLimit];
            [storeCredentials removeObjectForKey:kSecReturnData];
            
            results = SecItemUpdate((CFDictionaryRef) updateQuery,
                                    (CFDictionaryRef) storeCredentials);
            
            
            alertMessage = @"updated in keychain";
        }  
        else
        {
            alertMessage = @"exists in keychain, but error updating it";
        }
    }
    // credentials not entered in keychain, thus add it
    else if(results == errSecItemNotFound)
    {    
        results = SecItemAdd((CFDictionaryRef) storeCredentials, NULL); 
        alertMessage = @"added in keychain";
    }  
    else
    {
        alertMessage = @"adding/updating Exception in Keychain" ;
    }
}


@end

//******************************************************************************
//
// KeychainExerciseViewController.m
// iGoat
//
// This file is part of iGoat, an Open Web Application Security
// Project tool. For details, please see http://www.owasp.org
//
// Copyright(c) 2011 KRvW Associates, LLC (http://www.krvw.com)
// The iGoat project is principally sponsored by KRvW Associates, LLC
// Project Leader, Kenneth R. van Wyk (ken@krvw.com)
// Lead Developer: Sean Eidemiller (sean@krvw.com)
//
// iGoat is free software; you may redistribute it and/or modify it
// under the terms of the GNU General Public License as published by
// the Free Software Foundation; version 3.
//
// iGoat is distributed in the hope it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
// License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc. 59 Temple Place, suite 330, Boston, MA 02111-1307
// USA.
//
// Getting Source
//
// The source for iGoat is maintained at http://code.google.com/p/owasp-igoat/
//
// For project details, please see https://www.owasp.org/index.php/OWASP_iGoat_Project
//
//******************************************************************************
