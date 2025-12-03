import 'package:flutter/material.dart';

class TrackTraining extends StatefulWidget{
  final VoidCallback onBack;
  final String? dayIso;

  const TrackTraining({
    super.key,
    required this.onBack,
    required this.dayIso,
  });

  @override
  State<StatefulWidget> createState() => _TrackTrainingState();
}

class _TrackTrainingState extends State<TrackTraining> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}