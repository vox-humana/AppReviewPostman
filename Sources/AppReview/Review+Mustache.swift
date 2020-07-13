import mustache

extension Sequence where Element == Review {
    public func format(template: String, countryCode: String) -> [String] {
        let tree = MustacheParser().parse(string: template)
        return map { $0.mustacheDict(for: countryCode) }
            .map(tree.render(object:))
    }
}
