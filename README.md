# Conflicting Events

# Problem

Build  MVP app. See events sectioned by start date and listed in chronological  order. The app will also identify conflicts.

Use the mock.json file in order to complete the coding kata.

# Summary

For this kata, I have choosen to go the route of CoreData, SwiftUI and Combine. This allows me to keep things simple.
The UI has two buttons. One to load the data from the file into the application and one to give the user the option to delete the data.
The remove does a batch delete on all of the CoreData entities within a new background context and then merges the changes to the view context in order to stay performant. The load button will read the data from the json file and do a batch insert request to CoreData. Upon saving, the changes get merged to the view context in order to display to the user. The actual implementation uses a sorting index which is a 64 bit integer that represents the day of the event. This should allow CoreData to sort quicker when it is pulling the data in the FetchedResultsController. The data is then searched and updated to determine if it has a conflict or not. This happens within an operation queue in the background. If it finds that there is an event that is conflicting it will mark it as having a conflict and it will display as having a yellow background. 


## Demo
![](demo.gif)