import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    title: 'Dynamic Links Example',
    routes: <String, WidgetBuilder>{
      '/': (BuildContext context) => _MainScreen(),
      '/helloworld': (BuildContext context) => _DynamicLinkScreen(),
    },
  ));
}

class _MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  String _linkMessage;
  bool _isCreatingLink = false;
  String tempStr;
  // String _testString =
  //     "To test: long press link and then copy and click from a non-browser "
  //     "app. Make sure this isn't being tested on iOS simulator and iOS xcode "
  //     "is properly setup. Look at firebase_dynamic_links/README.md for more "
  //     "details.";

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
  }

  void initDynamicLinks() async {
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      setState(() {
        tempStr = deepLink.path;
      });
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      final Uri deepLink = dynamicLink?.link;
      print("checking link");

      if (deepLink != null) {
        print("Recieved Deep Link is ${deepLink.path}");
        setState(() {
          tempStr = deepLink.path;
        });
        // Navigator.pushNamed(context, deepLink.path);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }
  // void initDynamicLinks() async {
  //   FirebaseDynamicLinks.instance.onLink(
  //       onSuccess: (PendingDynamicLinkData dynamicLink) async {
  //     final Uri deepLink = dynamicLink?.link;

  //     print("Our Link Is " + deepLink.toString());
  //     print(deepLink.path);

  //     String meetingCode =
  //         deepLink.path.substring(deepLink.path.lastIndexOf('/') + 1);
  //     print(meetingCode);
  //     // if (deepLink != null) {
  //     //   Navigator.pushNamed(context, deepLink.path);
  //     // }
  //   }, onError: (OnLinkErrorException e) async {
  //     print('onLinkError');
  //     print(e.message);
  //   });
  // }

  Future<void> _createDynamicLink(bool short) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://linktesting.page.link',
      link: Uri.parse('https://facekeek.com/developer/khusboorocks'),
      androidParameters: AndroidParameters(
        packageName: 'com.hrm.linktest',
        minimumVersion: 0,
      ),
      dynamicLinkParametersOptions: DynamicLinkParametersOptions(
        shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
      ),
      iosParameters: IosParameters(
        bundleId: 'com.hrm.linktest',
        minimumVersion: '0',
      ),
    );

    Uri url;
    if (short) {
      final ShortDynamicLink shortLink = await parameters.buildShortLink();
      url = shortLink.shortUrl;
      print(url);
    } else {
      url = await parameters.buildUrl();
    }

    setState(() {
      _linkMessage = url.toString();
      _isCreatingLink = false;
    });
  }
  // Future<void> _createDynamicLink(bool short) async {
  //   // setState(() {
  //   //   //_isCreatingLink = true;
  //   // });

  //   String uriPrefix = 'https://linktesting.page.link/';
  //   String link = 'https://facekeek.com/room/';
  //   String packageName = 'com.hrm.linktest';
  //   String mainUrl = '$uriPrefix?link=$link/&apn=$packageName&ibn=$packageName';
  //   print(mainUrl);

  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: uriPrefix,
  //     link: Uri.parse(link),
  //     androidParameters: AndroidParameters(
  //       packageName: packageName,
  //       minimumVersion: 125,
  //     ),
  //     iosParameters: IosParameters(
  //       bundleId: packageName,
  //       minimumVersion: '1.0.1',
  //       appStoreId: '1538021806',
  //     ),
  //     // googleAnalyticsParameters: GoogleAnalyticsParameters(
  //     //   campaign: 'example-promo',
  //     //   medium: 'social',
  //     //   source: 'orkut',
  //     // ),
  //     // itunesConnectAnalyticsParameters: ItunesConnectAnalyticsParameters(
  //     //   providerToken: '123456',
  //     //   campaignToken: 'example-promo',
  //     // ),
  //     // socialMetaTagParameters: SocialMetaTagParameters(
  //     //   title: 'Example of a Dynamic Link',
  //     //   description: 'This link works whether app is installed or not!',
  //     // ),
  //   );

  //   // final Uri dynamicUrl = await parameters.buildUrl();
  //   // print(dynamicUrl);

  //   final ShortDynamicLink shortenedLink =
  //       await DynamicLinkParameters.shortenUrl(
  //     Uri.parse(mainUrl),
  //   );

  //   print(shortenedLink.shortUrl.toString());

  //   // setState(() {
  //   //   _linkMessage = shortenedLink.shortUrl.toString();
  //   //   _isCreatingLink = false;
  //   // });
  // }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Links Example'),
        ),
        body: Builder(builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // RaisedButton(
                    //   onPressed: !_isCreatingLink
                    //       ? () => _createDynamicLink(false)
                    //       : null,
                    //   child: const Text('Get Long Link'),
                    // ),
                    RaisedButton(
                      onPressed: !_isCreatingLink
                          ? () => _createDynamicLink(true)
                          : null,
                      child: const Text('Get Short Link'),
                    ),
                    Text(tempStr ?? 'No Link Found'),
                  ],
                ),
                InkWell(
                  child: Text(
                    _linkMessage ?? '',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  // onTap: () async {
                  //   if (_linkMessage != null) {
                  //     await launch(_linkMessage);
                  //   }
                  // },
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: _linkMessage));
                    Scaffold.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied Link!')),
                    );
                  },
                ),
                //  Text(_linkMessage == null ? '' : _testString)
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DynamicLinkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hello World DeepLink'),
        ),
        body: const Center(
          child: Text('Hello, World!'),
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:uni_links/uni_links.dart';

// void main() => runApp(new MyApp());

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }

