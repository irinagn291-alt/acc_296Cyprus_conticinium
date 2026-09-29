import SwiftUI
import UIKit

/// UIPageViewController for Reflect, Breathe, Ambient, and Rest.
/// A forward swipe on an unmarked leaf writes a FlutterMark and springs back.
struct FolioPages: UIViewRepresentable {
    @ObservedObject var desk: RitualDesk
    var reduceMotion: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(desk: desk)
    }

    func makeUIView(context: Context) -> FolioPageHost {
        let host = FolioPageHost()
        let controller = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        controller.view.backgroundColor = .clear
        host.install(controller)
        context.coordinator.attach(controller)
        context.coordinator.show(desk.folio.current, animated: false, reduceMotion: reduceMotion)
        return host
    }

    func updateUIView(_ uiView: FolioPageHost, context: Context) {
        context.coordinator.desk = desk
        context.coordinator.reduceMotion = reduceMotion
        context.coordinator.refreshHosts()
        context.coordinator.show(desk.folio.current, animated: true, reduceMotion: reduceMotion)
        if desk.flutterPulse != context.coordinator.lastFlutter {
            context.coordinator.lastFlutter = desk.flutterPulse
            if let page = uiView.pageController {
                context.coordinator.springBack(in: page, reduceMotion: reduceMotion)
            }
        }
    }

    @MainActor
    final class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var desk: RitualDesk
        var reduceMotion = false
        var lastFlutter = 0
        private var hosts: [LeafKind: UIHostingController<LeafColumn>] = [:]
        private var gestureLock = false
        private weak var pageController: UIPageViewController?

        init(desk: RitualDesk) {
            self.desk = desk
        }

        func attach(_ controller: UIPageViewController) {
            pageController = controller
            for kind in LeafKind.canonical {
                let host = UIHostingController(rootView: LeafColumn(desk: desk, kind: kind))
                host.view.backgroundColor = .clear
                hosts[kind] = host
            }
        }

        func refreshHosts() {
            for kind in LeafKind.canonical {
                hosts[kind]?.rootView = LeafColumn(desk: desk, kind: kind)
            }
        }

        func show(_ kind: LeafKind, animated: Bool, reduceMotion: Bool) {
            guard !gestureLock, let pageController, let host = hosts[kind] else { return }
            let current = pageController.viewControllers?.first as? UIHostingController<LeafColumn>
            if current?.rootView.kind == kind { return }
            let direction = direction(toward: kind, from: current?.rootView.kind)
            if reduceMotion {
                pageController.setViewControllers([host], direction: direction, animated: false)
                pageController.view.alpha = 0.45
                UIView.animate(withDuration: 0.25) {
                    pageController.view.alpha = 1
                }
            } else {
                pageController.setViewControllers([host], direction: direction, animated: animated)
            }
        }

        func springBack(in pageController: UIPageViewController, reduceMotion: Bool) {
            guard let host = hosts[desk.folio.current] else { return }
            if reduceMotion {
                pageController.view.alpha = 0.4
                pageController.setViewControllers([host], direction: .reverse, animated: false)
                UIView.animate(withDuration: 0.25) {
                    pageController.view.alpha = 1
                }
                return
            }
            pageController.setViewControllers([host], direction: .reverse, animated: true)
            let shift = CASpringAnimation(keyPath: "transform.translation.x")
            shift.fromValue = 28
            shift.toValue = 0
            shift.damping = 14
            shift.initialVelocity = 0.4
            shift.duration = 0.36
            pageController.view.layer.add(shift, forKey: "flutter")
        }

        nonisolated func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController
        ) -> UIViewController? {
            MainActor.assumeIsolated {
                neighbor(of: viewController, step: -1)
            }
        }

        nonisolated func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController
        ) -> UIViewController? {
            MainActor.assumeIsolated {
                neighbor(of: viewController, step: 1)
            }
        }

        nonisolated func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]
        ) {
            MainActor.assumeIsolated {
                gestureLock = true
            }
        }

        nonisolated func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            MainActor.assumeIsolated {
                guard completed,
                      let from = kind(of: previousViewControllers.first),
                      let to = kind(of: pageViewController.viewControllers?.first),
                      from != to
                else {
                    gestureLock = false
                    return
                }
                Task { @MainActor in
                    await self.desk.resolveSwipe(from: from, to: to)
                    self.gestureLock = false
                    self.show(self.desk.folio.current, animated: true, reduceMotion: self.reduceMotion)
                }
            }
        }

        private func neighbor(of viewController: UIViewController, step: Int) -> UIViewController? {
            guard desk.folio.fold != .rested, let kind = kind(of: viewController) else { return nil }
            guard let index = LeafKind.canonical.firstIndex(of: kind) else { return nil }
            let next = index + step
            guard LeafKind.canonical.indices.contains(next) else { return nil }
            return hosts[LeafKind.canonical[next]]
        }

        private func kind(of viewController: UIViewController?) -> LeafKind? {
            (viewController as? UIHostingController<LeafColumn>)?.rootView.kind
        }

        private func direction(toward kind: LeafKind, from current: LeafKind?) -> UIPageViewController.NavigationDirection {
            guard let current,
                  let nextIndex = LeafKind.canonical.firstIndex(of: kind),
                  let currentIndex = LeafKind.canonical.firstIndex(of: current)
            else {
                return .forward
            }
            return nextIndex >= currentIndex ? .forward : .reverse
        }
    }
}

