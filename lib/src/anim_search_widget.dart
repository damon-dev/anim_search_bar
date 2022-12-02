import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SuggestionItem {
  final String name;
  final String type;

  SuggestionItem({required this.name, required this.type, this.onTap});

  Widget buildTitle(BuildContext context) => Text(name);

  Widget buildSubtitle(BuildContext context) => Text(type);

  void Function(int index)? onTap;
}

class SuggestionController {
  SuggestionController({this.count = 0, this.animDurationInMilis = 200});

  /// Will used to access the Animated list
  GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  /// This holds the items
  List<SuggestionItem> items = [];

  /// This holds the item count
  int count;

  int animDurationInMilis;

  void addItem(SuggestionItem newItem) {
    items.add(newItem);
    listKey.currentState?.insertItem(items.length - 1,
        duration: Duration(milliseconds: animDurationInMilis));
  }

  void setItems(List<SuggestionItem> newItems) {
    if (newItems.length == 0) return;
    while (items.length < count) {
      addItem(SuggestionItem(name: '', type: ''));
    }
    int i = 0;
    for (i = 0; i < items.length && i < newItems.length; ++i) {
      items[i] = newItems[i];
    }
    for (; i < items.length; ++i) {
      items[i] = SuggestionItem(name: '', type: '');
    }
  }

  void popItem(BuildContext context) {
    if (items.length == 0) return;
    items.removeLast();
    listKey.currentState?.removeItem(items.length,
        (_, animation) => sizeSuggestion(context, items.length, animation),
        duration: Duration(milliseconds: animDurationInMilis));
  }

  void clear(BuildContext context) {
    while (items.length > 0) popItem(context);
  }

  Widget sizeSuggestion(BuildContext context, int index, animation) {
    late SuggestionItem item;
    (index >= items.length || index < 0)
        ? item = SuggestionItem(name: '', type: '')
        : item = items[index];
    return SizeTransition(
      axis: Axis.vertical,
      axisAlignment: -1.0,
      sizeFactor: animation,
      child: ListTile(
        title: item.buildTitle(context),
        subtitle: item.buildSubtitle(context),
        onTap: () => item.onTap?.call(index),
      ),
    );
  }
}

class AnimSearchBar extends StatefulWidget {
  ///  width - double ,isRequired : Yes
  ///  textController - TextEditingController  ,isRequired : Yes
  ///  onSuffixTap - Function, isRequired : Yes
  ///  rtl - Boolean, isRequired : No
  ///  autoFocus - Boolean, isRequired : No
  ///  style - TextStyle, isRequired : No
  ///  closeSearchOnSuffixTap - bool , isRequired : No
  ///  suffixIcon - Icon ,isRequired :  No
  ///  prefixIcon - Icon  ,isRequired : No
  ///  animationDurationInMilli -  int ,isRequired : No
  ///  helpText - String ,isRequired :  No
  /// inputFormatters - TextInputFormatter, Required - No

  final double width;
  final TextEditingController textController;
  final Icon? suffixIcon;
  final Icon? prefixIcon;
  final String helpText;
  final int animationDurationInMilli;
  final onSuffixTap;
  final bool rtl;
  final bool autoFocus;
  final TextStyle? style;
  final bool closeSearchOnSuffixTap;
  final Color? color;
  final List<TextInputFormatter>? inputFormatters;
  final SuggestionController? suggestionController;

  const AnimSearchBar({
    Key? key,

    /// The width cannot be null
    required this.width,

    /// The textController cannot be null
    required this.textController,
    this.suffixIcon,
    this.prefixIcon,
    this.helpText = "Search...",

    /// choose your custom color
    this.color = Colors.white,

    /// The onSuffixTap cannot be null
    required this.onSuffixTap,
    this.animationDurationInMilli = 200,

    /// make the search bar to open from right to left
    this.rtl = false,

    /// make the keyboard to show automatically when the searchbar is expanded
    this.autoFocus = false,

    /// TextStyle of the contents inside the searchbar
    this.style,

    /// close the search on suffix tap
    this.closeSearchOnSuffixTap = false,

    /// can add list of inputformatters to control the input
    this.inputFormatters,
    this.suggestionController,
  }) : super(key: key);

  @override
  _AnimSearchBarState createState() => _AnimSearchBarState();
}

///toggle - 0 => false or closed
///toggle 1 => true or open
int toggle = 0;

