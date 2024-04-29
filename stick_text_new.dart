import 'dart:io';
import 'package:app_real_estate/components/color_picker.dart';
import 'package:app_real_estate/components/fonts.dart';
import 'package:app_real_estate/components/shape_pointers/circle.dart';
import 'package:app_real_estate/components/shape_pointers/line.dart';
import 'package:app_real_estate/components/shape_pointers/rect.dart';
import 'package:app_real_estate/components/shape_pointers/rrect.dart';
import 'package:app_real_estate/components/shape_pointers/shape_sizes.dart';
import 'package:app_real_estate/cubit/bytes_cubit.dart';
import 'package:app_real_estate/cubit/crop_cubit.dart';
import 'package:app_real_estate/cubit/image_widgets_cubit.dart';
import 'package:app_real_estate/cubit/shape_values_cubit.dart';
import 'package:app_real_estate/widgets/dropdown_opacity.dart';
import 'package:app_real_estate/widgets/dropdown_stroke.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:text_editor/text_editor.dart';
import 'package:app_real_estate/components/stickers.dart';
import 'package:app_real_estate/cubit/image_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';

class StickTextNew extends StatefulWidget {
  const StickTextNew({super.key});

  @override
  State<StickTextNew> createState() => _StickTextNewState();
}

class _StickTextNewState extends State<StickTextNew>
    with TickerProviderStateMixin {
  bool spin = false;
  // late final TabController _tabController;

  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Custom'),
    Tab(text: 'Light'),
    Tab(text: 'Dark'),
  ];
  late LindiController lindiController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    int index =
        int.parse(ModalRoute.of(context)!.settings.arguments.toString());
    // Retrieve imageWidgets from context
    List<List<dynamic>>? imageWidgets =
        context.read<ImageWidgetsCubit>().state.imageWidgets[index];

    // Initialize lindiController with imageWidgets if available, else with an empty list
    lindiController = LindiController(
        oldWidgets: imageWidgets,
        updateValue: updateOldWidgets,
        imageIndex: index);
 

    // _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    // _tabController.dispose();
    lindiController.dispose();
    super.dispose();
    
  }

  // final GlobalKey<ScaffoldState> endDrawerKey = GlobalKey<ScaffoldState>();

  // Method to update oldWidgets in lindiController
  updateOldWidgets(List<List<dynamic>> newWidgets, int index) {
    final List<List<dynamic>> updatedWidgets = newWidgets.map((widget) {
      return [
        widget[0], // widget is at 0
        widget[1], //  scale is at index 1
        widget[2], //  matrix is at index 2
      ];
    }).toList();

    context
        .read<ImageWidgetsCubit>()
        .state
        .setOneImageWidgets(updatedWidgets, index);
    setState(() {});
  }

  int listIndex = 0;
  bool showText = false;
  bool showShape = true;
  bool showSticks = false;
  Color selectedColor = Colors.amber;
  double opacityValue = 1.0;
  double strokeWidth = 2.0;
  // addTextWidgetToLindicontroller(Widget textWidget) async {
  //   await lindiController.addWidget(textWidget);
  //   print("addTextWidgetToLindicontroller");
  // }

  @override
  Widget build(BuildContext context) {
    int index =
        int.parse(ModalRoute.of(context)!.settings.arguments.toString());
    int myInt = index;
    List<XFile> imageList = context.read<ImageListCubit>().state.imageFileList!;

    final cropListState = context.read<CropListCubit>().state.imageFileList!;
    File tempFile = File(cropListState[2].path);

    print(
        '${tempFile.readAsBytesSync().toString()},stick txt new render edildim');

    double widthMedia = MediaQuery.of(context).size.width;
    print(widthMedia);

    double heightMedia = MediaQuery.of(context).size.height;
    print(heightMedia);
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          leading: CloseButton(
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.grey[900],
          centerTitle: true,
          title: const Text(
            "Stick page",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  try {
                    await lindiController.updateNewWidgets();
                    // setState(() {
                    //   spin = true;
                    // });
                    Uint8List? bytes = await lindiController.saveAsUint8List();

                    final file = File(imageList[myInt].path);
                    await file.writeAsBytes(bytes!, mode: FileMode.write);
                    // setState(() {
                    //   spin = false;
                    // });
                    await File(imageList[index].path).writeAsBytes(
                        File(cropListState[2].path).readAsBytesSync(),
                        mode: FileMode.write);

                    var img = Image.file(file);
                    await img.image.evict();

                    if (!mounted) return;
                    Navigator.pop(context);

                    // spin = false;
                  } catch (e) {
                    setState(() {
                      spin = false;
                      print("Error in lindicontroller done: $e");
                    });
                  }
                },
                icon: const Icon(
                  Icons.done,
                  color: Colors.white,
                )),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: spin
                ? const SpinKitRotatingCircle(
                    color: Colors.white,
                    size: 50.0,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        // color: Colors.blueGrey,
                        height: 270.w,
                        width: 360.w,
                        child: InteractiveViewer(
                          child: Center(
                            child: Stack(children: [
                              LindiStickerWidget(
                                controller: lindiController,
                                child: SizedBox(
                                  height: 264.w,
                                  width: 352.w,
                                  child: Center(
                                    child: Image.memory(
                                      Uint8List.fromList(
                                          tempFile.readAsBytesSync()),
                                      key: UniqueKey(),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      showShape
                          ? SizedBox(
                              width: 360.w,
                              height: 10.h,
                            )
                          : showSticks
                              ? _showSticks()
                              : SizedBox(
                                  width: 360.w,
                                  height: 10.h,
                                ),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        showText = false;
                                        showShape = true;
                                        showSticks = false;
                                      });
                                      // endDrawerKey.currentState!
                                      //     .openEndDrawer();
                                    },
                                    icon: const Icon(Icons.format_shapes),
                                    iconSize: 32,
                                    color: Colors.white,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        // showStick = false;
                                        showText = false;
                                        showShape = false;
                                        showSticks = true;
                                      });
                                      // endDrawerKey.currentState!
                                      //     .openEndDrawer();
                                    },
                                    icon: const Icon(Icons.new_label),
                                    iconSize: 32,
                                    color: Colors.white,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showText = true;
                                        showShape = false;
                                        showSticks = false;
                                      });
                                    },
                                    icon: const Icon(Icons.text_increase),
                                    iconSize: 32,
                                    color: Colors.white,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      // setState(() {
                                      //   showText = false;
                                      //   showShape = false;
                                      //   showSticks = false;
                                      // });
                                      setState(() {
                                        spin = true;
                                      });
                                      await _cropImage(
                                        context: context,
                                        index: myInt,
                                      );
                                      setState(() {
                                        spin = false;
                                      });
                                    },
                                    icon: const Icon(Icons.crop_rotate),
                                    iconSize: 32,
                                    color: Colors.white,
                                  ),
                                ],
                              )
                            ]),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      if (showText) _showTextScaf(),
    ]);
  }

  _showSticks() {
    return Column(
      children: [
        Container(
          height: 200.h,
          width: 330.w,
          color: Colors.transparent,
          child: DefaultTabController(
              length: myTabs.length,
              child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Column(
                    children: [
                      const TabBar(
                        unselectedLabelColor: Colors.white,
                        dividerColor: Colors.white,
                        labelColor: Colors.amber,
                        indicatorColor: Colors.amber,
                        tabs: myTabs,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          height: 100.h,
                          child: TabBarView(children: [
                            Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: GridView.count(
                                crossAxisCount: 8,
                                crossAxisSpacing: 5, //spacing between items
                                mainAxisSpacing: 5,
                                children: Stickers().list()[0].map(
                                  (e) {
                                    return InkWell(
                                      onTap: () async {
                                        await lindiController
                                            .addWidget(Image.asset(
                                          e,
                                          width:
                                              50, // Adjust this value based on your requirements
                                        ));
                                        setState(() {});
                                        // endDrawerKey.currentState!
                                        //     .closeEndDrawer();
                                      },
                                      child: Image.asset(e),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                            Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: ListView(children: const <Widget>[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(children: []),
                                ),
                              ]),
                            ),
                            Container(
                              decoration:
                                  const BoxDecoration(color: Colors.white),
                              child: ListView(children: const <Widget>[
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(children: []),
                                ),
                              ]),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ))),
        ),
      ],
    );
  }

  _showTextScaf() {
    return Scaffold(
      key: UniqueKey(),
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 0),
        child: SafeArea(
          child: SizedBox(
            // width: 360.w,
            // height: 500.h,
            child: TextEditor(
              textStyle: const TextStyle(color: Colors.white, fontSize: 25.0),
              textAlingment: TextAlign.center,
              fonts: Fonts().list(),
              minFontSize: 10,
              maxFontSize: 70,
              onEditCompleted: (style, align, text) async {
                try {
                  if (text.isNotEmpty) {
                    await lindiController.addWidget(Text(
                      text,
                      textAlign: align,
                      style: style,
                    ));
                    // addTextWidgetToLindicontroller(Text(
                    //   text,
                    //   textAlign: align,
                    //   style: style,
                    // ));
                    setState(() {
                      showText = false;
                      showShape = false;
                      showSticks = false;
                    });
                  } else {
                    setState(() {
                      showText = false;
                      showShape = false;
                      showSticks = false;
                    });
                  }
                } catch (e) {
                  print("Error adding text: $e");
                  // Handle the error here, if needed
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<XFile?> _cropImage(
      {required BuildContext context, required int index}) async {
    final cropListState = context.read<CropListCubit>().state.imageFileList!;
    // final imageListState = context.read<ImageListCubit>().state.imageFileList!;
    final imagebytesListState = context.read<BytesCubit>().state.bytesList!;

    await File(cropListState[1].path)
        .writeAsBytes(imagebytesListState[index], mode: FileMode.write);

    CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: cropListState[index].path,
        aspectRatioPresets: [
          // CropAspectRatioPreset.square,
          // CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          // CropAspectRatioPreset.ratio16x9
        ],
        aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Scale & Crop',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
              rectWidth: 360.w,
              rectHeight: 270.w,
              resetAspectRatioEnabled: true,
              title: 'Scale & Crop',
              aspectRatioLockDimensionSwapEnabled: true,
              aspectRatioLockEnabled: true),
        ]);
    // XFile croppedFile = XFile(croppedImage!.path);

    // imageListState.replaceRange(index, index + 1, [croppedFile]);
    // if (File(cropListState[index]).readAsBytesSync() !=
    //     File(cropListState[index]).readAsBytesSync()) {}

    if (croppedImage != null) {
      var img = Image.file(File(croppedImage.path));
      await img.image.evict();
      await File(cropListState[2].path).writeAsBytes(
          File(croppedImage.path).readAsBytesSync(),
          mode: FileMode.write);
      // Update the state with the new file path or file object
      setState(() {});
    }

    // await File(cropListState[index])
    //     .writeAsBytes(imagebytesListState[index], mode: FileMode.write);

    if (!mounted) {}
    return null;
  }
}