/// Keeps the page controller's view inside a UIView so SwiftUI can host it.
final class FolioPageHost: UIView {
    private(set) var pageController: UIPageViewController?

    func install(_ controller: UIPageViewController) {
        pageController = controller
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

/// One measured column. A rule, then Keep and Turn. The current page name is the italic moment.
struct LeafColumn: View {
    @ObservedObject var desk: RitualDesk
    let kind: LeafKind
    @Environment(\.horizontalSizeClass) private var sizeClass
    @ScaledMetric(relativeTo: .title) private var artFloor: CGFloat = 192

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                page(width: proxy.size.width)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height, alignment: .topLeading)
                    .padding(.horizontal, FolioChrome.space(3))
                    .padding(.bottom, FolioChrome.space(3))
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    @ViewBuilder
    private func page(width: CGFloat) -> some View {
        let inner = max(width - FolioChrome.space(6), FolioChrome.space(20))
        let column = min(inner, FolioChrome.measure)
        if sizeClass == .regular {
            VStack(alignment: .leading, spacing: FolioChrome.space(3)) {
                HStack(alignment: .top, spacing: FolioChrome.space(3)) {
                    writing
                        .frame(width: column, alignment: .leading)
                    art
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .frame(minHeight: artFloor)
                }
                below
            }
        } else {
            VStack(alignment: .leading, spacing: FolioChrome.space(3)) {
                writing
                    .frame(width: column, alignment: .leading)
                art
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .frame(minHeight: artFloor)
                below
            }
        }
    }

    /// Measured column, then the rule, then the verb. Art and the index sit after that.
    private var writing: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(2)) {
            Text(pageName(kind))
                .font(FolioChrome.leafName)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .staggered(index: 0)
            Text(jobTitle)
                .font(FolioChrome.display)
                .foregroundStyle(DesignTokens.ink)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .staggered(index: 1)
            Text(pageLine)
                .font(FolioChrome.body)
                .foregroundStyle(DesignTokens.ink)
                .fixedSize(horizontal: false, vertical: true)
                .staggered(index: 2)
            if kind != .rest {
                Text(FolioCount.seconds(desk.durations.seconds(for: kind)))
                    .font(FolioChrome.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .monospacedDigit()
                    .staggered(index: 3)
            }
            FolioHairline()
            if desk.beatRunning, desk.folio.current == kind {
                Text(cueWord)
                    .font(FolioChrome.headline)
                    .foregroundStyle(DesignTokens.accent)
            }
            if let notice = desk.notice, desk.folio.current == kind {
                Text(notice)
                    .font(FolioChrome.caption)
                    .foregroundStyle(DesignTokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            verbs
        }
    }

    @ViewBuilder
    private var below: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(3)) {
            if let night = desk.sealedNights.first, desk.folio.current == kind {
                lastNight(night)
            }
            orderMeasure
                .frame(maxWidth: FolioChrome.measure, alignment: .leading)
        }
    }

    private var art: some View {
        Image(artName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(FolioChrome.space(2))
            .background(DesignTokens.surface)
            .clipShape(RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FolioChrome.surfaceRadius, style: .continuous)
                    .stroke(DesignTokens.muted.opacity(0.45), lineWidth: 1)
            )
            .clipped()
            .accessibilityHidden(true)
    }

