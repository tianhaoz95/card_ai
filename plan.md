your task is to build on top the bare minimal flutter app to create a large language model assisted credit card selector app. the app aims to help user always find the credit card with best reward when spending at the store.
the app uses flutter as the client framework. the app uses firebase as the backend. the app should only use firebase authentication and firestore and should not use any other firebase services.
the app should have the following screens:
- login screen: login with email and password is supported.
- sign up screen: sign up with email and password is supported.
- card screen: card screen is for managing the user's credit cards. it shows a list of credit cards the user have. the card screen should have a floating add button for the user to add a new credit card. when the user taps on the add button, a pop up window should show up to let the user input the card name, and a url to fetch the card information. each card shown in the card screen should have buttons for editing the card, deleting the card.
- settings screen: the settings screen should have buttons for sign out, delete the account and switch between languages, download model for large language model inference.
the app should support internationalization for english and chinese. when the user switch between the languages in settings screen, all content in the app should switch language.
the app should use large language model to get the best credit card match for the user base on the purchase information user provide. for the app to switch between large language model service providers, a intereface for converting user purchase information to card match should be created to avoid complication when switching between large language model service providers. when the model is downloading, a progress bar should be shown in the settings screen to indicate the progress.
- spend screen: when the user is at a store or shopping online, the user should be able to type in information about the purchase in spend screen and tap a button to get the best credit card match. the spend screen should have a text field for the user to type in the purchase information and a button to submit the purchase information and get a credit card match. the spend screen should be disabled until the user has downloaded the large language model model. when the user has not downloaded the model, it should show a button to navigate the user to settings screen to download the model first.
the app should use local large language model. the app should use cactus as the large language model provider. refer to https://www.cactuscompute.com/docs/flutter for how to integrate cactus with flutter. the large language model provider can change in the future, so encapsulate the usage of cactus.
use the git version of cactus instead of version like this:
```
dependencies:
  cactus:
    git:
      url: https://github.com/cactus-compute/cactus-flutter.git
      ref: main
```
the logic for finding matching card is to supply the card information and the purchase information user provide as context and prompt the large language model to output a credit card match.
firebase service has already been initialized manually, no need to redo setup.
during development, use `flutter build apk` to check for build errors to ensure the correctness of implementation.

your task is to add a progress indicator when the user taps "get best card match" button to indicate that the model is still working on getting the result.