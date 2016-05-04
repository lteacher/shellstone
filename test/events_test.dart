import 'package:test/test.dart';
import 'package:shellstone/shellstone.dart';
import 'test_setups.dart';

main() {
  setUp(() {
    // Start shellstone to setup any annotations
    strapIn();
  });
  group('Events', () {
    test('@Hook on adapter configure is executed', () {
      expect(configureHook,equals(true));
    });

    test('@Hook on adapter connect is executed', () {
      expect(connectHook,equals(true));
    });

    test('@Hook on adapter build is executed', () {
      expect(buildHook,equals(true));
    });

    test('@Hook on custom event is executed', () async {
      await trigger(new Event(String,'random'));
      expect(customHook,equals(true));
    });

    test('@Listen on adapter configure is executed', () {
      expect(configureListen,equals(true));
    });

    test('@Listen on adapter connect is executed', () {
      expect(connectListen,equals(true));
    });

    test('@Listen on adapter build is executed', () {
      expect(buildListen,equals(true));
    });

    test('@Listen on custom event is executed', () async {
      await trigger(new Event(String,'random'));
      expect(buildListen,equals(true));
    });
  });
}

bool configureHook;
bool configureListen;
bool connectHook;
bool connectListen;
bool buildHook;
bool buildListen;
bool customHook;
bool customListen;

@Hook(Adapter.configure)
hookConfigure(event) {
  configureHook = true;
}

@Listen(Adapter.configure)
listenConfigure(event) => configureListen = true;

@Hook(Adapter.connect)
hookConnect(event) => connectHook = true;

@Listen(Adapter.connect)
listenConnect(event) => connectListen = true;

@Hook(Adapter.build)
hookBuild(event) {
  buildHook = true;
}

@Listen(Adapter.build)
listenBuild(event) => buildListen = true;

@Hook(const EventRegistration(String, 'random'))
hookCustom(event) => customHook = true;

@Listen(const EventRegistration(String, 'random'))
listenCustom(event) => customListen = true;
