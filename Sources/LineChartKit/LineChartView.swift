//
//  LineChartView.swift
//  ChartTest
//
//  Created by Carlo on 1/13/26.
//

import UIKit

@objc public protocol LineChartViewDelegate:NSObjectProtocol{
    //日历模式变更回调
    @objc optional func lineChartViewDateModeChanged(chartView:LineChartView,mode:DateMode)
    //显示窗口最大最小X值回调
    @objc optional func lineChartViewXRangeChanged(chartView:LineChartView,min:Double,max:Double)
    //用户拖动、缩放或惯性滑动后的显示窗口回调
    @objc optional func lineChartViewXRangeChangedByUserInteraction(chartView:LineChartView,min:Double,max:Double)
    //显示窗口最大最小Y值回调
    @objc optional func lineChartViewYRangeChanged(chartView:LineChartView,min:Double,max:Double)
    //回调横向线段 Y 值，同时传入当前标签配置的颜色和字体
    @objc optional func lineChartViewHLineFormatAttributeStr(chartView:LineChartView,y:Double,color:UIColor,font:UIFont)->NSAttributedString
    //回调右侧最值标签 Y 值，同时传入当前标签配置的颜色和字体
    @objc optional func lineChartViewRightAxisDataMaxMinFormatStr(chartView:LineChartView,min:Double,max:Double,color:UIColor,font:UIFont)->MaxMinAttrModel
    //回调坐标轴刻度值，同时传入对应方向标签配置的颜色和字体
    @objc optional func lineChartViewAxisGraduationFormatStr(chartView:LineChartView,direction:AxisDirection,value:Double,color:UIColor,font:UIFont)->NSAttributedString?
    //回调底部首尾时间标签 X 值，同时传入当前标签配置的颜色和字体
    @objc optional func lineChartViewBottomAxisMaxMinFormatStr(chartView:LineChartView,x:Double,color:UIColor,font:UIFont)->NSAttributedString

    /// 当前点击的点的格式化字符串
    /// - Parameters:
    ///   - x: 当前点击的数据的x
    ///   - y: 当前点击的数据的x
    ///   - color: 当前点详情配置的文字颜色
    ///   - font: 当前点详情配置的字体
    /// - Returns: 格式化后的 X、Y 富文本
    @objc optional func lineChartViewTapedItemFormatStrs(chartView:LineChartView,x:Double,y:Double,color:UIColor,font:UIFont)->XYAttrModel

}


@objcMembers public class LineChartView: UIView,UIGestureRecognizerDelegate {
    public weak var delegate:LineChartViewDelegate?
    private lazy var drawer = LineChartDrawer(chartView: self)
    public var chartModel = ChartModel(){
        didSet{
            dealData()
        }
    }
    //用于保存手势的临时位置
    private var tempMinX:CGFloat = 0
    //用于保存手势的临时位置
    private var tempMaxX:CGFloat = 0
    //用于保存手势的临时位置
    private var pinchLocation:CGPoint = .zero
    //标记是否正在拖动tapedItem
    private var isLabelPaning = false
    // 模拟 UIScrollView 横向减速效果
    private var decelerationDisplayLink: CADisplayLink?
    private var decelerationVelocityX: CGFloat = 0
    private var lastDecelerationTimestamp: CFTimeInterval = 0
    private let decelerationStartVelocityThreshold: CGFloat = 120
    private let decelerationStopVelocityThreshold: CGFloat = 5
    // 采样缓存覆盖当前窗口及左右各一屏，平移期间复用同一批采样点。
    private var sampledPointsCache: [ChartPointModel] = []
    private var samplingCacheMinX: CGFloat?
    private var samplingCacheMaxX: CGFloat?
    private var samplingBaseVisibleRange: CGFloat = 0
    private var samplingSourceCount = 0
    private var samplingSourceFirstIdentifier: ObjectIdentifier?
    private var samplingSourceLastIdentifier: ObjectIdentifier?
    private var isPinchingChart = false
    private let samplingTargetPointCount = 200
    private let samplingOverscanScreenCount: CGFloat = 1

    // MARK: - Lifecycle and Rendering

