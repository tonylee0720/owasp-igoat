<h1>Contents</h1>



# Introduction #

This document will guide you through the process of adding a new exercise to iGoat.

From the start, iGoat was designed to be modular and extensible. One of the primary goals was to make it as easy as possible for contributing developers to add new exercises. Furthermore, developing new exercises shouldn't require extensive knowledge of Cocoa and Objective-C (although a passing familiarity is certainly helpful).

The role of an exercise in iGoat is two-fold. In its initial state, an exercise should present a vulnerability in the iOS platform; an actual, exploitable vulnerability. It should then provide the user with an opportunity to fix the problem by modifying the source code, recompiling, redeploying in the simulator (or to an actual device) and testing the solution.

In this way, the user is able to fully understand the problem AND the solution.

# Requirements #

  * OS X 10.6+ (Snow Leopard, Lion)
  * Xcode 4
  * Mercurial SCM tools
  * iGoat source code
  * Some familiarity with Cocoa and Objective-C

# Getting Started #

The first step is to get the iGoat source code, which means cloning the repository on Google Code and then creating a local copy with the Mercurial SCM tools.

(Mercurial itself is beyond the scope of this document. See [mercurial.selenic.com](http://mercurial.selenic.com) for documentation, workflow guides, etc.)

  1. Go to http://code.google.com/p/owasp-igoat/source/checkout
  1. Click on the "Create a clone" button at the bottom of the page.
  1. Fill in the details (give the cloned repository a name, etc.).
  1. Create a local copy of the repository from the command line...

`hg clone https://<username>@<repository>.googlecode.com/hg/ owasp-igoat`

...where `<username>` is your Google Code username and `<repository>` is the name of the cloned repository created in step 3.

This will create a new `owasp-igoat` directory inside the current working directory.

Finally, open the project file in Xcode.

`owasp-igoat/iGoat/iGoat.xcodeproj`

# Architecture Overview #

Before actually digging in and writing code, however, a brief overview of the iGoat architecture...

As with nearly all UI-driven Cocoa applications, iGoat is built upon the Model-View-Controller pattern. Data object classes ("Assets" in iGoat parlance) are defined in the model layer, views are constructed with Interface Builder and stored as .xib files, and controllers exist to manage the navigation flow, massage the data where necessary and actually perform the "business logic" of the exercises. In iGoat, most of the interesting code lives in the controller layer. New exercises are implemented as subclasses of `ExerciseViewController`, but more on that later.

### Models ###

The iGoat data model is very simple. There are exercise categories, and there are exercises. The relationship between category and exercise is 1-to-N, meaning that a category may contain multiple exercises, but an exercise can only belong to one category.

The `ExerciseCategory` and `Exercise` classes both extend the `Asset` base class, which defines a set of shared properties and methods. For example, `name` and `longDescription` are properties on both classes, and can be accessed using Objective-C dot notation. Refer to the corresponding header files for additional properties, methods, etc.

Asset data is dynamically loaded from the `Assets.plist` file in the "Resources" group. This is where the various properties relating to categories and exercises are defined (in declarative fashion), as well as the relationships between the two. When adding a new exercise, a new entry is created in the `Assets.plist` file in the context of an existing category definition. More on that later.

It should be noted that asset data is read-only across invocations of the app. In other words, while it's possible to modify the name of an exercise at run-time by changing the value of the `name` property, the change won't be persisted to the `Assets.plist` file.

### Views ###

Nearly all views in iGoat are constructed with Interface Builder. While it's not strictly necessary to use Interface Builder when adding a new exercise, it's often easier than generating the view programatically in the controller's `viewDidLoad()` method. Therefore, most exercise view controllers are initialized with a corresponding `.xib` file.

Actually constructing a view with Interface Builder is beyond the scope of this document, but a quick Google search should produce a wealth of guides, tutorials, etc.

Pertinent, official documentation from Apple:

http://developer.apple.com/library/ios/#documentation/IDEs/Conceptual/Xcode4TransitionGuide/InterfaceBuilder/InterfaceBuilder.html
http://developer.apple.com/library/ios/#recipes/xcode_help-interface_builder/_index.html

### Controllers ###

Finally, iGoat is made up of a handful of controllers, most of which correspond directly to views. At its core, iGoat uses a global navigation controller to manage the hierarchical structure of the various custom view controllers. The list of exercises within a category, for example, is backed by a custom view controller (`ExercisesViewController`, which extends `UITableViewController`).

An excellent overview of the navigation controller architecture:

http://developer.apple.com/library/ios/#featuredarticles/ViewControllerPGforiPhoneOS/NavigationControllers/NavigationControllers.html

Relevant to the addition of new exercises is the `ExerciseViewController`, which all exercise controllers must extend. This class defines certain methods, properties, and UI elements common to all exercises (the "Hints" and "Solution" button actions, for example).

# Code Layout #

After opening the project in Xcode, the first thing to do is familiarize yourself with the code layout and folder structure. Expand the top-level `iGoat` folder and take note of the various subfolders.

![http://halcyon.cc/igoat/folder_structure.png](http://halcyon.cc/igoat/folder_structure.png)

Relevant to adding a new exercise are the `View Controllers`, `Resources` and `Exercises` folders. The rest can essentially be ignored unless you're hacking on iGoat itself (separate wiki page).

Note that Xcode refers to these folders as "groups", which kinda makes sense because the files within them don't actually exist in separate folders in the filesystem. It's perhaps helpful to think of groups as logical folders within the context of an Xcode project. We'll continue to refer to them as "folders" for the sake of clarity.

### View Controllers ###

Most of the code in iGoat lives in view controllers. In general, each view is backed by a corresponding view controller. The modal "hints" view, for example, is backed by the `HintsViewController` class.

For the purpose of adding a new exercise, the only important class in this folder is `ExerciseViewController`, which all individual exercise controllers must subclass. Again, if you're not hacking on iGoat, you can safely ignore the rest.

### Resources ###

The `Resources` folder contains non-code "resources" used by the app, such as HTML and CSS files, along with the important `Assets.plist` file. All of these are discussed below in greater detail. For now, just be aware that these files exist, and that you'll definitely be adding and modifying files in the `Resources` folder.

### Exercises ###

This is where the actual exercises live, including those that ship with iGoat. Each exercise is contained within a subfolder bearing the name of the exercise itself. For example, the files and classes related to the SQL injection exercise are contained within the `SQL Injection` folder.

# Exercise Implementation #

Okay... It's finally time to start writing code!

### Creating Files and Folders ###

The first step is to create a new subfolder for your exercise within the existing `Exercises` folder. To do this, right-click on the `Exercises` folder and select "New Group" from the pop-up menu.

(Remember, Xcode refers to these folders as "groups".)

![http://halcyon.cc/igoat/exercises_folder.png](http://halcyon.cc/igoat/exercises_folder.png)

Name the new folder after the exercise itself, using the same punctuation and capitalization. If your exercise relates to key management, for example, name the folder "Key Management". Keep it simple... The name should serve to clearly indicate the nature of the exercise and to disambiguate it from others, but it shouldn't extend beyond the width of an iPhone screen in the list of exercises.

Avoid prefixes like "Safe" when naming your exercise. We know that the purpose is to demonstrate a "safe" technique. That's what iGoat is for.

Once the exercise folder is in place, the next step is to generate a skeleton implementation of the exercise view controller. Xcode does this for you. Well, you have to ask it to...

Right-click on the new exercise folder and select "New File..." from the pop-up menu. Xcode will bring up a wizard dialog. Select "Cocoa Touch" from the list on the left, and then "UIViewController subclass" from the detail view on the right. Click "Next" to continue.

![http://halcyon.cc/igoat/new_exercise1.png](http://halcyon.cc/igoat/new_exercise1.png)

On the following screen, type "ExerciseViewController" in the "Subclass of" drop-down menu and be sure that the "With XIB for user interface" checkbox is selected. Again, click "Next" to continue.

![http://halcyon.cc/igoat/new_exercise2.png](http://halcyon.cc/igoat/new_exercise2.png)

Finally, give the subclass a name in the following format:

`<ExerciseNameInPascalCase>ViewController`

For example, in the case of the local data storage exercise, the name of the view controller subclass would be `LocalDataStorageViewController`. Also, be sure to select the appropriate group in the drop-down menu. Click "Save" to continue.

![http://halcyon.cc/igoat/new_exercise3.png](http://halcyon.cc/igoat/new_exercise3.png)

Xcode will generate three new files at this point and store them in the new folder. Again, assuming the contrived example of a key management exercise, these files will be named:

`KeyManagementViewController.h`<br>
<code>KeyManagementViewController.m</code><br>
<code>KeyManagementViewController.xib</code>

The first is the header file, the second is the implementation file, and the third is the XIB-formatted view file.<br>
<br>
An Objective-C primer from Apple that covers the different file types (also a great introduction to the language itself):<br>
<br>
<a href='http://developer.apple.com/library/mac/#referencelibrary/GettingStarted/Learning_Objective-C_A_Primer/_index.html'>http://developer.apple.com/library/mac/#referencelibrary/GettingStarted/Learning_Objective-C_A_Primer/_index.html</a>

<h3>Building the View</h3>

The next step is to build the view. This is the screen that iGoat users will see and interact with upon launching your exercise. There could even be multiple screens/views if the exercise is sufficiently complex (SQL Injection, for example).<br>
<br>
Xcode ships with a fairly decent WYSIWYG view editor called Interface Builder. Simply click on the XIB file within your exercise folder to launch the editor within the main Xcode window, or double-click to open in a separate window.<br>
<br>
While actually using Interface Builder is beyond the scope of this document, there are several important things to keep in mind while constructing the view for your exercise.<br>
<br>
First, exercise views live within the context of a navigation view. This means that there will always be a navigation bar at the top of the screen and a toolbar at the bottom. You can (and should) simulate the presence of these bars in the "Simulated Metrics" options. This will help to ensure that your main window is the correct size.<br>
<br>
<img src='http://halcyon.cc/igoat/interface_builder1_highlighted.png' />

Second, the button layout in the navigation bar and toolbar is set programatically in the <code>ExerciseViewController</code> base class (in the viewDidLoad() function). For the sake of consistency, your exercise should NOT attempt to modify the contents of either bar. You don't need to write additional code to display the hints and solution text; the base class already handles that.<br>
<br>
<img src='http://halcyon.cc/igoat/bars.png' />

Finally, there are several <code>IBAction</code> methods already implemented in the <code>ExerciseViewController</code> base class that may prove useful:<br>
<br>
<code>- (IBAction)textFieldReturn:(id)sender;</code><br>
<code>- (IBAction)backgroundTouched:(id)sender;</code>

These actions can be connected to a text field and the background pane, respectively, and will dismiss the keyboard (doesn't happen automatically, which is annoying).<br>
<br>
<code>- (IBAction)textFieldDidBeginEditing:(id)sender;</code>

This action will shift the entire pane up in the case that the keyboard would otherwise overlap a text field. Again, this doesn't happen automatically, which is baffling in addition to annoying. Note that in order for this to work, the <code>UITextField</code> must exist within the context of a <code>UIScrollView</code>.<br>
<br>
Several of the default exercises make use of these actions, so you can always check there for usage examples. In fact, the default exercises are an excellent learning resource in a general sense.<br>
<br>
For additional reading, the Interface Builder documentation from Apple:<br>
<br>
<a href='http://developer.apple.com/library/ios/#documentation/IDEs/Conceptual/Xcode4TransitionGuide/InterfaceBuilder/InterfaceBuilder.html'>http://developer.apple.com/library/ios/#documentation/IDEs/Conceptual/Xcode4TransitionGuide/InterfaceBuilder/InterfaceBuilder.html</a>

<h3>View Controller Implementation</h3>

Once the view is built, the next step is to define the outputs and actions and implement the "business logic" in the controller.<br>
<br>
Again, hooking everything up properly is beyond the scope of this document. If you don't know how to connect a <code>UITextField</code> in the view to an <code>IBOutlet</code> in the controller, please refer to the iOS Developer Library from Apple:<br>
<br>
<a href='http://developer.apple.com/library/iOS/navigation/'>http://developer.apple.com/library/iOS/navigation/</a>

As stated in the introduction, an exercise in its initial state should be <i>vulnerable</i> to attack. Most of the time (though not always), the appropriate fix will be implemented in the view controller, but it shouldn't be present from the start. Rather, it's the user's job to implement the solution by modifying the code.<br>
<br>
However, the solution code <i>should</i> exist within a comment block near the bottom of the view controller implementation (the <code>.m</code> file), along with a brief description. For example...<br>
<br>
<img src='http://halcyon.cc/igoat/solution_comments.png' />

All of the default exercises that ship with iGoat are structured in this manner. For the sake of consistency, new exercises that do not adhere to this structure will be rejected, unless there's a really good reason.<br>
<br>
<h3>Assets.plist</h3>

The <code>Assets.plist</code> file, located in the <code>Resources</code> folder, is essentially a declarative repository for exercises. Upon initialization, iGoat parses this file and loads the data into its read-only store. This means that you don't need to modify any of the core iGoat classes to add a new exercise; you only need to add an entry in the <code>Assets.plist</code> file (much easier).<br>
<br>
The file itself is a simple iOS property list, stored in XML format. Xcode ships with a built-in editor of sorts, but it's generally easier to modify in raw XML. When you click on the <code>Assets.plist</code> file under the <code>Resources</code> folder, you'll see the following editor display by default.<br>
<br>
<img src='http://halcyon.cc/igoat/assets_plist.png' />

The structure of the file is fairly self-explanatory. The top-level items are categories, of which there are currently four:<br>
<br>
<b>Authentication</b><br>
<b>Data Protection (Rest)</b><br>
<b>Data Protection (Transit)</b><br>
<b>Injection Flaws</b>

New exercises will most likely fall into one of these categories. If not, or if categorization is somewhat ambiguous, please confer with either Ken or Sean before adding a new category. Refer to the <a href='#Getting_Help.md'>#Getting_Help</a> below for contact info.<br>
<br>
Each category contains a description and an array of exercises. Within the context of a <code>plist</code> file, array elements are referred to as "<code>Item &lt;n&gt;</code>", where <code>&lt;n&gt;</code> is the index (starting at zero). Again, these items represent individual exercises. Each exercise must define the following set of attributes:<br>
<br>
<code>name</code>: The name of the exercise.<br>
<br>
<code>description</code>: A brief introductory description to the exercise.<br>
<br>
<code>creditsFile</code>: The name of the HTML file containing the exercise credits (more on this later).<br>
<br>
<code>hints</code>: An array of hints designed to guide the user to the correct solution, in the manner of iterative disclosure.<br>
<br>
<code>solution</code>: A set of instructions for solving the exercise; displayed when the user clicks the "Solution" button.<br>
<br>
<code>initialViewController</code>: The name of the specific view controller class for this exercise. If there are multiple view controllers, this should be the name of the first to be displayed.<br>
<br>
Rather than defining all of these attributes by hand after creating a new exercise entry, it may be easier to simply copy/paste an existing exercise entry and replace all of the attribute definitions.<br>
<br>
Alternately, you can edit the file in raw XML format by right-clicking on the <code>Assets.plist</code> entry in the <code>Resources</code> folder and selecting <code>Open As</code> -> <code>Source Code</code> in the pop-up menu.<br>
<br>
<img src='http://halcyon.cc/igoat/assets_plist_xml.png' />

Once an exercise has been added to the <code>Assets.plist</code> file, it should <i>just be there</i> when iGoat is next launched.<br>
<br>
<h3>Credits File</h3>

The credits file allows developers to claim credit for individual exercises. The credits are displayed when a user clicks the "Credits" button on the exercise introduction screen. The file itself should be in HTML format, which iGoat will render within the context of a <code>UIWebView</code>. The following is the KRvW Associates credits page (we at KRvW Associates built all of the original iGoat exercises).<br>
<br>
<img src='http://halcyon.cc/igoat/credits.png' />

You can name the file whatever you like, but it must be placed in the <code>Resources</code> folder. Feel free to use the <code>igoat.css</code> file for styling (see <code>KRvWAssociates.html</code> for details), but it's certainly not required. Restrictions on content and styling are fairly lax. However, you should NOT include JavaScript or reference external resources on the Internet. The HTML should be fully self-contained.<br>
<br>
To associate an exercise with a credits page, simply provide the name of the HTML file (with extension) in the <code>creditsFile</code> attribute of the exercise entry in <code>Assets.plist</code>. Again, refer to existing exercise definitions for examples.<br>
<br>
<h1>Code Submission</h1>

Submitting an exercise is fairly simple.<br>
<br>
Okay, that's not entirely true... While the process isn't overly complicated, it's certainly more complicated than it should be, but most of that is due to a shortcoming in Google Code itself.<br>
<br>
If you're familiar with GitHub, for example, you're probably familiar with the pre-commit review scheme. As a contributing developer, your code is reviewed prior to being merged into the main project branch. GitHub makes this process very easy. Google Code, however, does not.<br>
<br>
The Google Code model assumes that contributing developers have already been granted commit-level access to the repository by the project leaders. The developer commits a change and <i>then</i> requests a code review. And in our opinion, this is less than ideal.<br>
<br>
Instead, you should first clone the iGoat repository as described in the <a href='#Getting_Started.md'>#Getting_Started</a> section. Then, after making changes and committing them back to the cloned repository, contact either Ken or Sean via email to request a code review. Once approved, your new exercise (or whatever other changes you've made) will be merged into the main repository.<br>
<br>
Do not attempt to use the built-in "Request code review" feature in the Google Code web interface.<br>
<br>
<h1>Getting Help</h1>

If you have questions, first try the official iGoat mailing list, which you can find at:<br>
<br>
<a href='https://lists.owasp.org/mailman/listinfo/owasp-igoat-project'>https://lists.owasp.org/mailman/listinfo/owasp-igoat-project</a>

Or you can email Ken (krvw@owasp.org) and Sean (sean@krvw.com), the project and dev leaders, respectively.<br>
<br>
Happy hacking!