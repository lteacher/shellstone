import 'events.dart';
import '../metadata/annotations.dart';

/// Adapter event to make it more pleasant than calling the Event constructor
class AdapterEvent extends Event {
  AdapterEvent(name,data) : super(Adapter,name,data);
}