    /// 在 Core Animation 提供的上下文中更新模型并完成整张图表绘制。
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        dealModels()
        drawer.draw(layer: layer,ctx: ctx, chartModel: chartModel)
    }

    /// 保留 UIView 的矩形绘制入口，由图层代理绘制入口负责实际绘制。
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
    }

    /// 用户开始直接触摸时停止仍在运行的惯性动画。
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopDeceleration()
        super.touchesBegan(touches, with: event)
    }

    /// 创建图表视图并安装点击、拖动和缩放手势。
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGesture()
        setupPanGesture()
        setupPinchGesture()
    }

    /// Storyboard 初始化暂未支持。
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 视图释放前停止 CADisplayLink，避免惯性回调继续触发。
    deinit {
        stopDeceleration()
    }

    /// 仅允许水平方向明显大于垂直方向的拖动手势开始识别。
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer,pan.view == self else {
            return true
        }
        let velocity = pan.velocity(in: self)
        // 横向滑动才触发
        return abs(velocity.x) > abs(velocity.y)
    }
    
    /// 重新处理当前数据并请求视图重绘。
    public func reloadData() {
        dealData()
        setNeedsDisplay()
    }
}

// MARK: - Data Processing

extension LineChartView {

    /// 排序原始数据、初始化显示范围并通知相关代理。
    func dealData(){
        let xs = chartModel.lineModel.points.map { $0.x }
        let now = Date().timeIntervalSince1970
        //xRangeType = .distaceByNow的时候，数据超出当前时间，初始拖动会闪动，考虑到数据一般不会超出当前时间，暂不修改
        chartModel.minX = xs.min() ?? now
        chartModel.maxX = xs.max() ?? now
        chartModel.lineModel.points.sort(by: {$0.x<$1.x})
        invalidateSamplingCache()
        dealModels()
        changeDateMode(mode: chartModel.dateMode)
        delegate?.lineChartViewDateModeChanged?(chartView: self, mode: chartModel.dateMode)
        delegate?.lineChartViewXRangeChanged?(chartView: self, min: chartModel.minX, max: chartModel.maxX)
    }

    /// 根据当前可视范围生成最终参与绘制的数据模型。
    func dealModels(){
        let visibleData = visibleDataForCurrentRange()
        updateYRange(using: visibleData)
        updateGapAreas(using: visibleData)
        delegate?.lineChartViewYRangeChanged?(chartView: self, min: chartModel.minY, max: chartModel.maxY)
        chartModel.lineModel.pointsShouldDraw = sampledVisibleData(preservingPointsFrom: visibleData)
        guard case .distance = chartModel.gapStyle else { return }
        addGapModel()
    }

    /// 获取当前 X 轴窗口内的数据，并为平滑曲线保留额外参考点。
    private func visibleDataForCurrentRange() -> [ChartPointModel] {
        points(
            in: chartModel.minX...chartModel.maxX,
            from: chartModel.lineModel.points
        )
    }

    /// 从指定有序数据中截取范围内的点，并保留曲线计算所需的边界参考点。
    private func points(
        in range: ClosedRange<CGFloat>,
        from points: [ChartPointModel]
    ) -> [ChartPointModel] {
        guard !points.isEmpty else { return [] }

        let extraReferenceCount = curveReferencePointCount() - 1
        let leftIndex = max(0, upperBoundIndex(for: range.lowerBound, in: points) - 1)
        let rightIndex = min(points.count - 1, lowerBoundIndex(for: range.upperBound, in: points))
        let startIndex = max(0, leftIndex - extraReferenceCount)
        let endIndex = min(points.count - 1, rightIndex + extraReferenceCount)
        return Array(points[startIndex...endIndex])
    }

    /// 返回当前曲线算法在可视区两侧需要保留的参考点数量。
    private func curveReferencePointCount() -> Int {
        switch chartModel.lineModel.datalineStyle {
        case .monotoneCubic, .catmullRom:
            return 2
        case .straight, .bezier:
            return 1
        }
    }

    /// 使用可视数据更新图表的 Y 轴范围。
    private func updateYRange(using visibleData: [ChartPointModel]) {
        let range = yRange(using: visibleData)
        chartModel.minY = range.min
        chartModel.maxY = range.max
    }

