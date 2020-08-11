
import 'dart:async';

import 'package:flutter/widgets.dart';

typedef EasyBlocStateModifier = void Function();

typedef EasyBlocStateProvider<S> = S Function();

typedef EasyBlocWidgetBuilder<T extends EasyBloc> = Widget Function(BuildContext context, T bloc);

abstract class EasyBloc<S> {
  final _stateController = StreamController<S>.broadcast();

  S _state;

  S get state => this._state;

  EasyBloc(this._state);

  void mutate(EasyBlocStateModifier stateModifier) {
    stateModifier();
    this._stateController.add(this._state);
  }

  void change(EasyBlocStateProvider<S> stateProvider) {
    this._state = stateProvider();
    this._stateController.add(this._state);
  }

  void dispose() {
    this._stateController.close();
  }
}

class EasyBlocBuilder<T extends EasyBloc> extends StatefulWidget {
  final T bloc;
  final ValueGetter<T> initBloc;
  final EasyBlocWidgetBuilder<T> builder;

  EasyBlocBuilder({Key key,
    this.bloc,
    this.initBloc,
    @required this.builder,})
      : assert(builder != null),
        super(key: key) {
    this.builder(null, this.bloc);
  }

  @override
  _EasyBlocBuilderState<T> createState() => _EasyBlocBuilderState<T>();
}

class _EasyBlocBuilderState<T extends EasyBloc> extends State<EasyBlocBuilder<T>> {
  T _bloc;

  @override
  void initState() {
    this.widget.builder(null, this.widget.bloc);

    super.initState();
    _bloc = (widget.bloc != null) ? widget.bloc : widget.initBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<dynamic>(
      initialData: this._bloc,
      stream: this._bloc._stateController.stream,
      builder: (context, snapshot) {
        return this.widget.builder(context, this._bloc);
      },
    );
  }
}
