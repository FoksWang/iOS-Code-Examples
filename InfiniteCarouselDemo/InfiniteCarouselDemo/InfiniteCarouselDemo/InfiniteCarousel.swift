//
//  InfiniteCarousel.swift
//  InfiniteCarouselDemo
//
//  Created by Hui Wang on 2025-03-05.
//

import SwiftUI
import Combine

struct InfiniteCarousel<Item, Cell: View>: View {
    private let data: [Item]
    private let duration: Double
    @State private var items: [Item] = []
    private let contentMargin: CGFloat
    private let spacing: CGFloat
    @ViewBuilder var cell: (Int, Item) -> Cell
    
    init(_ items: [Item], contentMargin: CGFloat? = nil, spacing: CGFloat? = nil, duration: Double = 3, @ViewBuilder cell: @escaping (Int, Item) -> Cell) {
        self.data = items
        self.contentMargin = contentMargin ?? 20
        self.spacing = spacing ?? 10
        self.duration = duration
        self.cell = cell
    }
    
    var body: some View {
        InfiniteScrollView(data, contentMargin: contentMargin, spacing: spacing, duration: duration, cell: cell)
    }
}

struct InfiniteScrollView<Item, Cell: View>: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State private var height: CGFloat = 1
    @State private var scrollPhase: ScrollPhase = .idle
    @State private var scrollID: Int?
    @State private var timer: Timer.TimerPublisher
    @State private var cancellable: Cancellable?
    private let dataMultiplier = 201
    
    private let data: [Item]
    private let duration: Double
    @State private var items: [Item] = []
    private let contentMargin: CGFloat
    private let spacing: CGFloat
    @ViewBuilder var cell: (Int, Item) -> Cell
    
    init(_ items: [Item], contentMargin: CGFloat, spacing: CGFloat, duration: Double, @ViewBuilder cell: @escaping (Int, Item) -> Cell) {
        self.data = items
        self.contentMargin = contentMargin
        self.spacing = spacing
        self.duration = duration
        self.cell = cell
        self._timer = .init(initialValue: Timer.publish(every: duration, on: .main, in: .common))
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                        cell(index, item)
                            .padding(spacing / 2)
                    }
                    .readSize(onChange: { size in
                        self.height = max(self.height, size.height)
                    })
                    .frame(width: max(0, proxy.size.width - contentMargin * 2))
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .safeAreaPadding(.horizontal, contentMargin)
        }
        .frame(height: height)
        .scrollPosition(id: $scrollID)
        .onScrollPhaseChange { _, newPhase in
            scrollPhase = newPhase
        }
        .onFirstAppear {
            items = Array(repeating: data, count: dataMultiplier).flatMap { $0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scrollID = data.count * (dataMultiplier - 1) / 2
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                startTimer()
            }
        }
        .onDisappear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                stopTimer()
            }
        }
        .onReceive(timer) { _ in
            guard duration > 0, scrollPhase == .idle, let currentScrollID = scrollID else { return }
            withAnimation(.easeInOut(duration: 0.5)) {
                scrollID = (currentScrollID + 1) % (data.count * dataMultiplier)
            }
        }
        .onChange(of: scenePhase) { _, newValue in
            switch newValue {
            case .active:
                startTimer()
            case .background, .inactive:
                stopTimer()
            default:
                break
            }
        }
    }
    
    private func startTimer() {
        guard duration > 0, cancellable == nil else { return }
        timer = Timer.publish(every: duration, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    private func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
        modifier(OnAppearModifier(perform: action))
    }
}

struct OnAppearModifier: ViewModifier {
    @State private var onAppearCalled = false
    private let action: (() -> Void)?
    
    init(perform action: (() -> Void)? = nil) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            if !onAppearCalled {
                onAppearCalled = true
                action?()
            }
        }
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
