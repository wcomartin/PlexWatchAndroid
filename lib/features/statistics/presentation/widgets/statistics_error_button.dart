import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/helpers/color_palette_helper.dart';
import '../bloc/statistics_bloc.dart';

class StatisticsErrorButton extends StatelessWidget {
  final Failure failure;
  final Completer completer;
  final StatisticsEvent statisticsAddedEvent;

  const StatisticsErrorButton({
    Key key,
    @required this.failure,
    @required this.completer,
    @required this.statisticsAddedEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return failure == SettingsFailure() || failure == MissingServerFailure()
        ? RaisedButton.icon(
            icon: FaIcon(
              FontAwesomeIcons.cogs,
              color: TautulliColorPalette.not_white,
            ),
            label: Text('Go to settings'),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/settings');
            },
          )
        : RaisedButton.icon(
            icon: FaIcon(
              FontAwesomeIcons.redoAlt,
              color: TautulliColorPalette.not_white,
            ),
            label: Text('Retry'),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              context.read<StatisticsBloc>().add(statisticsAddedEvent);
              return completer.future;
            },
          );
  }
}
