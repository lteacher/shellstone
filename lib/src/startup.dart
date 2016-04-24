part of shellstone;

/// The main startup class is... Shellstone
class Shellstone {
  static start() {
    // Scan and build metadata
    new Metadata().scan();
  }
}
