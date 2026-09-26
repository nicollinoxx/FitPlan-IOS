import Foundation
import HotwireNative

extension BridgeComponent {
    static var allTypes: [BridgeComponent.Type] {
        [
            FormComponent.self,
            NavButtonComponent.self,
            MenuComponent.self,
            FlashMessageComponent.self
        ]
    }
}