    private func lastNight(_ night: RitualSession) -> some View {
        Button {
            desk.showHistory = true
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: FolioChrome.space(2)) {
                VStack(alignment: .leading, spacing: FolioChrome.space(1)) {
                    Text("Last sealed night")
                        .font(FolioChrome.caption)
                        .foregroundStyle(DesignTokens.muted)
                    Text(FolioCount.day(from: night.daykey))
                        .font(FolioChrome.headline)
                        .foregroundStyle(DesignTokens.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer(minLength: FolioChrome.space(2))
                Text(flutterLine(night.folio.flutters.count))
                    .font(FolioChrome.caption)
                    .foregroundStyle(DesignTokens.ink)
                    .monospacedDigit()
                    .lineLimit(1)
                    .layoutPriority(1)
            }
        }
        .buttonStyle(FolioPlateStyle())
        .accessibilityLabel("Last sealed night")
    }

    private var orderMeasure: some View {
        VStack(alignment: .leading, spacing: FolioChrome.space(1)) {
            ForEach(LeafKind.canonical, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: FolioChrome.space(2)) {
                    Text(pageName(item))
                        .font(item == desk.folio.current ? FolioChrome.headline : FolioChrome.caption)
                        .foregroundStyle(item == desk.folio.current ? DesignTokens.ink : DesignTokens.muted)
                        .lineLimit(1)
                    Spacer(minLength: FolioChrome.space(2))
                    Text(stageWord(item))
                        .font(FolioChrome.caption)
                        .foregroundStyle(DesignTokens.muted)
                        .lineLimit(1)
                        .layoutPriority(1)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var verbs: some View {
        if desk.folio.current != kind {
            Text(parkedLine)
                .font(FolioChrome.caption)
                .foregroundStyle(DesignTokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        } else if desk.folio.fold == .rested {
            Button("Open history") {
                desk.showHistory = true
            }
            .buttonStyle(FolioCapsuleStyle())
        } else if kind == .rest {
            Button("Rest") {
                Task { await desk.restTonight() }
            }
            .buttonStyle(FolioCapsuleStyle(isLoading: desk.showWait))
            .disabled(!desk.canRest || desk.resting)
            .accessibilityHint("Seals tonight when Reflect, Breathe, and Ambient are each kept.")
        } else if desk.canBank {
            Button("Keep this page") {
                desk.beginBank()
            }
            .buttonStyle(FolioCapsuleStyle(isLoading: desk.showWait))
            .disabled(desk.beatRunning || desk.banking)
            if desk.beatRunning {
                Button("End early") {
                    Task { await desk.skipBeat() }
                }
                .buttonStyle(FolioQuietStyle())
            }
            Button("Turn forward") {
                Task { await desk.turnForward() }
            }
            .buttonStyle(FolioQuietStyle())
            .disabled(!desk.canTurn)
            .accessibilityHint("Moves forward only after this page is kept. An early turn stays here.")
        } else {
            Text("Page kept")
                .font(FolioChrome.caption)
                .foregroundStyle(DesignTokens.muted)
            Button("Turn forward") {
                Task { await desk.turnForward() }
            }
            .buttonStyle(FolioCapsuleStyle())
            .disabled(!desk.canTurn)
            .accessibilityHint("Moves forward only after this page is kept. An early turn stays here.")
        }
    }

    private var jobTitle: String {
        if desk.folio.fold == .rested {
            return "This night is sealed"
        }
        if kind == .rest {
            return "Rest seals the night"
        }
        if desk.folio.current == kind, desk.canBank {
            return "Keep this page"
        }
        if desk.folio.leaf(kind)?.isBanked == true {
            return "This page is kept"
        }
        return "Keep this page"
    }

    private var pageLine: String {
        switch kind {
        case .reflect:
            return "Sit with the day. Keep this page, then turn forward."
        case .breathe:
            return "Follow the beat. Keep this page, then turn forward."
        case .ambient:
            return "Let the wash hold. Keep this page, then turn toward rest."
        case .rest:
            return "Rest once Reflect, Breathe, and Ambient are each kept."
        }
    }

    private var parkedLine: String {
        if desk.folio.leaf(kind)?.isBanked == true {
            return "This page already holds its mark."
        }
        return "Turn back here when you want this page."
    }

    private func stageWord(_ item: LeafKind) -> String {
        if desk.folio.fold == .rested, item == .rest {
            return "Sealed"
        }
        if desk.folio.leaf(item)?.isBanked == true {
            return "Kept"
        }
        if desk.folio.current == item {
            return "Now"
        }
        return "Waiting"
    }

    private func pageName(_ item: LeafKind) -> String {
        switch item {
        case .reflect: return "Reflect"
        case .breathe: return "Breathe"
        case .ambient: return "Ambient"
        case .rest: return "Rest"
        }
    }

    private func flutterLine(_ count: Int) -> String {
        let digits = FolioCount.integer(count)
        if count == 1 {
            return digits + " flutter"
        }
        return digits + " flutters"
    }

    private var cueWord: String {
        switch desk.cue {
        case .inhale: return "Inhale"
        case .hold: return "Hold"
        case .exhale: return "Exhale"
        case .settle: return "Settle"
        }
    }

    private var artName: String {
        switch kind {
        case .reflect: return "ctn_LeafReflect"
        case .breathe: return "ctn_LeafBreathe"
        case .ambient: return "ctn_LeafAmbient"
        case .rest: return "ctn_LeafRest"
        }
    }
}
