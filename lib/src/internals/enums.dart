/*
    Author: Aditi Patil
    Email: appatil595@gmail.com
    createTime:2026-03-09
*/

/// The current status of the refresh header.
enum RefreshStatus {
  /// Initial state, when not being overscrolled into, or after the overscroll
  /// is canceled or after done and the sliver retracted away.
  idle,

  /// Dragged far enough that the onRefresh callback will be triggered.
  canRefresh,

  /// The indicator is refreshing, waiting for the completion callback.
  refreshing,

  /// The indicator refresh has successfully completed.
  completed,

  /// The indicator refresh has failed.
  failed,

  /// Dragged far enough that the onTwoLevel callback will be triggered.
  canTwoLevel,

  /// The indicator is in the process of opening the two-level mode.
  twoLevelOpening,

  /// The indicator is currently in two-level mode.
  twoLeveling,

  /// The indicator is in the process of closing the two-level mode.
  twoLevelClosing
}

/// The current status of the loading footer.
enum LoadStatus {
  /// Initial state, which can trigger loading more by a pull-up gesture.
  idle,

  /// Dragged far enough that the onLoading callback will be triggered.
  canLoading,

  /// The indicator is currently loading more data.
  loading,

  /// The indicator has no more data to load; this state prevents further loading.
  noMore,

  /// The indicator load has failed. It can be clicked to retry.
  /// If you want pull-up to trigger retry, set enableLoadingWhenFailed to true.
  failed
}

/// The display style of the refresh header indicator.
enum RefreshStyle {
  /// The indicator box always follows the content.
  follow,

  /// The indicator box follows content until it reaches the top and is fully visible, then it remains stationary.
  unFollow,

  /// The indicator size zooms with the boundary distance, appearing to be behind the content.
  behind,

  /// The indicator is shown above the content, similar to Flutter's native RefreshIndicator.
  front
}

/// The display style of the loading footer indicator.
enum LoadStyle {
  /// The indicator always occupies its layout extent, regardless of its state.
  showAlways,

  /// The indicator always has a layout extent of 0.0, regardless of its state.
  hideAlways,

  /// The indicator follows the content and only occupies its layout extent while loading.
  showWhenLoading,
}

/// Centralized magic constants used across the package.
abstract final class SmartRefresherConstants {
  /// Default distance needed to trigger a pull-down refresh.
  static const double defaultHeaderTriggerDistance = 80.0;

  /// Default distance needed to trigger pull-up loading.
  static const double defaultFooterTriggerDistance = 15.0;

  /// Default distance needed to trigger two-level mode.
  static const double defaultTwiceTriggerDistance = 150.0;

  /// Default distance needed to close two-level mode from the bottom.
  static const double defaultCloseTwoLevelDistance = 80.0;

  /// Default height for the refresh header.
  static const double defaultHeaderHeight = 60.0;

  /// Default height for the loading footer.
  static const double defaultFooterHeight = 60.0;

  /// Default animation duration for state transitions.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// Default duration the indicator stays in "completed" or "failed" state.
  static const Duration defaultCompleteDuration = Duration(milliseconds: 600);
}
