# New York Times Most Read Articles Demo iOS App

This app loads a list of most read New York Times articles and displays that in a table.

When a table cell is tapped a detail view is shown with more information and the ability to jump to the online article. Articles can be made favorite, after which they appear in an additional list table section.

Articles can be deleted. At the moment this is only temporary, a reload (by dragging down the list or app restart) will add the deleted items again, unless of course they are no longer retured by the web API.

Articles and favorites are sorted first on date and then on main article title.

Here's a list of remarks that are there due to time constraints.  One simply has to stop somewhere.  In case you're missing certain aspects of app development you'd still like to see me do, please ask and I'll extend the app.

## Remarks

- App displays my experience with relevant techniques: saving data in Core Data, parsing JSON using Swift 4 Codable, use of Swift 4 KVO, both iPhone and iPad support (using split view), ...
- Please be aware that it's a lot of code done in a short time.  A number of things could be refactored a bit.
- Basic error handling is in place: An error is shown at center screen if the list could not be loaded.
- All kinds of extra's were at the back of my mind, but were not done simply for time reasons: Adding loading spinners on the images, ability to search articles in the list, ...
- The app is prepared for testing by using the MVVM architecture and DI.
- XIBs are used to obtain self-contained UI classes (instead of multiple UI classes being dependent on one Storyboard) and to allow straightforward CI.
- Due to lack of time no tests have been added (yet).

## Know Issues

- Downloaded images are not saved on disk but kept in memory.  The image cache could be re-implemented using Core Data.
- Adding favorite and deleting an article are not animated on the table yet.
- All thumbnail images are loaded immediately, instead of when its cell is about to be shown.  Images should be loaded only when they (almost) appear on screen.  (The list is only 20 long and images small, so it's not a big deal for this demo.)
- The image cache implementation saves all images but never frees up memory yet.  A real app that handles many (larger) images, should have a mechanism to limit memory use.
- When app starts on iPad there's no nice empty/'we're loading' detail view yet.
- The disclosure indicator on the table cell should not be displayed on iPad.
- If there are articles in the database, they are not immediately loaded at app startup yet.
