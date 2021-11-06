import Foundation

class Envelope: ObservableObject {
    @Published public var L1: Int = 0;
    @Published public var L2: Int = 0;
    @Published public var L3: Int = 0;
    @Published public var L4: Int = 0;

    @Published public var T1: Int = 0;
    @Published public var T2: Int = 0;
    @Published public var T3: Int = 0;
    @Published public var T4: Int = 0;

    public init() {
        self.L1 = 127
        self.L2 = 127
        self.L3 = 127
        self.L4 = 0

        self.T1 = 0
        self.T2 = 20
        self.T3 = 20
        self.T4 = 20
    }

    public init(
        l1: Int, t1: Int,
        l2: Int, t2: Int,
        l3: Int, t3: Int,
        l4: Int, t4: Int
    ) {
        self.L1 = l1
        self.L2 = l2
        self.L3 = l3
        self.L4 = l4

        self.T1 = t1
        self.T2 = t2
        self.T3 = t3
        self.T4 = t4
    }
}
