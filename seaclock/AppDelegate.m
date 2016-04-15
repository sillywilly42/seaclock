//
//  AppDelegate.m
//  seaclock
//
//  Created by Will Jenkins on 15/04/2016.
//  Copyright © 2016 Will Jenkins. All rights reserved.
//

#import "AppDelegate.h"

static NSString *const kDefaultTimeZone = @"America/Los_Angeles";

@interface AppDelegate ()
@property NSStatusItem *statusItem;
@property NSTimer *timer;
@property NSTimeZone *timeZone;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.timeZone = [NSTimeZone timeZoneWithName:kDefaultTimeZone];
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                          target:self
                                        selector:@selector(refreshDate)
                                        userInfo:nil
                                         repeats:YES];

  NSMenu *popUpMenu = [[NSMenu alloc] init];
  for (NSString *zone in [NSTimeZone knownTimeZoneNames]) {
    NSArray *components = [zone componentsSeparatedByString:@"/"];
    [self rootMenu:popUpMenu tzArray:components tzString:zone];
  }
  self.statusItem.menu = popUpMenu;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  [self.timer invalidate];
}

- (void)refreshDate {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setTimeZone:self.timeZone];
  [dateFormatter setDateFormat:@"HH:mm"];
  self.statusItem.button.title = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)rootMenu:(NSMenu *)root tzArray:(NSArray *)array tzString:(NSString *)string {
  NSString *sanitisedString = [array[0] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
  if ([array count] > 1) {
    NSMenuItem *existingMenuItem = [root itemWithTitle:sanitisedString];
    NSMenu *newRootMenu;
    if (!existingMenuItem) {
      NSMenuItem *menuItem = [[NSMenuItem alloc] init];
      menuItem.title = sanitisedString;
      NSMenu *submenu = [[NSMenu alloc] init];
      menuItem.submenu = submenu;
      [root addItem:menuItem];
      newRootMenu = submenu;
    } else {
      newRootMenu = existingMenuItem.submenu;
    }
    [self rootMenu:newRootMenu
           tzArray:[array subarrayWithRange:NSMakeRange(1, [array count]-1)]
          tzString:string];
  } else {
    NSMenuItem *menuItem = [[NSMenuItem alloc] init];
    menuItem.title = sanitisedString;
    menuItem.representedObject = string;
    menuItem.target = self;
    menuItem.action = @selector(changeTimeZone:);
    [root addItem:menuItem];
    
    if ([self.timeZone.name isEqualToString:string]) {
      menuItem.state = NSOnState;
    }
  }
}

- (IBAction)changeTimeZone:sender {
  [self clearAllStates:self.statusItem.menu];
  [sender setState:NSOnState];
  self.timeZone = [NSTimeZone timeZoneWithName:[sender representedObject]];
}

- (void)clearAllStates:(NSMenu *)rootMenu {
  for (NSMenuItem *item in rootMenu.itemArray) {
    if (item.hasSubmenu) {
      [self clearAllStates:item.submenu];
    } else {
      item.state = NSOffState;
    }
  }
}

@end
