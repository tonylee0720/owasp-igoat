#import "HintsViewController.h"
#import "Exercise.h"

@implementation HintsViewController

@synthesize exercise, nextButton, prevButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
             exercise:(Exercise *)ex
{
    NSString *hintText = (NSString *)[ex.hints objectAtIndex:ex.hintIndex];

    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil
                              infoText:hintText])) {
        self.exercise = ex;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self toggleButtons];
    [super viewDidLoad];
}

- (IBAction)loadNextHint:(id)sender
{
    int idx = self.exercise.hintIndex;

    if (idx < self.exercise.totalHints - 1) {
        self.exercise.hintIndex = idx + 1;
        [self toggleButtons];
        [self loadHtmlString:(NSString *)[self.exercise.hints objectAtIndex:(idx + 1)]];
    }
}

- (IBAction)loadPreviousHint:(id)sender
{
    int idx = self.exercise.hintIndex;
    
    if (idx > 0) {
        self.exercise.hintIndex = idx - 1;
        [self toggleButtons];
        [self loadHtmlString:(NSString *)[self.exercise.hints objectAtIndex:(idx - 1)]];
    }
}

- (void)toggleButtons
{
    int idx = self.exercise.hintIndex;
    int total = self.exercise.totalHints;

    if (idx < total - 1) {
        self.nextButton.enabled = YES;

        if (idx == 0) {
            self.prevButton.enabled = NO;
        } else {
            self.prevButton.enabled = YES;
        }

    } else if (total == 0) {
        // Should never get here because the hints controller shouldn't be instantiated if there
        // are no hints, but just in case...
        self.nextButton.enabled = NO;
        self.prevButton.enabled = NO;
    } else {
        self.nextButton.enabled = NO;
        self.prevButton.enabled = YES;
    }
}

// TODO: This is kinda hacky.
- (NSString *)formatAsHtml:(NSString *)text
{
    if ([text hasPrefix:@"<html>"]) {
        return text;
    } else {
        return [NSString stringWithFormat:@"<html><head>"
                "<link href=\"igoat.css\" rel=\"stylesheet\" type=\"text/css\">"
                "<head><body<h2>%@ (%d/%d)</h2>%@</body></html>",
                self.exercise.name, (self.exercise.hintIndex + 1), self.exercise.totalHints, text];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [exercise release];
    [nextButton release];
    [prevButton release];
    [super dealloc];
}

@end

//******************************************************************************
//
// HintsViewController.m
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
// The source for iGoat is maintained at <REPO>, a repository
// for free software projects.
//
// For details, please see <URL>
//
//******************************************************************************