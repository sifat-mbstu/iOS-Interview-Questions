//
//  FrameVsBoundVC.swift
//  UIKit-Examination
//
//  Created by Sifatul on 30/6/26.
//

import UIKit

/*
 1) What is Frame and Bounds?

    Bounds: The bounds of a UIView is the rectangle, expressed as location (x, y)
            and size (width & height), relative to its OWN coordinate system.
            Its origin is (0, 0) by default.

    Frame:  The frame of a UIView is the rectangle, expressed as location (x, y)
            and size (width & height), relative to its SUPERVIEW's coordinate system.

 2) In which case can frame and bounds x/y be different?  -> Demo 2 (Child Offset)
    A child placed at the centre of a bigger parent has a frame origin that is
    offset inside the parent (e.g. x 75, y 75), while its bounds origin is still
    (0, 0) because bounds is measured in the child's own coordinate system.

 3) In which case can width/height be different?  -> Demo 1 (Rotation)
    When you rotate a view, its bounds (the view's own un-rotated rectangle) keeps
    the SAME width/height, but its frame is the smallest axis-aligned rectangle in
    the superview that still contains the rotated view, so the frame GROWS.
    The two are equal only when transform == .identity.
 */

final class FrameVsBoundVC: UIViewController {

    // MARK: - Demo selection

    private enum Demo: Int {
        case rotation
        case childOffset
    }
    private var currentDemo: Demo = .rotation

    // MARK: - Controls

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["1 · Rotation", "2 · Child Offset"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(demoChanged(_:)), for: .valueChanged)
        return control
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var rotationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = Float.pi * 2          // 0 … 360°
        slider.value = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(rotationChanged(_:)), for: .valueChanged)
        return slider
    }()

    // MARK: - Stage (holds the demo views, positioned with frames)

    private let stage = UIView()

    // Demo 1 — the axis-aligned box that visualises the rectangle's FRAME.
    // It sits behind the rectangle and is resized to match `rectangleView.frame`,
    // so you can literally watch the containing box grow while rotating.
    private let frameBoxView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemRed.withAlphaComponent(0.25)
        view.layer.borderColor = UIColor.systemRed.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    // Demo 1 — a single rectangle that we rotate.
    private let rectangleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 4
        return view
    }()

    // Demo 2 — a small child sitting in the middle of a bigger parent.
    private let parentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.borderColor = UIColor.systemGray2.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    private let childView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        return view
    }()

    // MARK: - Live read-out labels

    private lazy var frameLabel = Self.makeReadoutLabel(tint: .systemRed)
    private lazy var boundsLabel = Self.makeReadoutLabel(tint: .systemBlue)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Frame vs Bounds"
        view.backgroundColor = .systemBackground
        setupLayout()
        applyDemoVisibility()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutDemoViews()
    }

    // MARK: - Layout

    private func setupLayout() {
        stage.translatesAutoresizingMaskIntoConstraints = false
        stage.addSubview(frameBoxView)      // behind the rectangle…
        stage.addSubview(rectangleView)        // …so the rectangle sits on top of its frame box.
        stage.addSubview(parentView)
        parentView.addSubview(childView)        // child lives in the parent's coordinate space.

        let readoutStack = UIStackView(arrangedSubviews: [frameLabel, boundsLabel, rotationSlider])
        readoutStack.axis = .vertical
        readoutStack.spacing = 12
        readoutStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segmentedControl)
        view.addSubview(infoLabel)
        view.addSubview(stage)
        view.addSubview(readoutStack)

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: guide.topAnchor, constant: 16),
            segmentedControl.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            infoLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            infoLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),

            stage.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
            stage.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            stage.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            stage.bottomAnchor.constraint(equalTo: readoutStack.topAnchor, constant: -16),

            readoutStack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
            readoutStack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20),
            readoutStack.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -16),
        ])
    }

    /// The demo views are positioned with explicit frames (not Auto Layout) so the
    /// rotation transform and the parent/child offset stay easy to reason about.
    private func layoutDemoViews() {
        let centerPoint = CGPoint(x: stage.bounds.midX, y: stage.bounds.midY)

        // Demo 1: keep the rectangle's bounds fixed at 220×120 and centre it.
        // We clear the transform before touching the frame, then re-apply it.
        let savedTransform = rectangleView.transform
        rectangleView.transform = .identity
        rectangleView.bounds = CGRect(x: 0, y: 0, width: 220, height: 120)
        rectangleView.center = centerPoint
        rectangleView.transform = savedTransform
        updateFrameBox()

        // Demo 2: a 250×250 parent centred in the stage…
        parentView.bounds = CGRect(x: 0, y: 0, width: 250, height: 250)
        parentView.center = centerPoint

        // …with a 100×100 child centred inside it. The child's FRAME origin is
        // therefore (75, 75) in the parent, but its BOUNDS origin stays (0, 0).
        let childSide: CGFloat = 100
        let inset = (parentView.bounds.width - childSide) / 2   // 75
        childView.frame = CGRect(x: inset, y: inset, width: childSide, height: childSide)

        updateReadout()
    }

    // MARK: - Actions

    @objc private func demoChanged(_ sender: UISegmentedControl) {
        currentDemo = Demo(rawValue: sender.selectedSegmentIndex) ?? .rotation
        applyDemoVisibility()
        updateReadout()
    }

    @objc private func rotationChanged(_ sender: UISlider) {
        rectangleView.transform = CGAffineTransform(rotationAngle: CGFloat(sender.value))
        updateFrameBox()
        updateReadout()
    }

    // MARK: - Helpers

    /// Keeps the red frame box exactly equal to the rectangle's current frame.
    /// `rectangleView.frame` is already expressed in the stage's coordinate system,
    /// and the box itself has no transform, so assigning it directly is correct.
    private func updateFrameBox() {
        frameBoxView.frame = rectangleView.frame
    }

    private func applyDemoVisibility() {
        let isRotation = currentDemo == .rotation
        rectangleView.isHidden = !isRotation
        frameBoxView.isHidden = !isRotation
        parentView.isHidden = isRotation
        rotationSlider.isHidden = !isRotation

        infoLabel.text = isRotation
            ? "Rotate the rectangle. Its BOUNDS keeps the same size, but its FRAME — the red box containing the rotated rectangle — grows."
            : "The green child sits in the middle of the grey parent. Its FRAME is offset inside the parent, while its BOUNDS origin is still (0, 0)."
    }

    private func updateReadout() {
        let rect: (frame: CGRect, bounds: CGRect, name: String)
        switch currentDemo {
        case .rotation:
            rect = (rectangleView.frame, rectangleView.bounds, "Rect")
        case .childOffset:
            rect = (childView.frame, childView.bounds, "Child")
        }

        frameLabel.text  = "\(rect.name) FRAME   →  \(Self.describe(rect.frame))"
        boundsLabel.text = "\(rect.name) BOUNDS  →  \(Self.describe(rect.bounds))"

        // Mirrors the tutorial's console output so the values can be read in the log too.
        print("\(rect.name)  frame: \(Self.describe(rect.frame))  |  bounds: \(Self.describe(rect.bounds))")
    }

    private static func describe(_ rect: CGRect) -> String {
        String(format: "x %6.1f  y %6.1f  w %6.1f  h %6.1f",
               rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
    }

    private static func makeReadoutLabel(tint: UIColor) -> UILabel {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 13, weight: .semibold)
        label.textColor = tint
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }
}