    /// 按 Y 轴范围配置计算本次绘制使用的最小值和最大值。
    private func yRange(using visibleData: [ChartPointModel]) -> (min: CGFloat, max: CGFloat) {
        switch chartModel.yRangeType {
        case .selfAdaptAll:
            let ys = chartModel.lineModel.points.map { $0.y }
            return (CGFloat(ys.min() ?? 0), CGFloat(ys.max() ?? 0))
        case .selfAdaptVisible:
            let ys = visibleData.map { $0.y }
            return (CGFloat(ys.min() ?? 0), CGFloat(ys.max() ?? 0))
        case .selfAdaptVisibleWithType(let type):
            let ys = visibleData.map { $0.y }
            let minY = ys.min() ?? 0
            let maxY = ys.max() ?? 0
            let padding = min(max((maxY - minY) * 0.3, 0.2), 2)
            let range = (min: CGFloat(minY - padding), max: CGFloat(maxY + padding))
            guard type == .humidity else { return range }
            return (max(0, range.min), min(100, range.max))
        case .fixed(let min, let max):
            return (CGFloat(min), CGFloat(max))
        case .selfAdaptVisibleWithMinMax(let min,let max):
            let ys = visibleData.map { $0.y }
            let dataMin = ys.min() ?? 0
            let dataMax = ys.max() ?? 0
            return (CGFloat(Swift.min(min, dataMin)), CGFloat(Swift.max(max, dataMax)))
        }
    }

    /// 根据 Gap 配置更新当前可视范围内的空数据区域。
    private func updateGapAreas(using visibleData: [ChartPointModel]) {
        switch chartModel.gapStyle {
        case .none:
            clearGapData()
        case .distance(let distance):
            chartModel.lineModel.emptyAreas = filterPointsByXDistance(visibleData, threshold: distance)
        }
    }

    /// 清空 Gap 数据，并取消已经失效的 Gap 选中项。
    private func clearGapData() {
        chartModel.lineModel.emptyAreas.removeAll()
        guard chartModel.tapedItem?.dataType == .gap else { return }
        chartModel.tapedItem = nil
    }

    /// 找出相邻点 X 距离超过阈值的区间并转换为 Gap 模型。
    func filterPointsByXDistance(_ points: [ChartPointModel], threshold: CGFloat) -> [horizontalEmptyAreaModel] {
        
        guard threshold > 0, points.count > 1 else { return [] }
        
        var result: [horizontalEmptyAreaModel] = []
        
        for i in 0..<(points.count - 1) {
            let currentPoint = points[i]
            let nextPoint = points[i + 1]
            guard nextPoint.dataType == .data else { continue }
            // 检查后一个点比前一个点的x值是否大于threshold
            guard nextPoint.x - currentPoint.x > threshold else { continue }
            result.append(horizontalEmptyAreaModel(left: currentPoint.x, right: nextPoint.x))
        }
        return result
    }

    
    /// 添加gap模型，便于使用chartpointmodel一样的交互逻辑
    func addGapModel(){
        for arer in chartModel.lineModel.emptyAreas{
            let model = ChartPointModel()
            model.dataType = .gap
            model.x = (arer.left+arer.right)*0.5
            model.y = chartModel.maxY
            model.gapLeft = arer.left
            model.gapRight = arer.right
            if chartModel.tapedItem?.dataType == .gap&&model.x == chartModel.tapedItem?.x{
                model.style = chartModel.tapedItem?.style ?? .normal
            }
            chartModel.lineModel.pointsShouldDraw.append(model)
        }
        chartModel.lineModel.pointsShouldDraw.sort(by: {$0.x<$1.x})
    }

    /// 清空采样缓存，使下一次绘制按最新数据和范围重新采样。
    private func invalidateSamplingCache() {
        sampledPointsCache.removeAll(keepingCapacity: true)
        samplingCacheMinX = nil
        samplingCacheMaxX = nil
        samplingBaseVisibleRange = 0
        samplingSourceCount = 0
        samplingSourceFirstIdentifier = nil
        samplingSourceLastIdentifier = nil
    }

    /// 返回当前可视范围对应的缓存采样点，并补回未被采样选中的 Tooltip 数据点。
    private func sampledVisibleData(preservingPointsFrom visibleData: [ChartPointModel]) -> [ChartPointModel] {
        ensureSamplingCache()
        guard !sampledPointsCache.isEmpty else { return visibleData }

        var result = points(
            in: chartModel.minX...chartModel.maxX,
            from: sampledPointsCache
        )
        guard let selectedItem = chartModel.tapedItem,
              selectedItem.dataType == .data,
              selectedItem.style != .normal,
              visibleData.contains(where: { $0 === selectedItem }),
              !result.contains(where: { $0 === selectedItem }) else { return result }
        let insertionIndex = lowerBoundIndex(for: selectedItem.x, in: result)
        result.insert(selectedItem, at: insertionIndex)
        return result
    }