// enum UniLinksType { string, uri }

// class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
//   String _latestLink = 'Unknown';
//   Uri _latestUri;

//   StreamSubscription _sub;

//   TabController _tabController;
//   UniLinksType _type = UniLinksType.string;

//   final List<String> _cmds = getCmds();
//   final TextStyle _cmdStyle = const TextStyle(
//       fontFamily: 'Courier', fontSize: 12.0, fontWeight: FontWeight.w700);
//   final _scaffoldKey = new GlobalKey<ScaffoldState>();

//   @override
//   initState() {
//     super.initState();
//     _tabController = new TabController(vsync: this, length: 2);
//     _tabController.addListener(_handleTabChange);
//     initPlatformState();
//   }

//   @override
//   dispose() {
//     if (_sub != null) _sub.cancel();
//     _tabController.removeListener(_handleTabChange);
//     _tabController.dispose();
//     super.dispose();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   initPlatformState() async {
//     if (_type == UniLinksType.string) {
//       await initPlatformStateForStringUniLinks();
//     } else {
//       await initPlatformStateForUriUniLinks();
//     }
//   }

//   /// An implementation using a [String] link
//   initPlatformStateForStringUniLinks() async {
//     // Attach a listener to the links stream
//     _sub = getLinksStream().listen((String link) {
//       if (!mounted) return;
//       setState(() {
//         _latestLink = link ?? 'Unknown';
//         _latestUri = null;
//         try {
//           if (link != null) _latestUri = Uri.parse(link);
//         } on FormatException {}
//       });
//     }, onError: (err) {
//       if (!mounted) return;
//       setState(() {
//         _latestLink = 'Failed to get latest link: $err.';
//         _latestUri = null;
//       });
//     });

//     // Attach a second listener to the stream
//     getLinksStream().listen((String link) {
//       print('got link: $link');
//     }, onError: (err) {
//       print('got err: $err');
//     });

//     // Get the latest link
//     String initialLink;
//     Uri initialUri;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       initialLink = await getInitialLink();
//       print('initial link: $initialLink');
//       if (initialLink != null) initialUri = Uri.parse(initialLink);
//     } on PlatformException {
//       initialLink = 'Failed to get initial link.';
//       initialUri = null;
//     } on FormatException {
//       initialLink = 'Failed to parse the initial link as Uri.';
//       initialUri = null;
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _latestLink = initialLink;
//       _latestUri = initialUri;
//     });
//   }

//   /// An implementation using the [Uri] convenience helpers
//   initPlatformStateForUriUniLinks() async {
//     // Attach a listener to the Uri links stream
//     _sub = getUriLinksStream().listen((Uri uri) {
//       if (!mounted) return;
//       setState(() {
//         _latestUri = uri;
//         _latestLink = uri?.toString() ?? 'Unknown';
//       });
//     }, onError: (err) {
//       if (!mounted) return;
//       setState(() {
//         _latestUri = null;
//         _latestLink = 'Failed to get latest link: $err.';
//       });
//     });

//     // Attach a second listener to the stream
//     getUriLinksStream().listen((Uri uri) {
//       print('got uri: ${uri?.path} ${uri?.queryParametersAll}');
//     }, onError: (err) {
//       print('got err: $err');
//     });

