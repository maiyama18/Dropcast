import ComposableArchitecture

public struct LicensesReducer: ReducerProtocol {
    public struct State: Equatable {
        var selectedLicense: LicensesPlugin.License?

        public init() {}
    }

    public enum Action: Equatable {
        case licenseSelected(LicensesPlugin.License?)
    }

    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .licenseSelected(let license):
            state.selectedLicense = license
            return .none
        }
    }
}
