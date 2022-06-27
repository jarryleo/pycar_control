import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'base_view_model.dart';

abstract class BasePage<T extends StatefulWidget, M extends BaseViewModel>
    extends State<T> {
  late M viewModel;

  @override
  initState() {
    viewModel = createViewModel();
    super.initState();
  }

  createViewModel();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewModel,
        builder: (context, child) {
          return contentView(context);
        }
    );
  }

  Widget contentView(BuildContext context);

  @override
  void dispose() {
    super.dispose();
  }
}
