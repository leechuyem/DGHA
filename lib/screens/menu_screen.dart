import 'package:dgha_brochure/components/appbar.dart';
import 'package:dgha_brochure/components/dgha_icon.dart';
import 'package:dgha_brochure/components/menu_drawer.dart';
import 'package:dgha_brochure/components/menu_card.dart';
import 'package:dgha_brochure/misc/data.dart';
import 'package:dgha_brochure/misc/styles.dart';
import 'package:dgha_brochure/models/menu_card_data.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuScreen extends StatefulWidget {
  static const String id = "Menu Screen";
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // NOTE: App Properties
  double srcWidth;
  double srcHeight;
  double horizontalPadding = 30;

  // NOTE: App Bar Properties
  double appBarHeight;
  double appBarRadius;

  // NOTE: Drawer
  double drawerWidth;

  // NOTE: Card Properties
  bool isVertical = false;
  double cardSpacing = 20;
  double cardWidth;
  double cardHeight;
  double cardMaxHeight;
  double cardBorderRadius;

  void calcDimensions(Orientation orientation) {
    // NOTE: App
    this.srcWidth = MediaQuery.of(context).size.width;
    this.srcHeight = MediaQuery.of(context).size.height;

    // NOTE: App Bar
    this.appBarHeight = orientation == Orientation.portrait ? srcHeight / 12 : srcWidth / 12;
    // this.appBarTextScale = this.appBarHeight / 70;
    this.appBarRadius = this.appBarHeight / 3.5;

    // NOTE: Drawer
    this.drawerWidth = orientation == Orientation.portrait ? srcWidth * 0.8 : srcHeight * 0.8;
    // this.tileTextScale = drawerWidth / 440 < 1.5 ? drawerWidth / 440 : 1.5;

    // NOTE: Card
    if (this.isVertical && orientation == Orientation.portrait) {
      this.cardWidth = (this.srcWidth - this.horizontalPadding * 2 - this.cardSpacing) / 2;
      this.cardHeight = this.srcHeight / 3.5;
    }

    if (this.isVertical && orientation == Orientation.landscape) {
      this.cardWidth = (srcWidth - horizontalPadding * 2 - cardSpacing * 3) / 4;
      this.cardHeight = srcHeight / 2.25;
    }

    if (!this.isVertical && orientation == Orientation.portrait) {
      this.cardWidth = (srcWidth - horizontalPadding * 2 - cardSpacing * 2) / 2.1;
      this.cardHeight = this.srcHeight / 3.5;
      this.cardMaxHeight = this.cardWidth * 1.1;
      this.cardBorderRadius = this.cardWidth / 8;
      // this.cardTextScale = this.cardWidth / 160;
    }

    // NOTE: the srcHeight and srcWidth are flipped from the Orientatin.portrait
    if (!this.isVertical && orientation == Orientation.landscape) {
      this.cardWidth = (srcHeight - horizontalPadding * 2 - cardSpacing * 2) / 2.1;
      this.cardHeight = this.srcWidth / 3.5;
    }

    this.cardMaxHeight = this.cardWidth * 1.1;
    this.cardBorderRadius = this.cardWidth / 8;
    // this.cardTextScale = this.cardWidth / 150 < 1.2 ? this.cardWidth / 200 : 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuDrawer(
        width: this.drawerWidth,
        borderRadius: this.appBarRadius,
        marginLeft: this.horizontalPadding,
        iconSize: this.appBarHeight,
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            this.calcDimensions(orientation);
            return Column(
              children: <Widget>[
                // NOTE: APPBAR
                DghaAppBar(
                    text: "DGHA",
                    appBarHeight: this.appBarHeight,
                    srcWidth: this.srcWidth,
                    horizontalPadding: this.horizontalPadding,
                    borderRadius: this.appBarRadius,
                    isMenuScr: true,
                    leftChild: Semantics(
                      label: "Menu button",
                      hint: "Double tap to open up side bar navigation",
                      excludeSemantics: true,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _scaffoldKey.currentState.openDrawer();
                            });
                          },
                          child: DghaIcon(
                            icon: FontAwesomeIcons.bars,
                          )),
                    ),
                    rightChid: Semantics(
                      label: "Card Direction Button",
                      hint: this.isVertical ? "Double tap to list cards horizontally" : "Double tap to list cards vertically",
                      excludeSemantics: true,
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              this.isVertical = !this.isVertical;
                            });
                          },
                          child: DghaIcon(
                            icon: this.isVertical ? FontAwesomeIcons.arrowsAltH : FontAwesomeIcons.arrowsAltV,
                          )),
                    )),
                // NOTE: TILES AREA
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Semantics(
                          label: "Sub Heading. ",
                          hint: "There are two cards in this category. Double tap on the card to read more about the topic",
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(left: this.horizontalPadding, top: 30, bottom: 10),
                            child: Text("General Information", style: Styles.h2Style),
                          ),
                        ),
                        Container(
                          height: cardHeight,
                          constraints: BoxConstraints(maxHeight: cardMaxHeight),
                          child: _buildCardList(Data.generalInfoCardData),
                        ),
                        Semantics(
                          label: "Sub Heading. ",
                          hint: "There are 9 cards in this category. " +
                              (this.isVertical ? "Slide up and down the list below to see more cards. " : "Slide left to right the list below to see more cards. ") +
                              "Double tap on the card to read more about the topic",
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(left: this.horizontalPadding, top: 30, bottom: 10),
                            child: Text("Federal and State Laws", style: Styles.h2Style),
                          ),
                        ),
                        _buildLawCards(orientation),
                        SizedBox(height: this.cardSpacing),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  EdgeInsets getMargin(int length, int index) {
    return index == length - 1 ? EdgeInsets.all(0) : EdgeInsets.only(right: cardSpacing);
  }

  ListView _buildCardList(List<MenuCardData> cardList) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(this.horizontalPadding, 0, this.horizontalPadding, 0),
      itemCount: cardList.length,
      itemBuilder: (BuildContext context, int index) {
        String upAndDown = "${cardList[index].semanticHint}. Or slide up and down to see more cards"; 
        String leftAndRight = "${cardList[index].semanticHint}. Or slide left and right to see more cards";
        return Container(
          margin: getMargin(cardList.length, index),
          child: Semantics(
            label: cardList[index].semanticLabel,
            hint: this.isVertical ? upAndDown : leftAndRight,
            child: MenuCard(
              card: cardList[index],
              width: this.cardWidth,
              height: this.cardHeight,
              maxHeight: this.cardMaxHeight,
              radius: this.cardBorderRadius,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLawCards(Orientation orientation) {
    if (this.isVertical && orientation == Orientation.portrait) {
      return _verticalAndPortWidgets();
    } else if (this.isVertical && orientation == Orientation.landscape) {
      return _verticalAndLandWidgets();
    } else {
      return _horizontalWidgets();
    }
  }

  Widget _verticalAndPortWidgets() {
    return Column(
      children: <Widget>[
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataPortRow1)),
        SizedBox(height: this.cardSpacing),
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataPortRow2)),
        SizedBox(height: this.cardSpacing),
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataPortRow3)),
        SizedBox(height: this.cardSpacing),
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataPortRow4)),
        SizedBox(height: this.cardSpacing),
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataPortRow5)),
      ],
    );
  }

  Widget _verticalAndLandWidgets() {
    return Column(
      children: <Widget>[
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataLandRow1)),
        SizedBox(height: this.cardSpacing),
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataLandRow2)),
        SizedBox(height: this.cardSpacing),
        Container(height: cardHeight, constraints: BoxConstraints(maxHeight: cardMaxHeight), child: _buildCardList(Data.lawInfoCardDataLandRow3)),
      ],
    );
  }

  Widget _horizontalWidgets() {
    return Container(
        height: cardHeight,
        constraints: BoxConstraints(maxHeight: cardMaxHeight),
        child: Semantics(container: true, child: _buildCardList(Data.lawInfoCardData)));
  }
}