    /// 在数据源或显示窗口超出缓存条件时重建扩展范围采样缓存。
    private func ensureSamplingCache() {
        guard !isSamplingCacheValid() else { return }
        rebuildSamplingCache()
    }

    /// 判断当前数据源、可视范围和缩放比例是否仍可复用现有缓存。
    private func isSamplingCacheValid() -> Bool {
        let source = chartModel.lineModel.points
        guard !sampledPointsCache.isEmpty,
              samplingSourceCount == source.count,
              samplingSourceFirstIdentifier == source.first.map({ ObjectIdentifier($0) }),
              samplingSourceLastIdentifier == source.last.map({ ObjectIdentifier($0) }),
              let cacheMinX = samplingCacheMinX,
              let cacheMaxX = samplingCacheMaxX else { return false }

        let visibleRange = chartModel.maxX - chartModel.minX
        let tolerance = max(visibleRange * 0.000001, 0.0001)
        guard chartModel.minX >= cacheMinX - tolerance,
              chartModel.maxX <= cacheMaxX + tolerance else { return false }
        guard !isPinchingChart, samplingBaseVisibleRange > 0 else { return true }
        let scale = visibleRange / samplingBaseVisibleRange
        return scale >= 0.5 && scale <= 2
    }

    /// 对当前窗口左右各扩展一屏并生成一次固定的 LTTB 采样缓存。
    private func rebuildSamplingCache() {
        let source = chartModel.lineModel.points
        samplingSourceCount = source.count
        samplingSourceFirstIdentifier = source.first.map { ObjectIdentifier($0) }
        samplingSourceLastIdentifier = source.last.map { ObjectIdentifier($0) }

        let visibleRange = chartModel.maxX - chartModel.minX
        guard !source.isEmpty, visibleRange > 0 else {
            sampledPointsCache.removeAll(keepingCapacity: true)
            samplingCacheMinX = nil
            samplingCacheMaxX = nil
            samplingBaseVisibleRange = 0
            return
        }

        let overscanDistance = visibleRange * samplingOverscanScreenCount
        let cacheMinX = chartModel.minX - overscanDistance
        let cacheMaxX = chartModel.maxX + overscanDistance
        let expandedData = points(in: cacheMinX...cacheMaxX, from: source)
        let screenCount = 1 + samplingOverscanScreenCount * 2
        let threshold = Int(ceil(CGFloat(samplingTargetPointCount) * screenCount))

        sampledPointsCache = resampleLTTB(data: expandedData, threshold: threshold)
        samplingCacheMinX = cacheMinX
        samplingCacheMaxX = cacheMaxX
        samplingBaseVisibleRange = visibleRange
    }

    /// 对扩展可视范围执行一次 LTTB，结果会一直复用到缓存失效。
    /// - Parameters:
    ///   - data: 扩展可视范围内的原始数据。
    ///   - threshold: 扩展范围内保留的目标点数。
    /// - Returns: 当前缓存周期内保持不变的采样结果。
    private func resampleLTTB(
        data: [ChartPointModel],
        threshold: Int
    ) -> [ChartPointModel] {
        guard threshold < data.count else { return data }
        guard threshold > 2, let firstPoint = data.first, let lastPoint = data.last else { return data }
        
        let bucketSize = Double(data.count - 2) / Double(threshold - 2)
        var result = [firstPoint]
        var previousSelectedIndex = 0
        
        for i in 0..<(threshold - 2) {
            let candidateStart = Int(Double(i) * bucketSize) + 1
            let candidateEnd = min(Int(Double(i + 1) * bucketSize) + 1, data.count - 1)
            let averageStart = Int(Double(i + 1) * bucketSize) + 1
            let averageEnd = min(Int(Double(i + 2) * bucketSize) + 1, data.count)
            let candidateRange = candidateStart..<candidateEnd
            let averageRange = averageStart..<averageEnd
            let averagePoint = averagePoint(
                in: data,
                range: averageRange
            )
            let selectedIndex = largestTrianglePointIndex(
                in: data,
                candidateRange: candidateRange,
                previousIndex: previousSelectedIndex,
                averagePoint: averagePoint
            )

            result.append(data[selectedIndex])
            previousSelectedIndex = selectedIndex
        }
        
        result.append(lastPoint)
        insertIfMissing(data.min(by: { $0.y < $1.y }), into: &result)
        insertIfMissing(data.max(by: { $0.y < $1.y }), into: &result)
        return result
    }

