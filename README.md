# New York Times Most Read Articles Demo iOS App

This app loads a list of most read New York Times articles and displays that in a table.

When a table cell is tapped a detail view is shown with more information and the ability to jump to the online article. Articles can be made favorite, after which they appear in an additional list table section.

## Remarks

- Type of a app is slightly different than requested.  I wanted to save time by reusing demo code I wrote only a few weeks.  A lot was added: saving data in Core Data, parsing JSON using Swift 4 Codable, use Swift 4 KVO, implement favorites, add delete functionality, made universal by adding iPad split view support, ...
- Deleting a favorite article causes a crash.  I will fix this issue today.
- Please be aware that it's a lot of code done in a short time.  A number of things could be refactored a bit.
- All thumbnail images are still loaded immediately, instead of when its cell is about to be shown.  It's a known issue I didn't fix (yet); in a real app with a long list images should be loaded only when they (almost) appear on screen.
- Basic error handling is in place: An error is shown at center screen if the list could not be loaded.
- The image cache implementation saves all images but never frees up memory yet.  It's a know issue I didn't fix (yet); a real app that handles many (larger) images, should have a mechanism to limit memory use.
- No external libraries are used.  So no special instructions are needed to run the app.
- All kinds of extra's were at the back of my mind, but were not done simply for time reasons: Adding loading spinners on the images, ability to select number of days (1, 7, or 30) using a segment control, ability to search articles in the list, show more available info on the detail view, ...
- The app is prepared for testing by using the MVVM architecture and DI.
- Due to lack of time no tests have been added (yet).
