
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
//---------------------------
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
