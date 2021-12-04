import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:tab_container/tab_container.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late final TabContainerController _controller;
  late TextTheme textTheme;

  @override
  void initState() {
    _controller = TabContainerController(length: 3);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    textTheme = Theme.of(context).textTheme;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: 1200,
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: AspectRatio(
                  aspectRatio: 10 / 8,
                  child: TabContainer(
                    radius: 20,
                    tabEdge: TabEdge.bottom,
                    tabCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      animation = CurvedAnimation(
                          curve: Curves.easeIn, parent: animation);
                      return SlideTransition(
                        position: Tween(
                          begin: const Offset(0.2, 0.0),
                          end: const Offset(0.0, 0.0),
                        ).animate(animation),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    colors: const <Color>[
                      Color(0xfffa86be),
                      Color(0xffa275e3),
                      Color(0xff9aebed),
                    ],
                    selectedTextStyle:
                        textTheme.bodyText2?.copyWith(fontSize: 15.0),
                    unselectedTextStyle:
                        textTheme.bodyText2?.copyWith(fontSize: 13.0),
                    children: _getChildren1(),
                    tabs: _getTabs1(),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 330.0,
                child: TabContainer(
                  controller: _controller,
                  radius: 0,
                  color: Colors.black,
                  tabDuration: const Duration(seconds: 0),
                  selectedTextStyle:
                      textTheme.bodyText2?.copyWith(color: Colors.white),
                  unselectedTextStyle:
                      textTheme.bodyText2?.copyWith(color: Colors.black),
                  children: _getChildren2(),
                  tabs: _getTabs2(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _controller.prev(),
                    icon: Icon(Ionicons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () => _controller.next(),
                    icon: Icon(Ionicons.arrow_forward),
                  ),
                ],
              ),
              const Spacer(),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TabContainer(
                    color: Theme.of(context).colorScheme.secondary,
                    tabEdge: TabEdge.right,
                    childPadding: const EdgeInsets.all(20.0),
                    children: _getChildren3(context),
                    tabs: _getTabs3(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getChildren1() {
    List<CreditCardData> cards = kCreditCards
        .map(
          (e) => CreditCardData.fromJson(e),
        )
        .toList();

    return cards.map((e) => CreditCard(data: e)).toList();
  }

  List<String> _getTabs1() {
    List<CreditCardData> cards = kCreditCards
        .map(
          (e) => CreditCardData.fromJson(e),
        )
        .toList();

    return cards
        .map(
          (e) => '*' + e.number.substring(e.number.length - 4, e.number.length),
        )
        .toList();
  }

  List<Widget> _getChildren2() {
    return <Widget>[
      Image.asset('assets/car1.jpg'),
      Image.asset('assets/car2.jpg'),
      Image.asset('assets/car3.jpg'),
    ];
  }

  List<String> _getTabs2() {
    return <String>['Image 1', 'Image 2', 'Image 3'];
  }

  List<Widget> _getChildren3(BuildContext context) => <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Info', style: Theme.of(context).textTheme.headline5),
            const Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam non ex ac metus facilisis pulvinar. In id nulla tellus. Donec vehicula iaculis lacinia. Fusce tincidunt viverra nisi non ultrices. Donec accumsan metus sed purus ullamcorper tincidunt. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.',
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Documents', style: Theme.of(context).textTheme.headline5),
            const Spacer(flex: 2),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Divider(thickness: 1),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text('Document 1'),
                  ),
                  Divider(thickness: 1),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text('Document 2'),
                  ),
                  Divider(thickness: 1),
                  Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Text('Document 3'),
                  ),
                  Divider(thickness: 1),
                ],
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profile', style: Theme.of(context).textTheme.headline5),
            const Spacer(flex: 3),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('username:'),
                        Text('email:'),
                        Text('birthday:'),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('John Doe'),
                        Text('john.doe@email.com'),
                        Text('1/1/1985'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headline5),
            const Spacer(flex: 1),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SwitchListTile(
                    title: const Text('Darkmode'),
                    value: false,
                    onChanged: (v) {},
                    secondary: Icon(Ionicons.moon),
                  ),
                  SwitchListTile(
                    title: const Text('Analytics'),
                    value: false,
                    onChanged: (v) {},
                    secondary: Icon(Ionicons.analytics),
                  ),
                ],
              ),
            ),
          ],
        ),
      ];

  List<Widget> _getTabs3(BuildContext context) => <Widget>[
        Icon(
          Ionicons.information_circle,
        ),
        Icon(
          Ionicons.document_text,
        ),
        Icon(
          Ionicons.person,
        ),
        Icon(
          Ionicons.settings,
        ),
      ];
}

class CreditCard extends StatelessWidget {
  final Color? color;
  final CreditCardData data;

  const CreditCard({
    Key? key,
    this.color,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  data.bank,
                ),
                Icon(
                  data.number[0] == '4'
                      ? FontAwesome5Brands.cc_visa
                      : data.number[0] == '5'
                          ? FontAwesome5Brands.cc_mastercard
                          : FontAwesome5Regular.question_circle,
                  size: 36,
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Text(
                  data.number,
                  style: const TextStyle(
                    fontSize: 22.0,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Exp.'),
                const SizedBox(width: 4),
                Text(
                  data.expiration,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CreditCardData {
  int index;
  bool locked;
  final String bank;
  final String name;
  final String number;
  final String expiration;
  final String cvc;

  CreditCardData({
    this.index = 0,
    this.locked = false,
    required this.bank,
    required this.name,
    required this.number,
    required this.expiration,
    required this.cvc,
  });

  factory CreditCardData.fromJson(Map<String, dynamic> json) => CreditCardData(
        index: json['index'],
        bank: json['bank'],
        name: json['name'],
        number: json['number'],
        expiration: json['expiration'],
        cvc: json['cvc'],
      );
}

const List<Map<String, dynamic>> kCreditCards = [
  {
    'index': 0,
    'bank': 'Aerarium',
    'name': 'John Doe',
    'number': '4540 1234 5678 2975',
    'expiration': '11/25',
    'cvc': '123',
  },
  {
    'index': 1,
    'bank': 'Aerarium',
    'name': 'John Doe',
    'number': '5450 8765 4321 6372',
    'expiration': '07/24',
    'cvc': '321',
  },
  {
    'index': 2,
    'bank': 'Aerarium',
    'name': 'John Doe',
    'number': '4540 4321 8765 7446',
    'expiration': '09/23',
    'cvc': '456',
  },
];
