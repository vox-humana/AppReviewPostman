import Foundation

public enum CountryCode: String, CaseIterable, Codable {
    case ae
    case ag
    case ai
    case al
    case am
    case ao
    case ar
    case at
    case au
    case az
    case bb
    case be
    case bf
    case bg
    case bh
    case bj
    case bm
    case bn
    case bo
    case br
    case bs
    case bt
    case bw
    case by
    case bz
    case ca
    case cg
    case ch
    case cl
    case cn
    case co
    case cr
    case cv
    case cy
    case cz
    case de
    case dk
    case dm
    case `do`
    case dz
    case ec
    case ee
    case eg
    case es
    case fi
    case fj
    case fm
    case fr
    case gb
    case gd
    case gh
    case gm
    case gr
    case gt
    case gw
    case gy
    case hk
    case hn
    case hr
    case hu
    case id
    case ie
    case il
    case `in`
    case `is`
    case it
    case jm
    case jo
    case jp
    case ke
    case kg
    case kh
    case kn
    case kr
    case kw
    case ky
    case kz
    case la
    case lb
    case lc
    case lk
    case lr
    case lt
    case lu
    case lv
    case md
    case mg
    case mk
    case ml
    case mn
    case mo
    case mr
    case ms
    case mt
    case mu
    case mw
    case mx
    case my
    case mz
    case na
    case ne
    case ng
    case ni
    case nl
    case np
    case no
    case nz
    case om
    case pa
    case pe
    case pg
    case ph
    case pk
    case pl
    case pt
    case pw
    case py
    case qa
    case ro
    case ru
    case sa
    case sb
    case sc
    case se
    case sg
    case si
    case sk
    case sl
    case sn
    case sr
    case st
    case sv
    case sz
    case tc
    case td
    case th
    case tj
    case tm
    case tn
    case tr
    case tt
    case tw
    case tz
    case ua
    case ug
    case us
    case uy
    case uz
    case vc
    case ve
    case vg
    case vn
    case ye
    case za
    case zw
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
