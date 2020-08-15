import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helpers/color_palette_helper.dart';
import '../../../../core/widgets/poster_chooser.dart';
import '../../domain/entities/activity.dart';
import '../bloc/activity_bloc.dart';
import 'activity_media_details.dart';
import 'activity_media_info.dart';
import 'background_image_chooser.dart';
import 'progress_bar.dart';
import 'status_poster_overlay.dart';
import 'time_eta.dart';
import 'time_total.dart';

class ActivityModalBottomSheet extends StatefulWidget {
  final ActivityItem activity;
  final String tautulliId;

  const ActivityModalBottomSheet({
    Key key,
    @required this.activity,
    @required this.tautulliId,
  }) : super(key: key);

  @override
  _ActivityModalBottomSheetState createState() =>
      _ActivityModalBottomSheetState();
}

class _ActivityModalBottomSheetState extends State<ActivityModalBottomSheet> {
  ActivityItem activity;

  @override
  void initState() {
    super.initState();
    activity = widget.activity;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityBloc, ActivityState>(
      listener: (context, state) {
        // Update the activityItem to the lastest data when a new ActivityLoadSuccess is pushed
        if (state is ActivityLoadSuccess) {
          setState(() {
            // If sessionId no longer exists for a given server close the modal
            try {
              List activityList =
                  state.activityMap[widget.tautulliId]['activity'];
              ActivityItem item = activityList.firstWhere(
                  (element) => element.sessionId == activity.sessionId);
              activity = item;
            } catch (_) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      child: Stack(
        children: <Widget>[
          // Use LayoutBulilder to pass constraints to ActivityMediaDetails
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            // Creates a transparent area for the poster to hover over
                            // Allows for that area to be tapped to dismiss the modal bottom sheet
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                height: 30,
                                color: Colors.transparent,
                              ),
                            ),
                            //* Activity art section
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Container(
                                height: 130,
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      child: BackgroundImageChooser(
                                        activity: activity,
                                      ),
                                    ),
                                    BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 25,
                                        sigmaY: 25,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                                left: 98,
                                                bottom: 4,
                                                right: 4,
                                              ),
                                              child: ActivityMediaInfo(
                                                activity: activity,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              right: 4,
                                              left: 98,
                                              top: 4,
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                //* User name
                                                Text(activity.friendlyName),
                                                //* Time left or Live tv channel
                                                activity.live == 0 &&
                                                        activity.duration !=
                                                            null
                                                    ? TimeTotal(
                                                        viewOffset:
                                                            activity.viewOffset,
                                                        duration:
                                                            activity.duration,
                                                      )
                                                    : activity.live == 1
                                                        ? Text(
                                                            '${activity.channelCallSign} ${activity.channelIdentifier}')
                                                        : SizedBox(),
                                              ],
                                            ),
                                          ),
                                          //* Progress bar
                                          activity.mediaType == 'photo' ||
                                                  activity.live == 1
                                              ? ProgressBar(
                                                  progress: 100,
                                                  transcodeProgress: 0,
                                                )
                                              : ProgressBar(
                                                  progress:
                                                      activity.progressPercent,
                                                  transcodeProgress: activity
                                                      .transcodeProgress,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        //* Poster
                        Positioned(
                          bottom: 10,
                          child: Container(
                            height: 130,
                            padding: EdgeInsets.only(
                              left: 4,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Stack(
                                children: <Widget>[
                                  PosterChooser(
                                    item: activity,
                                  ),
                                  if (activity.state == 'paused' ||
                                      activity.state == 'buffering')
                                    StatusPosterOverlay(state: activity.state),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (activity.duration != null)
                          Positioned(
                            right: 4,
                            bottom: 28,
                            child: TimeEta(
                              duration: activity.duration,
                              progressPercent: activity.progressPercent,
                            ),
                          ),
                      ],
                    ),
                    //* Activity details section
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        color: PlexColorPalette.river_bed,
                        child: ActivityMediaDetails(
                          constraints: constraints,
                          activity: activity,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
