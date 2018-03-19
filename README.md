# New York Times Most Read Articles Demo iOS App

This app loads a list of most read New York Times articles and displays that in a table.

When a table cell is tapped a detail view is shown with more information and the ability to jump to the online article. Articles can be made favorite, after which they appear in an additional list table section.

Articles can be deleted. At the moment this is only temporary, a reload (by dragging down the list or app restart) will add the deleted items again, unless of course they are no longer retured by the web API.

Articles and favorites are sorted first on date and then on main article title.

## Remarks

- Type of a app is slightly different than requested.  It does display my experience with many or all relevant techniques for this demo.  I wanted to save time by reusing demo code I wrote only a few weeks ago.  A lot was added: saving data in Core Data, parsing JSON using Swift 4 Codable, use of Swift 4 KVO, implementing favorites, adding delete functionality, adding iPad support (using split view), ...
- Images are not saved on disk.  Now that there's a Core Data database, the image cache could be re-implemented using Core Data.
- Please be aware that it's a lot of code done in a short time.  A number of things could be refactored a bit.
- Basic error handling is in place: An error is shown at center screen if the list could not be loaded.
- All kinds of extra's were at the back of my mind, but were not done simply for time reasons: Adding loading spinners on the images, ability to search articles in the list, ...
- The app is prepared for testing by using the MVVM architecture and DI.
- XIBs are used to obtain self-contained UI classes (instead of multiple UI classes being dependent on one Storyboard) and to allow straightforward CI.
- Due to lack of time no tests have been added (yet).

## Know Issues

- Adding favorite and deleting are not animated on the list table yet.
- All thumbnail images are still loaded immediately, instead of when its cell is about to be shown.  Images should be loaded only when they (almost) appear on screen.  (The list is only 20 long and images small, so it's not a big deal for this demo.)
- The image cache implementation saves all images but never frees up memory yet.  A real app that handles many (larger) images, should have a mechanism to limit memory use.
- When app starts on iPad there's no nice empty/'we're loading' detail view yet.
- The disclosure indicator on the table cell should not be displayed on iPad.