    /// 计算指定索引区间内数据点的平均坐标。
    private func averagePoint(
        in data: [ChartPointModel],
        range: Range<Int>
    ) -> CGPoint {
        var totalX: CGFloat = 0
        var totalY: CGFloat = 0
        for index in range {
            totalX += data[index].x
            totalY += data[index].y
        }
        let count = CGFloat(range.count)
        return CGPoint(x: totalX / count, y: totalY / count)
    }

    /// 在候选桶中选择与前一点和下一桶均值构成最大三角形的点。
    private func largestTrianglePointIndex(
        in data: [ChartPointModel],
        candidateRange: Range<Int>,
        previousIndex: Int,
        averagePoint: CGPoint
    ) -> Int {
        var largestArea: CGFloat = -1
        var selectedIndex = candidateRange.lowerBound
        let previousPoint = data[previousIndex]

        for index in candidateRange {
            let point = data[index]
            let area = abs(
                (previousPoint.x - averagePoint.x) * (point.y - previousPoint.y) -
                (previousPoint.x - point.x) * (averagePoint.y - previousPoint.y)
            )
            guard area > largestArea else { continue }
            largestArea = area
            selectedIndex = index
        }
        return selectedIndex
    }

    /// 将极值点按 X 顺序插入结果，并避免同一个模型被重复添加。
    private func insertIfMissing(
        _ point: ChartPointModel?,
        into result: inout [ChartPointModel]
    ) {
        guard let point, !result.contains(where: { $0 === point }) else { return }
        let insertionIndex = lowerBoundIndex(for: point.x, in: result)
        result.insert(point, at: insertionIndex)
    }

    /// 返回第一个 X 大于等于目标值的数据索引。
    private func lowerBoundIndex(for x: CGFloat, in points: [ChartPointModel]) -> Int {
        var lower = 0
        var upper = points.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            if points[middle].x < x {
                lower = middle + 1
            } else {
                upper = middle
            }
        }
        return lower
    }

    /// 返回第一个 X 大于目标值的数据索引。
    private func upperBoundIndex(for x: CGFloat, in points: [ChartPointModel]) -> Int {
        var lower = 0
        var upper = points.count
        while lower < upper {
            let middle = lower + (upper - lower) / 2
            if points[middle].x <= x {
                lower = middle + 1
            } else {
                upper = middle
            }
        }
        return lower
    }

    
}

// MARK: - Visible Range

extension LineChartView {

    /// 设置窗口最大最小X
    /// - Parameters:
    ///   - min: 最小X
    ///   - max: 最大X
    public func changeXRange(min:Double,max:Double){
        updateXRange(min: min, max: max, isUserInteraction: false)
    }

    /// 更新由手势交互产生的可视 X 轴范围。
    private func changeXRangeByUserInteraction(min: Double, max: Double) {
        updateXRange(min: min, max: max, isUserInteraction: true)
    }

    /// 统一约束和应用 X 轴范围，并发送对应的范围变化回调。
    private func updateXRange(min: Double, max: Double, isUserInteraction: Bool) {
        let range = constrainedXRange(min: min, max: max)
        chartModel.minX = range.min
        chartModel.maxX = range.max
        setNeedsDisplay()
        notifyXRangeChanged(isUserInteraction: isUserInteraction)
        autoChangeDateMode()
    }

    /// 根据配置集中约束 X 轴范围，外部设置、拖动和缩放共用同一套边界。
    private func constrainedXRange(min: Double, max: Double) -> (min: CGFloat, max: CGFloat) {
        switch chartModel.XRangeType {
        case .unlimited:
            return (CGFloat(min), CGFloat(max))
        case .limitedByData:
            let dataMin = chartModel.lineModel.points.first?.x ?? min
            let dataMax = chartModel.lineModel.points.last?.x ?? max
            return (CGFloat(Swift.max(min, dataMin)), CGFloat(Swift.min(max, dataMax)))
        case .distaceByNow(let distance):
            let now = Date().timeIntervalSince1970
            return (CGFloat(Swift.max(min, now - distance)), CGFloat(Swift.min(max, now)))
        }
    }

