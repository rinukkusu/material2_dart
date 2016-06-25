import "package:angular2/core.dart";
import "package:material2_dart/core/a11y/live_announcer.dart";

@Component(selector: "toolbar-demo", templateUrl: "live_announcer_demo.html")
class LiveAnnouncerDemo {
  MdLiveAnnouncer live;

  LiveAnnouncerDemo(this.live);

  announceText(String message) {
    live.announce(message);
  }
}
