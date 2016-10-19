import 'dart:async';

import 'package:build/build.dart';

import 'package:sass_builder/sass_builder.dart';

Future main() async {
  /// Builds a full package dependency graph for the current package.
  var graph = new PackageGraph.forThisPackage();
  var phases = new PhaseGroup();

  /// Give [Builder]s access to a [PackageGraph] so they can choose which
  /// packages to run on. This simplifies user code a lot, and helps to mitigate
  /// the transitive deps issue.
  SassBuilder.addPhases(phases, graph, new SassSettings());
  await build(phases);
}