    /// 通知普通范围变化，并在手动交互时额外通知交互范围变化。
    private func notifyXRangeChanged(isUserInteraction: Bool) {
        delegate?.lineChartViewXRangeChanged?(chartView: self, min: chartModel.minX, max: chartModel.maxX)
        guard isUserInteraction else { return }
        delegate?.lineChartViewXRangeChangedByUserInteraction?(
            chartView: self,
            min: chartModel.minX,
            max: chartModel.maxX
        )
    }
    /// 切换日期模式，并按该模式更新当前显示时间跨度。
    public func changeDateMode(mode:DateMode){
        chartModel.dateMode = mode
        switch chartModel.dateMode {
        case .hour:
            chartModel.minX = chartModel.maxX-3600
        case .day:
            chartModel.minX = chartModel.maxX-3600*24
        case .week:
            chartModel.minX = chartModel.maxX-3600*24*7
        case .month:
            chartModel.minX = chartModel.maxX-3600*24*30
        case .year:
            chartModel.minX = chartModel.maxX-3600*24*30*12
        case .none:
            break
        }
        self.setNeedsDisplay()
        delegate?.lineChartViewXRangeChanged?(chartView: self, min: chartModel.minX, max: chartModel.maxX)
    }

    
    /// 根据当前 X 轴跨度自动选择日期显示模式。
    private func autoChangeDateMode(){
        let range = chartModel.maxX - chartModel.minX
        if range <= 3600{
            chartModel.dateMode = .day
        }else if range <= 3600*24{
            chartModel.dateMode = .day
        }else if range <= 3600*24*7{
            chartModel.dateMode = .week
        }else if range <= 3600*24*30{
            chartModel.dateMode = .month
        }else if range <= 3600*24*30*12{
            chartModel.dateMode = .year
        }
        self.delegate?.lineChartViewDateModeChanged?(chartView: self, mode: chartModel.dateMode)
    }
}

// MARK: - Tooltip Selection

extension LineChartView {

    /// 安装用于选择或关闭 Tooltip 的点击手势。
    private func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    ///处理点击事件
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        stopDeceleration()
        let location = gesture.location(in: self)
        guard !dismissTapedItemIfNeeded(at: location) else { return }
        selectNearestItem(at: location)
    }

    /// 点击落在当前 Tooltip 内时取消选中并返回 true。
    private func dismissTapedItemIfNeeded(at location: CGPoint) -> Bool {
        guard let item = chartModel.tapedItem, item.style != .normal else { return false }
        guard tapedItemDetailFrame(item).contains(location) else { return false }
        item.style = .normal
        chartModel.tapedItem = nil
        setNeedsDisplay()
        return true
    }

    /// 选择与触摸位置 X 坐标最近的数据点并显示 Tooltip。
    private func selectNearestItem(at location: CGPoint) {
        let dataPoint = dataPointFromPointInView(point: location)
        let item = nearestItem(in: chartModel.lineModel.pointsShouldDraw, to: dataPoint.x)
        chartModel.tapedItem?.style = .normal
        chartModel.tapedItem = item
        chartModel.tapedItem?.style = .circle(radius: 8, width: 2, color: .gray)
        setNeedsDisplay()
    }

    /// 计算指定选中项对应 Tooltip 的实际视图区域。
    private func tapedItemDetailFrame(_ item: ChartPointModel) -> CGRect {
        let center = drawer.deteminItemDetailCenter(item: item)
        return CGRect(
            x: center.x - item.detailSize.width * 0.5,
            y: center.y - item.detailSize.height * 0.5,
            width: item.detailSize.width,
            height: item.detailSize.height
        )
    }

    //数据点和view的pt之间的转换
    private func dataPointFromPointInView(point:CGPoint)->CGPoint{
        let x = chartModel.minX + (point.x-chartModel.chartContentInsert.left)/(self.bounds.width-chartModel.chartContentInsert.left-chartModel.chartContentInsert.right)*(chartModel.maxX-chartModel.minX)
        let y = chartModel.minY + (self.bounds.height-point.y-chartModel.chartContentInsert.bottom)/(self.bounds.height-chartModel.chartContentInsert.top-chartModel.chartContentInsert.bottom)*(chartModel.maxY-chartModel.minY)
        return CGPoint.init(x: x, y: y)
    }
    //获取最近点击事件的位置最近的一个数据
    private func nearestItem(
        in items: [ChartPointModel],
        to x: Double
    ) -> ChartPointModel? {
        guard !items.isEmpty else { return nil }
        return items.filter({$0.dataType == .data}).min {
            abs($0.x - x) < abs($1.x - x)
        }
    }
}

// MARK: - Gestures

extension LineChartView {