class _AnimSearchBarState extends State<AnimSearchBar>
    with SingleTickerProviderStateMixin {
  ///initializing the AnimationController
  late AnimationController _con;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    ///Initializing the animationController which is responsible for the expanding and shrinking of the search bar
    _con = AnimationController(
      vsync: this,

      /// animationDurationInMilli is optional, the default value is 375
      duration: Duration(milliseconds: widget.animationDurationInMilli),
    );
  }

  unfocusKeyboard() {
    final FocusScopeNode currentScope = FocusScope.of(context);
    if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      ///if the rtl is true, search bar will be from right to left
      alignment: widget.rtl ? Alignment.centerRight : Alignment(-1.0, 0.0),

      ///Using Animated container to expand and shrink the widget
      child: ConstrainedBox(
        constraints: new BoxConstraints(
          minHeight: 48.0,
          minWidth: 48.0,
          maxHeight: double.infinity,
          maxWidth: widget.width,
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: widget.animationDurationInMilli),
          width: (toggle == 0) ? 48.0 : widget.width,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            /// can add custom color or the color will be white
            color: widget.color,
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                spreadRadius: -10.0,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ///Using Animated Positioned widget to expand and shrink the widget
                  Positioned(
                    //duration:
                    //Duration(milliseconds: widget.animationDurationInMilli),
                    top: 6.0,
                    right: 7.0,
                    //curve: Curves.easeOut,
                    child: AnimatedOpacity(
                      opacity: (toggle == 0) ? 0.0 : 1.0,
                      duration: Duration(
                          milliseconds: widget.animationDurationInMilli),
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          /// can add custom color or the color will be white
                          color: widget.color,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: AnimatedBuilder(
                          child: GestureDetector(
                            onTap: () {
                              try {
                                ///trying to execute the onSuffixTap function
                                widget.onSuffixTap();

                                ///closeSearchOnSuffixTap will execute if it's true
                                if (widget.closeSearchOnSuffixTap) {
                                  unfocusKeyboard();
                                  setState(() {
                                    toggle = 0;
                                  });
                                }
                              } catch (e) {
                                ///print the error if the try block fails
                                print(e);
                              }
                            },

                            ///suffixIcon is of type Icon
                            child: widget.suffixIcon != null
                                ? widget.suffixIcon
                                : Icon(
                                    Icons.close,
                                    size: 20.0,
                                  ),
                          ),
                          builder: (context, widget) {
                            ///Using Transform.rotate to rotate the suffix icon when it gets expanded
                            return Transform.rotate(
                              angle: _con.value * 2.0 * pi,
                              child: widget,
                            );
                          },
                          animation: _con,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration:
                        Duration(milliseconds: widget.animationDurationInMilli),
                    left: (toggle == 0) ? 20.0 : 40.0,
                    curve: Curves.easeOut,
                    top: 11.0,

                    ///Using Animated opacity to change the opacity of th textField while expanding
                    child: AnimatedOpacity(
                      opacity: (toggle == 0) ? 0.0 : 1.0,
                      duration: Duration(
                          milliseconds: widget.animationDurationInMilli),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        alignment: Alignment.topCenter,
                        width: widget.width / 1.7,
                        child: TextField(
                          ///Text Controller. you can manipulate the text inside this textField by calling this controller.
                          controller: widget.textController,
                          inputFormatters: widget.inputFormatters,
                          focusNode: focusNode,
                          cursorRadius: Radius.circular(10.0),
                          cursorWidth: 2.0,
                          onEditingComplete: () {
                            /// on editing complete the keyboard will be closed and the search bar will be closed
                            unfocusKeyboard();
                            setState(() {
                              toggle = 0;
                            });
                          },

                          ///style is of type TextStyle, the default is just a color black
                          style: widget.style != null
                              ? widget.style
                              : TextStyle(color: Colors.black),
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(bottom: 5),
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            labelText: widget.helpText,
                            labelStyle: TextStyle(
                              color: Color(0xff5B5B5B),
                              fontSize: 17.0,
                              fontWeight: FontWeight.w500,
                            ),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///Using material widget here to get the ripple effect on the prefix icon
                  Material(
                    /// can add custom color or the color will be white
                    color: widget.color,

                    borderRadius: BorderRadius.circular(30.0),
                    child: IconButton(
                      splashRadius: 19.0,

                      ///if toggle is 1, which means it's open. so show the back icon, which will close it.
                      ///if the toggle is 0, which means it's closed, so tapping on it will expand the widget.
                      ///prefixIcon is of type Icon
                      icon: widget.prefixIcon != null
                          ? toggle == 1
                              ? Icon(Icons.arrow_back_ios)
                              : widget.prefixIcon!
                          : Icon(
                              toggle == 1 ? Icons.arrow_back_ios : Icons.search,
                              size: 20.0,
                            ),
                      onPressed: () async {
                        ///if the search bar is closed
                        if (toggle == 0) {
                          setState(() {
                            toggle = 1;
                            setState(() {
                              ///if the autoFocus is true, the keyboard will pop open, automatically
                              if (widget.autoFocus)
                                FocusScope.of(context).requestFocus(focusNode);
                            });

                            ///forward == expand
                            _con.forward();
                          });
                        } else {
                          ///if the autoFocus is true, the keyboard will close, automatically
                          setState(() {
                            if (widget.autoFocus) unfocusKeyboard();
                          });

                          if (widget.suggestionController != null &&
                              widget.suggestionController!.items.length > 0) {
                            setState(() {
                              widget.suggestionController!.clear(context);
                            });
                            Future.delayed(
                                Duration(
                                    milliseconds:
                                        widget.animationDurationInMilli), () {
                              setState(() {
                                toggle = 0;

                                ///reverse == close
                                _con.reverse();
                              });
                            });
                          } else {
                            ///if the search bar is expanded
                            toggle = 0;

                            ///reverse == close
                            _con.reverse();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              Builder(builder: (context) {
                if (toggle == 0) widget.suggestionController?.clear(context);
                return widget.suggestionController == null
                    ? SizedBox.shrink()
                    : AnimatedList(
                        key: widget.suggestionController!.listKey,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index, animation) {
                          return widget.suggestionController!
                              .sizeSuggestion(context, index, animation);
                        },
                      );
              })
            ],
          ),
        ),
      ),
    );
  }
}
