import Foundation

// MARK: - Profile

struct ProfileResponse: Codable {
    let userId: Int
    let nickname: String
    let birthDate: String?
    let birthTime: String?
    let gender: String?
    let birthCalendarType: String?
    let birthIsLeapMonth: Bool?
}

struct ProfileUpdateRequest: Codable {
    let nickname: String?
    let birthDate: String
    let birthTime: String?
    let gender: String?
    let birthCalendarType: String?
    let birthIsLeapMonth: Bool?
}

// MARK: - Saju

struct PillarInfo: Codable {
    let characters: String
    let stemKorean: String
    let branchKorean: String
    let stemElement: String
    let branchElement: String
}

struct SajuResponse: Codable {
    let yearPillar: PillarInfo
    let monthPillar: PillarInfo
    let dayPillar: PillarInfo
    let timePillar: PillarInfo?
    let dayMasterKorean: String
    let dayMasterElement: String
    let dayPillarName: String
    let dayMasterStrength: String
    let elementDistribution: [String: Int]
    let yongsin: String?
}

// MARK: - Element Color Helper

extension String {
    /// 오행(五行) → 원에 사용할 색상
    var elementColor: ElementColor {
        switch self {
        case "목": return .wood
        case "화": return .fire
        case "토": return .earth
        case "금": return .metal
        case "수": return .water
        default:   return .unknown
        }
    }
}

enum ElementColor {
    case wood, fire, earth, metal, water, unknown

    var name: String {
        switch self {
        case .wood:    return "목"
        case .fire:    return "화"
        case .earth:   return "토"
        case .metal:   return "금"
        case .water:   return "수"
        case .unknown: return "-"
        }
    }
}
