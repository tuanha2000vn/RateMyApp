import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

/// Main Rate my app instance.
RateMyApp _rateMyApp = RateMyApp();

/// First plugin test method.
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // This allows to use async methods in the main method without any problem.

  _rateMyApp.init().then((_) {
    // We initialize our Rate my app instance.
    runApp(_RateMyAppTestApp());
    _rateMyApp.conditions.forEach((condition) {
      if (condition is DebuggableCondition) {
        print(condition.valuesAsString()); // We iterate through our list of conditions and we print all debuggable ones.
      }
    });

    print('Are all conditions met ? ' + (_rateMyApp.shouldOpenDialog ? 'Yes' : 'No'));
  });
}

/// The main Rate my app test widget.
class _RateMyAppTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Rate my app !'),
          ),
          body: _RateMyAppTestAppBody(),
        ),
      );
}

/// The body of the main Rate my app test widget.
class _RateMyAppTestAppBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RateMyAppTestAppBodyState();
}

/// The body state of the main Rate my app test widget.
class _RateMyAppTestAppBodyState extends State<_RateMyAppTestAppBody> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 40,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (Condition condition in _rateMyApp.conditions)
              if (condition is DebuggableCondition) // Same here, we put all debuggable conditions in a Text widget.
                _textCenter(condition.valuesAsString()),
            _textCenter('Are conditions met ? ' + (_rateMyApp.shouldOpenDialog ? 'Yes' : 'No')),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: RaisedButton(
                child: Text('Launch "Rate my app" dialog'),
                onPressed: () => _rateMyApp.showRateDialog(context).then((_) => setState(() {})), // We launch the default Rate my app dialog.
              ),
            ),
            RaisedButton(
              child: Text('Launch "Rate my app" star dialog'),
              onPressed: () => _rateMyApp.showStarRateDialog(context, onRatingChanged: (count) {
                final Widget cancelButton = RateMyAppNoButton(
                  // We create a custom "Cancel" button using the RateMyAppNoButton class.
                  _rateMyApp,
                  text: 'CANCEL',
                  callback: () => setState(() {}),
                );
                if (count == null || count == 0) {
                  // If there is no rating (or a 0 star rating), we only have to return our cancel button.
                  return [cancelButton];
                }

                // Otherwise we can do some little more things...
                String message = 'You\'ve put ' + count.round().toString() + ' star(s). ';
                Color color;
                switch (count.round()) {
                  case 1:
                    message += 'Did this app hurt you physically ?';
                    color = Colors.red;
                    break;
                  case 2:
                    message += 'That\'s not really cool man.';
                    color = Colors.orange;
                    break;
                  case 3:
                    message += 'Well, it\'s average.';
                    color = Colors.yellow;
                    break;
                  case 4:
                    message += 'This is cool, like this app.';
                    color = Colors.lime;
                    break;
                  case 5:
                    message += 'Great ! <3';
                    color = Colors.green;
                    break;
                }

                return [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () async {
                      print(message);
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: color,
                        ),
                      );

                      // This allow to mimic a click on the default "Rate" button and thus update the conditions based on it ("Do not open again" condition for example) :
                      await _rateMyApp.callEvent(RateMyAppEventType.rateButtonPressed);

                      Navigator.pop(context);
                      setState(() {});
                    },
                  ),
                  cancelButton,
                ];
              }),
            ),
            RaisedButton(
              child: Text('Reset'),
              onPressed: () => _rateMyApp.reset().then((_) => setState(() {})), // We reset all Rate my app conditions values.
            ),
          ],
        ),
      );

  /// Returns a centered text.
  Text _textCenter(String content) => Text(
        content,
        textAlign: TextAlign.center,
      );
}