//     // Get the latest Uri
//     Uri initialUri;
//     String initialLink;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       initialUri = await getInitialUri();
//       print('initial uri: ${initialUri?.path}'
//           ' ${initialUri?.queryParametersAll}');
//       initialLink = initialUri?.toString();
//     } on PlatformException {
//       initialUri = null;
//       initialLink = 'Failed to get initial uri.';
//     } on FormatException {
//       initialUri = null;
//       initialLink = 'Bad parse the initial link as Uri.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _latestUri = initialUri;
//       _latestLink = initialLink;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final queryParams = _latestUri?.queryParametersAll?.entries?.toList();

//     return new MaterialApp(
//       home: new Scaffold(
//         key: _scaffoldKey,
//         appBar: new AppBar(
//           title: new Text('Plugin example app'),
//           bottom: new TabBar(
//             controller: _tabController,
//             tabs: <Widget>[
//               new Tab(text: 'STRING LINK'),
//               new Tab(text: 'URI'),
//             ],
//           ),
//         ),
//         body: new ListView(
//           shrinkWrap: true,
//           padding: const EdgeInsets.all(8.0),
//           children: <Widget>[
//             new ListTile(
//               title: const Text('Link'),
//               subtitle: new Text('$_latestLink'),
//             ),
//             new ListTile(
//               title: const Text('Uri Path'),
//               subtitle: new Text('${_latestUri?.path}'),
//             ),
//             new ExpansionTile(
//               initiallyExpanded: true,
//               title: const Text('Query params'),
//               children: queryParams?.map((item) {
//                     return new ListTile(
//                       title: new Text('${item.key}'),
//                       trailing: new Text('${item.value?.join(', ')}'),
//                     );
//                   })?.toList() ??
//                   <Widget>[
//                     new ListTile(
//                       dense: true,
//                       title: const Text('null'),
//                     ),
//                   ],
//             ),
//             _cmdsCard(_cmds),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _cmdsCard(commands) {
//     Widget platformCmds;

//     if (commands == null) {
//       platformCmds = const Center(child: const Text('Unsupported platform'));
//     } else {
//       platformCmds = new Column(
//         children: <List<Widget>>[
//           [
//             const Text(
//                 'To populate above fields open a terminal shell and run:\n')
//           ],
//           intersperse(
//               commands.map<Widget>((cmd) => new InkWell(
//                     onTap: () => _printAndCopy(cmd),
//                     child: new Text('\n$cmd\n', style: _cmdStyle),
//                   )),
//               const Text('or')),
//           [
//             new Text(
//                 '(tap on any of the above commands to print it to'
//                 ' the console/logger and copy to the device clipboard.)',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.caption),
//           ]
//         ].expand((el) => el).toList(),
//       );
//     }

//     return new Card(
//       margin: const EdgeInsets.only(top: 20.0),
//       child: new Padding(
//         padding: const EdgeInsets.all(10.0),
//         child: platformCmds,
//       ),
//     );
//   }

//   _handleTabChange() {
//     if (_tabController.indexIsChanging) {
//       setState(() {
//         _type = UniLinksType.values[_tabController.index];
//       });
//       initPlatformState();
//     }
//   }

//   _printAndCopy(String cmd) async {
//     print(cmd);

//     await Clipboard.setData(new ClipboardData(text: cmd));
//     _scaffoldKey.currentState.showSnackBar(new SnackBar(
//       content: const Text('Copied to Clipboard'),
//     ));
//   }
// }

// List<String> getCmds() {
//   String cmd;
//   String cmdSuffix = '';

//   if (Platform.isIOS) {
//     cmd = '/usr/bin/xcrun simctl openurl booted';
//   } else if (Platform.isAndroid) {
//     cmd = '\$ANDROID_HOME/platform-tools/adb shell \'am start'
//         ' -a android.intent.action.VIEW'
//         ' -c android.intent.category.BROWSABLE -d';
//     cmdSuffix = "'";
//   } else {
//     return null;
//   }

//   // https://orchid-forgery.glitch.me/mobile/redirect/
//   return [
//     '$cmd "unilinks://host/path/subpath"$cmdSuffix',
//     '$cmd "unilinks://example.com/path/portion/?uid=123&token=abc"$cmdSuffix',
//     '$cmd "unilinks://example.com/?arr%5b%5d=123&arr%5b%5d=abc'
//         '&addr=1%20Nowhere%20Rd&addr=Rand%20City%F0%9F%98%82"$cmdSuffix',
//   ];
// }

// List<Widget> intersperse(Iterable<Widget> list, Widget item) {
//   List<Widget> initialValue = [];
//   return list.fold(initialValue, (all, el) {
//     if (all.length != 0) all.add(item);
//     all.add(el);
//     return all;
//   });
// }
