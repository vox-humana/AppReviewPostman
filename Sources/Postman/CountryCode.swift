import Foundation

// App Store countries and regions:
// https://help.apple.com/app-store-connect/#/dev997f9cf7c
// ISO 3166-1 alpha-3 and alpha-2 codes:
// https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
// Last update date: 08-10-2021
enum CountryCode: String, CaseIterable, Codable {
    case AF
    case AE
    case AG
    case AI
    case AL
    case AM
    case AO
    case AR
    case AT
    case AU
    case AZ
    case BB
    case BE
    case BA
    case BF
    case BG
    case BH
    case BJ
    case BM
    case BN
    case BO
    case BR
    case BS
    case BT
    case BW
    case BY
    case BZ
    case CM
    case CA
    case CG
    case CH
    case CI
    case CL
    case CN
    case CO
    case CD
    case CR
    case CV
    case CY
    case CZ
    case DE
    case DK
    case DM
    case DO
    case DZ
    case EC
    case EE
    case EG
    case ES
    case FI
    case FJ
    case FM
    case FR
    case GA
    case GB
    case GD
    case GE
    case GH
    case GM
    case GR
    case GT
    case GW
    case GY
    case HK
    case HN
    case HR
    case HU
    case ID
    case IE
    case IL
    case IN
    case IQ
    case IS
    case IT
    case JM
    case JO
    case JP
    case KE
    case KG
    case KH
    case KN
    case KR
    case KW
    case KY
    case KZ
    case LA
    case LB
    case LY
    case LC
    case LK
    case LR
    case LT
    case LU
    case LV
    case MA
    case MD
    case MV
    case MG
    case MK
    case ML
    case MM
    case MN
    case ME
    case MO
    case MR
    case MS
    case MT
    case MU
    case MW
    case MX
    case MY
    case MZ
    case NA
    case NE
    case NG
    case NI
    case NL
    case NO
    case NP
    case NR
    case NZ
    case OM
    case PA
    case PE
    case PG
    case PH
    case PK
    case PL
    case PT
    case PW
    case PY
    case QA
    case RO
    case RU
    case RW
    case SA
    case SB
    case SC
    case SE
    case SG
    case SI
    case SK
    case SL
    case SN
    case SR
    case RS
    case ST
    case SV
    case SZ
    case TC
    case TD
    case TH
    case TJ
    case TM
    case TN
    case TO
    case TR
    case TT
    case TW
    case TZ
    case UA
    case UG
    case US
    case UY
    case UZ
    case VC
    case VE
    case VG
    case VN
    case VU
    case XK
    case YE
    case ZA
    case ZM
    case ZW
}

extension CountryCode {
    var flag: String {
        let scalars = rawValue.uppercased().unicodeScalars
        assert(scalars.count == 2)
        let base: UInt32 = 127_397
        return String(String.UnicodeScalarView(scalars.compactMap { UnicodeScalar(base + $0.value) }))
    }

    var countryName: String? {
        Locale.current.localizedString(forRegionCode: rawValue)
    }
}
