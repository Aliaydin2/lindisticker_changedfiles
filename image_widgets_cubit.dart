import 'package:bloc/bloc.dart';

// State class for the ImageWidgetsCubit
class ImageWidgetsState {
  List<List<List<dynamic>>> imageWidgets = <List<List<dynamic>>>[];

  ImageWidgetsState(this.imageWidgets);

  // Method to set a new list of widgets
  setOneImageWidgets(List<List<dynamic>> oneImageWidgets, int index) {
    imageWidgets[index] = oneImageWidgets;
  }
}

// Cubit class to manage the state of draggable widgets
class ImageWidgetsCubit extends Cubit<ImageWidgetsState> {
  ImageWidgetsCubit({required ImageWidgetsState initialState})
      : super(initialState);
}