    /// 安装负责 Tooltip 拖动和图表平移的 Pan 手势。
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        self.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        self.isUserInteractionEnabled = true
    }
    /// 根据 Pan 手势状态分发开始、变化、结束和取消逻辑。
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginPan(gesture)
        case .changed:
            changePan(gesture)
        case .ended:
            endPan(gesture)
        case .cancelled, .failed:
            cancelPan()
        default:
            break
        }
    }

    /// 开始拖动时判断本次手势操作 Tooltip 还是平移图表。
    private func beginPan(_ gesture: UIPanGestureRecognizer) {
        stopDeceleration()
        guard let item = chartModel.tapedItem, item.style != .normal else {
            isLabelPaning = false
            return
        }
        isLabelPaning = tapedItemDetailFrame(item).contains(gesture.location(in: self))
    }

    /// 拖动过程中更新 Tooltip 选中项或移动图表可视范围。
    private func changePan(_ gesture: UIPanGestureRecognizer) {
        guard !isLabelPaning else {
            selectNearestItem(at: gesture.location(in: self))
            return
        }
        let translation = gesture.translation(in: self)
        gesture.setTranslation(.zero, in: self)
        _ = shiftVisibleRange(by: dataOffsetFromViewTranslation(translation.x))
    }

    /// 结束图表拖动后按配置启动惯性滑动。
    private func endPan(_ gesture: UIPanGestureRecognizer) {
        let wasPanningLabel = isLabelPaning
        isLabelPaning = false
        guard !wasPanningLabel else { return }
        startDeceleration(with: gesture.velocity(in: self).x)
    }

    /// 取消拖动状态并立即停止惯性滑动。
    private func cancelPan() {
        isLabelPaning = false
        stopDeceleration()
    }

    /// 安装用于缩放 X 轴范围的 Pinch 手势。
    private func setupPinchGesture() {
        // 创建 Pinch 手势识别器
        let pinchGesture = UIPinchGestureRecognizer(
            target: self,
            action: #selector(handlePinch(_:))
        )
        // 将手势添加到视图
        self.addGestureRecognizer(pinchGesture)
    }

    /// 根据 Pinch 手势状态分发缩放开始和变化逻辑。
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginPinch(gesture)
        case .changed:
            changePinch(gesture)
        case .ended, .cancelled, .failed:
            endPinch()
        default:
            break
        }
    }

    /// 记录缩放锚点和手势开始时的 X 轴范围。
    private func beginPinch(_ gesture: UIPinchGestureRecognizer) {
        stopDeceleration()
        isPinchingChart = true
        pinchLocation = gesture.location(in: self)
        tempMaxX = chartModel.maxX
        tempMinX = chartModel.minX
    }

    /// 围绕缩放锚点计算并应用新的 X 轴范围。
    private func changePinch(_ gesture: UIPinchGestureRecognizer) {
        let locationX = dataX(at: pinchLocation, minX: tempMinX, maxX: tempMaxX)
        let scale = 1 / gesture.scale
        let proposedRange = (
            min: locationX - (locationX - tempMinX) * scale,
            max: locationX + (tempMaxX - locationX) * scale
        )
        let range = rangeRespectingMinimumWidth(proposedRange, anchorX: locationX)
        changeXRangeByUserInteraction(min: range.min, max: range.max)
    }

    /// 缩放结束后按最终范围重建一次采样缓存。
    private func endPinch() {
        isPinchingChart = false
        invalidateSamplingCache()
        setNeedsDisplay()
    }

    /// 将视图坐标中的触摸位置换算为指定范围内的数据 X 值。
    private func dataX(at location: CGPoint, minX: CGFloat, maxX: CGFloat) -> CGFloat {
        let contentWidth = bounds.width - chartModel.chartContentInsert.left - chartModel.chartContentInsert.right
        guard contentWidth > 0 else { return minX }
        let ratio = (location.x - chartModel.chartContentInsert.left) / contentWidth
        return ratio * (maxX - minX) + minX
    }

    /// 当缩放结果过小时，围绕锚点恢复到允许的最小范围宽度。
    private func rangeRespectingMinimumWidth(
        _ range: (min: CGFloat, max: CGFloat),
        anchorX: CGFloat
    ) -> (min: CGFloat, max: CGFloat) {
        let minimumWidth = max(chartModel.minimumXRange, 0)
        guard minimumWidth > 0, range.max - range.min < minimumWidth else { return range }

        let originalWidth = tempMaxX - tempMinX
        let anchorRatio = originalWidth > 0
            ? min(max((anchorX - tempMinX) / originalWidth, 0), 1)
            : 0.5
        let minX = anchorX - minimumWidth * anchorRatio
        return (minX, minX + minimumWidth)
    }

    /// 将屏幕上的水平位移换算为数据坐标中的 X 偏移量。
    private func dataOffsetFromViewTranslation(_ translationX: CGFloat) -> Double {
        guard self.layer.bounds.width > 0 else { return 0 }
        return Double((translationX / self.layer.bounds.width) * CGFloat(chartModel.maxX - chartModel.minX))
    }

    @discardableResult
    /// 按数据偏移移动可视范围，并返回是否完整应用了本次移动。
    private func shiftVisibleRange(by dataOffset: Double) -> Bool {
        let newMinX = chartModel.minX - dataOffset
        let newMaxX = chartModel.maxX - dataOffset
        
        switch chartModel.XRangeType {
        case .unlimited:
            changeXRangeByUserInteraction(min: newMinX, max: newMaxX)
            return true
        case .limitedByData:
            return shiftRangeWithinDataBounds(newMinX: newMinX, newMaxX: newMaxX)
        case .distaceByNow(let distance):
            let now = Date().timeIntervalSince1970
            return shiftRange(
                newMinX: newMinX,
                newMaxX: newMaxX,
                lowerBound: now - distance,
                upperBound: now
            )
        }
    }

    /// 将待移动范围限制在首尾数据点之间。
    private func shiftRangeWithinDataBounds(newMinX: CGFloat, newMaxX: CGFloat) -> Bool {
        let lowerBound = chartModel.lineModel.points.first?.x ?? newMinX
        let upperBound = chartModel.lineModel.points.last?.x ?? newMaxX
        return shiftRange(
            newMinX: newMinX,
            newMaxX: newMaxX,
            lowerBound: lowerBound,
            upperBound: upperBound
        )
    }

    /// 在给定上下边界内移动范围，越界时吸附到对应边界。
    private func shiftRange(
        newMinX: CGFloat,
        newMaxX: CGFloat,
        lowerBound: CGFloat,
        upperBound: CGFloat
    ) -> Bool {
        if newMinX < lowerBound {
            applyBoundaryShift(lowerBound - chartModel.minX)
            return false
        }
        if newMaxX > upperBound {
            applyBoundaryShift(upperBound - chartModel.maxX)
            return false
        }
        changeXRangeByUserInteraction(min: newMinX, max: newMaxX)
        return true
    }

    /// 将当前范围整体移动指定距离以完成边界吸附。
    private func applyBoundaryShift(_ distance: CGFloat) {
        guard distance != 0 else { return }
        changeXRangeByUserInteraction(
            min: chartModel.minX + distance,
            max: chartModel.maxX + distance
        )
    }

    /// 使用手指离开时的速度启动横向惯性滑动。
    private func startDeceleration(with velocityX: CGFloat) {
        stopDeceleration()
        guard chartModel.enableDeceleration else { return }
        // 过滤手指离开瞬间的轻微抖动，避免出现非预期的小惯性位移
        guard abs(velocityX) > decelerationStartVelocityThreshold else { return }
        decelerationVelocityX = velocityX
        lastDecelerationTimestamp = 0
        let displayLink = CADisplayLink(target: self, selector: #selector(handleDecelerationTick(_:)))
        displayLink.add(to: .main, forMode: .common)
        decelerationDisplayLink = displayLink
    }

    /// 停止惯性计时器并清空当前减速状态。
    private func stopDeceleration() {
        decelerationDisplayLink?.invalidate()
        decelerationDisplayLink = nil
        decelerationVelocityX = 0
        lastDecelerationTimestamp = 0
    }

    /// 在每一帧根据速度移动范围并按系统减速率衰减速度。
    @objc private func handleDecelerationTick(_ displayLink: CADisplayLink) {
        if lastDecelerationTimestamp == 0 {
            lastDecelerationTimestamp = displayLink.timestamp
            return
        }
        
        let deltaTime = displayLink.timestamp - lastDecelerationTimestamp
        lastDecelerationTimestamp = displayLink.timestamp
        
        let didMove = shiftVisibleRange(by: dataOffsetFromViewTranslation(decelerationVelocityX * CGFloat(deltaTime)))
        let rate = CGFloat(pow(Double(UIScrollView.DecelerationRate.normal.rawValue), deltaTime * 1000))
        decelerationVelocityX *= rate
        
        if !didMove || abs(decelerationVelocityX) < decelerationStopVelocityThreshold {
            stopDeceleration()
        }
    }

    
}
