//
//  LineChartDrawer.swift
//  ChartTest
//
//  Created by Carlo on 1/14/26.
//

import UIKit

class LineChartDrawer {
    //文本框的大小
    //    var circleLabelSize = CGSize.init(width: 80, height: 40)
    //图表模型
    var chartModel = ChartModel()
    var layer = CALayer()
    private unowned let chartView: LineChartView

    // MARK: - Lifecycle and Drawing Pipeline

    /// 创建与指定图表视图绑定的绘制器。
    init(chartView: LineChartView) {
        self.chartView = chartView
    }
    /// 按既定层级依次绘制坐标轴、曲线、标签、参考线和 Tooltip。
    func draw(layer:CALayer,ctx:CGContext,chartModel:ChartModel){
        self.chartModel = chartModel
        self.layer = layer
        drawAxis(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        drawLine(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        if case .distance = chartModel.gapStyle {
            drawEmptyArea(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        }
        drawAxisLable(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        drawAxisMaxMinLable(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        drawAxisDataMaxMinLable(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        drawHVLine(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
        drawItemCircle(layer: layer, ctx: ctx, chartModel: chartModel, data: chartModel.lineModel.pointsShouldDraw)
    }
}

// MARK: - Coordinate Axis Frame

extension LineChartDrawer {

    /// 根据四个方向的轴线配置绘制图表边界轴线。
    func drawAxis(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        ctx.saveGState()
        switch chartModel.topAxisLineStyle {
        case .line(let width, let color):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            if chartModel.horizontalAxisFullFrame{
                ctx.move(to: CGPoint(x: 0, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: layer.bounds.width, y: chartModel.chartContentInsert.top))
                
            }else{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: chartModel.chartContentInsert.top))
            }
            ctx.strokePath()
        case .dashLine(let width, let color, let lengths):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            ctx.setLineDash(phase: 0, lengths: lengths)
            if chartModel.horizontalAxisFullFrame{
                ctx.move(to: CGPoint(x: 0, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: layer.bounds.width, y: chartModel.chartContentInsert.top))
                
            }else{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: chartModel.chartContentInsert.top))
            }
            ctx.strokePath()
        case .none:
            break
        }
        ctx.restoreGState()
        ctx.saveGState()
        switch chartModel.bottomAxisLineStyle {
        case .line(let width, let color):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            if chartModel.horizontalAxisFullFrame{
                ctx.move(to: CGPoint(x: 0, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
                ctx.addLine(to: CGPoint(x: layer.bounds.width, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }else{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }
            ctx.strokePath()
        case .dashLine(let width, let color, let lengths):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            ctx.setLineDash(phase: 0, lengths: lengths)
            if chartModel.horizontalAxisFullFrame{
                ctx.move(to: CGPoint(x: 0, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
                ctx.addLine(to: CGPoint(x: layer.bounds.width, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }else{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }
            ctx.strokePath()
        case .none:
            break
        }
        ctx.restoreGState()
        ctx.saveGState()
        switch chartModel.leftAxisLineStyle {
        case .line(let width, let color):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            if chartModel.verticalAxisFullFrame{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: 0))
                ctx.addLine(to: CGPoint(x: chartModel.chartContentInsert.left, y: layer.bounds.height))
            }else{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: chartModel.chartContentInsert.left, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }
            ctx.strokePath()
        case .dashLine(let width, let color, let lengths):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            ctx.setLineDash(phase: 0, lengths: lengths)
            if chartModel.verticalAxisFullFrame{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: 0))
                ctx.addLine(to: CGPoint(x: chartModel.chartContentInsert.left, y: layer.bounds.height))
            }else{
                ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: chartModel.chartContentInsert.left, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }
            ctx.strokePath()
        case .none:
            break
        }
        ctx.restoreGState()
        ctx.saveGState()
        switch chartModel.rightAxisLineStyle {
        case .line(let width, let color):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            if chartModel.verticalAxisFullFrame{
                ctx.move(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: 0))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: layer.bounds.height))
            }else{
                ctx.move(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }
            ctx.strokePath()
        case .dashLine(let width, let color, let lengths):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            ctx.setLineDash(phase: 0, lengths: lengths)
            if chartModel.verticalAxisFullFrame{
                ctx.move(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: 0))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: layer.bounds.height))
            }else{
                ctx.move(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: chartModel.chartContentInsert.top))
                ctx.addLine(to: CGPoint(x: layer.bounds.width-chartModel.chartContentInsert.right, y: layer.bounds.height-chartModel.chartContentInsert.bottom))
            }
            ctx.strokePath()
        case .none:
            break
        }
        ctx.restoreGState()
        
    }
}

// MARK: - Curve Paths and Gaps

extension LineChartDrawer {

    /// 生成曲线路径，并绘制背景渐变、阴影和按区域分色的线条。
    func drawLine(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        guard data.count>0 else{
            return
        }
        ctx.saveGState()
        let lineWidth:CGFloat = getLineWidth()

        let clipRect = CGRect(
            x: chartModel.chartContentInsert.left,
            y: chartModel.chartContentInsert.top-lineWidth*0.5,
            width: layer.bounds.width - chartModel.chartContentInsert.left - chartModel.chartContentInsert.right,
            height: layer.bounds.height - chartModel.chartContentInsert.top - chartModel.chartContentInsert.bottom+lineWidth
        )
        ctx.clip(to: clipRect)
        
        if case .distance = chartModel.gapStyle {
            ctx.addRect(clipRect)
            for point in chartModel.lineModel.emptyAreas{
                let point1 = ptPointFromPoint(point: .init(x: point.left, y: 0))
                let point2 = ptPointFromPoint(point: .init(x: point.right, y: 0))
                let gapRect:CGRect = .init(x: point1.x, y:chartModel.chartContentInsert.top-lineWidth*0.5, width: point2.x-point1.x, height: layer.bounds.height-chartModel.chartContentInsert.top-chartModel.chartContentInsert.bottom+lineWidth)
                ctx.addRect(gapRect)
            }
            ctx.clip(using: .evenOdd)
        }

        let paths = makeLineAndAreaPaths(
            layer: layer,
            chartModel: chartModel,
            data: data
        )

        if let areaPath = paths.areaPath,
           let verticalBGColorRnages = chartModel.verticalBGColorRnages,
           !verticalBGColorRnages.isEmpty {
            drawLineBottomGradient(
                ctx: ctx,
                areaPath: areaPath,
                colorRanges: verticalBGColorRnages
            )
        }

        if let shadow = chartModel.lineModel.dataLineShadow {
            drawDataLineShadow(
                ctx: ctx,
                path: paths.linePath,
                lineWidth: lineWidth,
                shadow: shadow
            )
        }

        switch chartModel.lineModel.datalineStyle {
        case .straight(let width, let color):
            ctx.setLineWidth(width)
            ctx.setStrokeColor(color.cgColor)
            ctx.addPath(paths.linePath)
        case .bezier(let width, let color),
             .monotoneCubic(let width, let color),
             .catmullRom(let width, let color):
            ctx.setLineWidth(width)
            // 曲线路径使用圆角连接和圆形端点，避免端点出现尖锐接缝。
            ctx.setLineJoin(.round)
            ctx.setLineCap(.round)
            ctx.setStrokeColor(color.cgColor)
            ctx.addPath(paths.linePath)
        }
        ctx.replacePathWithStrokedPath()
        ctx.clip()
        
        
        
        for (index,verticalColorRnage) in chartModel.verticalColorRnages.enumerated() {
            let toppt = ptPointFromPoint(point: .init(x: 0, y: verticalColorRnage.top ))
            let bottompt = ptPointFromPoint(point: .init(x: 0, y: verticalColorRnage.bottom ))
            
            let topY = toppt.y
            let bottomY = bottompt.y
            let colors = [
                verticalColorRnage.topColor.cgColor,
                verticalColorRnage.bottomColor.cgColor
            ]
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            )!
            
            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: index == 0 ?topY-lineWidth*0.5:topY),
                end: CGPoint(x: 0, y: index == chartModel.verticalColorRnages.count-1 ?bottomY+lineWidth:bottomY),
                options: []
            )
        }
        
        ctx.restoreGState()
        
    }

    /// 单独描边生成阴影，避免后续线条渐变的裁剪路径把阴影一并裁掉。
    private func drawDataLineShadow(
        ctx: CGContext,
        path: CGPath,
        lineWidth: CGFloat,
        shadow: DataLineShadow
    ) {
        ctx.saveGState()
        ctx.setLineWidth(lineWidth)
        ctx.setLineJoin(.round)
        ctx.setLineCap(.round)
        ctx.setStrokeColor(shadow.color.cgColor)
        ctx.setShadow(offset: shadow.offset, blur: shadow.blur, color: shadow.color.cgColor)
        ctx.addPath(path)
        ctx.strokePath()
        ctx.restoreGState()
    }

    //一次遍历生成曲线路径和曲线下方面积路径，避免背景和线条重复计算贝塞尔曲线
    /// 一次遍历同时生成曲线描边路径和曲线下方面积路径。
    private func makeLineAndAreaPaths(
        layer: CALayer,
        chartModel: ChartModel,
        data: [ChartPointModel]
    ) -> (linePath: CGPath, areaPath: CGPath?) {
        let segments: [[ChartPointModel]]
        switch chartModel.gapStyle {
        case .none:
            segments = [data]
        case .distance:
            segments = continuousDataSegments(data)
        }
        let linePath = CGMutablePath()
        let areaPath = CGMutablePath()
        let bottomY = layer.bounds.height - chartModel.chartContentInsert.bottom
        var hasAreaPath = false

        for segment in segments {
            let points = segment.map {
                ptPointFromPoint(point: .init(x: $0.x, y: $0.y))
            }
            hasAreaPath = appendDataSegment(
                points,
                linePath: linePath,
                areaPath: areaPath,
                bottomY: bottomY
            ) || hasAreaPath
        }

        return (linePath, hasAreaPath ? areaPath : nil)
    }

    @discardableResult
    /// 将一段连续数据追加到线条路径和面积路径中。
    private func appendDataSegment(
        _ points: [CGPoint],
        linePath: CGMutablePath,
        areaPath: CGMutablePath,
        bottomY: CGFloat
    ) -> Bool {
        guard let firstPoint = points.first else { return false }
        linePath.move(to: firstPoint)
        guard points.count > 1, let lastPoint = points.last else { return false }

        areaPath.move(to: CGPoint(x: firstPoint.x, y: bottomY))
        areaPath.addLine(to: firstPoint)
        appendStyledPath(points, linePath: linePath, areaPath: areaPath)
        areaPath.addLine(to: CGPoint(x: lastPoint.x, y: bottomY))
        areaPath.closeSubpath()
        return true
    }

    /// 按当前线条样式选择对应的路径构建算法。
    private func appendStyledPath(
        _ points: [CGPoint],
        linePath: CGMutablePath,
        areaPath: CGMutablePath
    ) {
        switch chartModel.lineModel.datalineStyle {
        case .straight:
            appendStraightPath(points, linePath: linePath, areaPath: areaPath)
        case .bezier:
            appendBezierPath(points, linePath: linePath, areaPath: areaPath)
        case .monotoneCubic:
            appendControlledPath(
                points,
                controls: monotoneCubicControlPoints(points),
                linePath: linePath,
                areaPath: areaPath
            )
        case .catmullRom:
            appendControlledPath(
                points,
                controls: catmullRomControlPoints(points),
                linePath: linePath,
                areaPath: areaPath
            )
        }
    }

    /// 使用直线连接全部数据点。
    private func appendStraightPath(
        _ points: [CGPoint],
        linePath: CGMutablePath,
        areaPath: CGMutablePath
    ) {
        for point in points.dropFirst() {
            linePath.addLine(to: point)
            areaPath.addLine(to: point)
        }
    }

    /// 使用水平控制点为相邻数据点生成贝塞尔曲线。
    private func appendBezierPath(
        _ points: [CGPoint],
        linePath: CGMutablePath,
        areaPath: CGMutablePath
    ) {
        for index in 1..<points.count {
            let startPoint = points[index - 1]
            let endPoint = points[index]
            let control1 = CGPoint(
                x: startPoint.x + (endPoint.x - startPoint.x) * 0.5,
                y: startPoint.y
            )
            let control2 = CGPoint(
                x: endPoint.x - (endPoint.x - startPoint.x) * 0.5,
                y: endPoint.y
            )
            appendCurveOrLine(
                from: startPoint,
                to: endPoint,
                control1: control1,
                control2: control2,
                linePath: linePath,
                areaPath: areaPath
            )
        }
    }

    /// 使用已经计算好的控制点追加三次贝塞尔曲线。
    private func appendControlledPath(
        _ points: [CGPoint],
        controls: [(control1: CGPoint, control2: CGPoint)],
        linePath: CGMutablePath,
        areaPath: CGMutablePath
    ) {
        for index in controls.indices {
            appendCurveOrLine(
                from: points[index],
                to: points[index + 1],
                control1: controls[index].control1,
                control2: controls[index].control2,
                linePath: linePath,
                areaPath: areaPath
            )
        }
    }

    /// 根据屏幕距离决定追加曲线段还是退化后的直线段。
    private func appendCurveOrLine(
        from startPoint: CGPoint,
        to endPoint: CGPoint,
        control1: CGPoint,
        control2: CGPoint,
        linePath: CGMutablePath,
        areaPath: CGMutablePath
    ) {
        guard !shouldFallbackToStraightLine(from: startPoint, to: endPoint) else {
            linePath.addLine(to: endPoint)
            areaPath.addLine(to: endPoint)
            return
        }
        linePath.addCurve(to: endPoint, control1: control1, control2: control2)
        areaPath.addCurve(to: endPoint, control1: control1, control2: control2)
    }

    /// 当相邻点的屏幕 X 距离小于配置阈值时，将当前曲线段退化为直线。
    private func shouldFallbackToStraightLine(from start: CGPoint, to end: CGPoint) -> Bool {
        let minimumDistance = chartModel.bezierToLineMinDistance
        return minimumDistance > 0 && abs(end.x - start.x) < minimumDistance
    }

    /// 计算单调三次 Hermite 曲线对应的贝塞尔控制点，避免曲线越过相邻数据点的值域。
    private func monotoneCubicControlPoints(
        _ points: [CGPoint]
    ) -> [(control1: CGPoint, control2: CGPoint)] {
        guard points.count > 1 else { return [] }

        let minimumDistance: CGFloat = 0.0001
        var intervals = [CGFloat](repeating: 0, count: points.count - 1)
        var slopes = [CGFloat](repeating: 0, count: points.count - 1)

        for index in intervals.indices {
            let distanceX = points[index + 1].x - points[index].x
            intervals[index] = distanceX
            if distanceX > minimumDistance {
                slopes[index] = (points[index + 1].y - points[index].y) / distanceX
            }
        }

        var tangents = [CGFloat](repeating: 0, count: points.count)
        tangents[0] = slopes[0]
        tangents[points.count - 1] = slopes[slopes.count - 1]

        updateInteriorTangents(
            &tangents,
            intervals: intervals,
            slopes: slopes,
            minimumDistance: minimumDistance
        )

        return intervals.indices.map { index in
            let distanceX = intervals[index]
            let controlDistance = distanceX / 3
            return (
                control1: CGPoint(
                    x: points[index].x + controlDistance,
                    y: points[index].y + tangents[index] * controlDistance
                ),
                control2: CGPoint(
                    x: points[index + 1].x - controlDistance,
                    y: points[index + 1].y - tangents[index + 1] * controlDistance
                )
            )
        }
    }

    /// 根据相邻斜率更新单调三次曲线的内部切线。
    private func updateInteriorTangents(
        _ tangents: inout [CGFloat],
        intervals: [CGFloat],
        slopes: [CGFloat],
        minimumDistance: CGFloat
    ) {
        guard tangents.count > 2 else { return }
        for index in 1..<(tangents.count - 1) {
            let previousSlope = slopes[index - 1]
            let nextSlope = slopes[index]
            guard previousSlope * nextSlope > 0 else {
                tangents[index] = 0
                continue
            }

            let previousInterval = max(intervals[index - 1], minimumDistance)
            let nextInterval = max(intervals[index], minimumDistance)
            let firstWeight = 2 * nextInterval + previousInterval
            let secondWeight = nextInterval + 2 * previousInterval
            tangents[index] = (firstWeight + secondWeight)
                / (firstWeight / previousSlope + secondWeight / nextSlope)
        }
    }

    /// 将 centripetal Catmull-Rom 曲线转换为 Core Graphics 可绘制的三次贝塞尔控制点。
    private func catmullRomControlPoints(
        _ points: [CGPoint]
    ) -> [(control1: CGPoint, control2: CGPoint)] {
        guard points.count > 1 else { return [] }

        var controls: [(control1: CGPoint, control2: CGPoint)] = []
        controls.reserveCapacity(points.count - 1)

        for index in 0..<(points.count - 1) {
            let point1 = points[index]
            let point2 = points[index + 1]
            let point0 = index > 0
                ? points[index - 1]
                : CGPoint(x: point1.x * 2 - point2.x, y: point1.y * 2 - point2.y)
            let point3 = index + 2 < points.count
                ? points[index + 2]
                : CGPoint(x: point2.x * 2 - point1.x, y: point2.y * 2 - point1.y)

            let time0: CGFloat = 0
            let time1 = time0 + catmullRomParameterDistance(from: point0, to: point1)
            let time2 = time1 + catmullRomParameterDistance(from: point1, to: point2)
            let time3 = time2 + catmullRomParameterDistance(from: point2, to: point3)
            let segmentDuration = time2 - time1

            let firstTangent = catmullRomTangent(
                previous: point0,
                current: point1,
                next: point2,
                previousTime: time0,
                currentTime: time1,
                nextTime: time2
            )
            let secondTangent = catmullRomTangent(
                previous: point1,
                current: point2,
                next: point3,
                previousTime: time1,
                currentTime: time2,
                nextTime: time3
            )
            let tangent1 = CGPoint(
                x: firstTangent.x * segmentDuration,
                y: firstTangent.y * segmentDuration
            )
            let tangent2 = CGPoint(
                x: secondTangent.x * segmentDuration,
                y: secondTangent.y * segmentDuration
            )

            let minimumX = min(point1.x, point2.x)
            let maximumX = max(point1.x, point2.x)
            let control1 = CGPoint(
                x: min(maximumX, max(minimumX, point1.x + tangent1.x / 3)),
                y: point1.y + tangent1.y / 3
            )
            let control2 = CGPoint(
                x: min(maximumX, max(minimumX, point2.x - tangent2.x / 3)),
                y: point2.y - tangent2.y / 3
            )
            controls.append((control1: control1, control2: control2))
        }

        return controls
    }

    /// 计算非均匀 Catmull-Rom 参数区间内某个数据点的切线。
    private func catmullRomTangent(
        previous: CGPoint,
        current: CGPoint,
        next: CGPoint,
        previousTime: CGFloat,
        currentTime: CGFloat,
        nextTime: CGFloat
    ) -> CGPoint {
        let previousDuration = currentTime - previousTime
        let nextDuration = nextTime - currentTime
        let totalDuration = nextTime - previousTime

        let previousX = (current.x - previous.x) / previousDuration
        let previousY = (current.y - previous.y) / previousDuration
        let totalX = (next.x - previous.x) / totalDuration
        let totalY = (next.y - previous.y) / totalDuration
        let nextX = (next.x - current.x) / nextDuration
        let nextY = (next.y - current.y) / nextDuration

        return CGPoint(
            x: previousX - totalX + nextX,
            y: previousY - totalY + nextY
        )
    }

    /// alpha=0.5 的参数距离可减少 Catmull-Rom 在密集点附近产生尖点和回环。
    private func catmullRomParameterDistance(from start: CGPoint, to end: CGPoint) -> CGFloat {
        let distance = hypot(end.x - start.x, end.y - start.y)
        return max(sqrt(distance), 0.0001)
    }

    //绘制曲线下方的渐变背景
    private func drawLineBottomGradient(
        ctx: CGContext,
        areaPath: CGPath,
        colorRanges: [VerticalColorRange]
    ) {
        ctx.saveGState()
        ctx.addPath(areaPath)
        ctx.clip()

        for verticalBGColorRnage in colorRanges {
            let topPt = ptPointFromPoint(point: .init(x: 0, y: verticalBGColorRnage.top))
            let bottomPt = ptPointFromPoint(point: .init(x: 0, y: verticalBGColorRnage.bottom))
            let colors = [
                verticalBGColorRnage.topColor.cgColor,
                verticalBGColorRnage.bottomColor.cgColor
            ]

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: [0, 1]
            ) else { continue }

            ctx.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: topPt.y),
                end: CGPoint(x: 0, y: bottomPt.y),
                options: []
            )
        }

        ctx.restoreGState()
    }

    //按照 gap 将数据拆分成多段连续数据，避免背景跨过空洞区域
    private func continuousDataSegments(_ data: [ChartPointModel]) -> [[ChartPointModel]] {
        var segments: [[ChartPointModel]] = []
        var current: [ChartPointModel] = []

        for item in data {
            guard item.dataType == .gap else {
                current.append(item)
                continue
            }
            guard !current.isEmpty else { continue }
            segments.append(current)
            current.removeAll()
        }

        if !current.isEmpty {
            segments.append(current)
        }

        return segments
    }
    
    /// 返回当前数据线样式配置的线宽。
    func getLineWidth()->CGFloat{
        var lineWidth:CGFloat = 1
        switch chartModel.lineModel.datalineStyle{
        case .straight(let width, _):
          lineWidth = width
        case .bezier(let width, _),
             .monotoneCubic(let width, _),
             .catmullRom(let width, _):
            lineWidth = width
        }
        return lineWidth
    }
    
    //绘制空数据区域
    func drawEmptyArea(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        ctx.saveGState()

        let clipRect = CGRect(
            x: chartModel.chartContentInsert.left,
            y: chartModel.chartContentInsert.top,
            width: layer.bounds.width - chartModel.chartContentInsert.left - chartModel.chartContentInsert.right,
            height: layer.bounds.height - chartModel.chartContentInsert.top - chartModel.chartContentInsert.bottom
        )
        
        ctx.clip(to: clipRect)
        for point in chartModel.lineModel.emptyAreas{
            var point1 = ptPointFromPoint(point: .init(x: point.left, y: 0))
            if point1.x<chartModel.chartContentInsert.left{
                point1.x = chartModel.chartContentInsert.left
            }
            var point2 = ptPointFromPoint(point: .init(x: point.right, y: 0))
            if point2.x>layer.bounds.width-chartModel.chartContentInsert.right{
                point2.x = layer.bounds.width-chartModel.chartContentInsert.right
            }
            let gapRect:CGRect = .init(x: point1.x, y:chartModel.chartContentInsert.top, width: point2.x-point1.x, height: layer.bounds.height-chartModel.chartContentInsert.top-chartModel.chartContentInsert.bottom)
            
            drawDiagonalLines(in: ctx, rect: gapRect, spacing: 10)
            UIGraphicsPushContext(ctx)
            if gapRect.width>10{
                drawText(NSAttributedString.init(string: "G\nA\nP",attributes: [.foregroundColor:UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0),.font:UIFont.systemFont(ofSize: 13)]), point: .init(x: gapRect.minX+gapRect.width*0.5, y: gapRect.minY+gapRect.height*0.5), anchor: .center)
            }
            UIGraphicsPopContext()
        }
        
        ctx.restoreGState()
        
    }
    
    /// 绘制斜线
    /// - Parameters:
    ///   - ctx: 图形上下文
    ///   - rect: 绘制区域
    ///   - angle: 倾斜角度（度）
    ///   - spacing: 线间距
    private func drawDiagonalLines(in ctx: CGContext, rect: CGRect, spacing: CGFloat) {
        ctx.setLineWidth(1)
        ctx.setStrokeColor(UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0).cgColor)
        var y = rect.minY-rect.width
        while y>=rect.minY-rect.width&&y<=rect.maxY {
            ctx.move(to: .init(x: rect.origin.x, y: y))
            ctx.addLine(to: .init(x: rect.origin.x+rect.width, y: y+rect.width))
            ctx.strokePath()
            y+=spacing
        }
        
    }
}

// MARK: - Axis Reference Lines

extension LineChartDrawer {

    /// 绘制模型中配置的全部水平参考线和垂直参考线。
    func drawHVLine(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        for horizontalLine in chartModel.horizontalLines {
            drawHorizontalLine(horizontalLine, ctx: ctx)
        }

        ctx.saveGState()
        defer { ctx.restoreGState() }
        let clipRect = CGRect(
            x: chartModel.chartContentInsert.left,
            y: chartModel.chartContentInsert.top,
            width: layer.bounds.width - chartModel.chartContentInsert.left - chartModel.chartContentInsert.right,
            height: layer.bounds.height - chartModel.chartContentInsert.top - chartModel.chartContentInsert.bottom
        )
        ctx.clip(to: clipRect)
        for verticalLine in chartModel.verticalLines {
            drawVerticalLine(verticalLine, ctx: ctx)
        }
    }

    /// 绘制一条水平参考线及其可选标签。
    private func drawHorizontalLine(_ line: HorizontalLine, ctx: CGContext) {
        let point = ptPointFromPoint(point: .init(x: 0, y: line.y))
        guard drawHorizontalLineStroke(line, y: point.y, ctx: ctx) else { return }
        drawHorizontalLineLabel(line, point: point, ctx: ctx)
    }

    @discardableResult
    /// 配置并描绘水平参考线，返回该线是否需要继续绘制标签。
    private func drawHorizontalLineStroke(_ line: HorizontalLine, y: CGFloat, ctx: CGContext) -> Bool {
        ctx.saveGState()
        defer { ctx.restoreGState() }
        guard configureLineStyle(line.lineStyle, ctx: ctx) else { return false }
        ctx.move(to: CGPoint(x: chartModel.chartContentInsert.left, y: y))
        ctx.addLine(to: CGPoint(x: layer.bounds.width - chartModel.chartContentInsert.right, y: y))
        ctx.strokePath()
        return true
    }

    /// 根据标签方向配置绘制水平参考线标签。
    private func drawHorizontalLineLabel(
        _ line: HorizontalLine,
        point: CGPoint,
        ctx: CGContext
    ) {
        let contentBottom = layer.bounds.height - chartModel.chartContentInsert.bottom
        guard point.y >= chartModel.chartContentInsert.top, point.y <= contentBottom else { return }

        switch line.lableStyle {
        case .left(let color, let font, let offset):
            drawHorizontalLineLabel(
                line,
                x: chartModel.chartContentInsert.left + (offset ?? 0),
                anchor: .maxxcentery,
                color: color,
                font: font,
                ctx: ctx
            )
        case .right(let color, let font, _):
            drawHorizontalLineLabel(
                line,
                x: point.x,
                anchor: .minxcentery,
                color: color,
                font: font,
                ctx: ctx
            )
        default:
            return
        }
    }

    /// 在指定锚点绘制单个水平参考线富文本标签。
    private func drawHorizontalLineLabel(
        _ line: HorizontalLine,
        x: CGFloat,
        anchor: TextDrawAnchor,
        color: UIColor,
        font: UIFont,
        ctx: CGContext
    ) {
        let padding = UIEdgeInsets(top: 4, left: 6, bottom: 4, right: 6)
        let positions = horizontalLinesMaxMinDrawY(insert: padding, distance: 4)
        let y = line.y == chartModel.horizontalLines.map(\.y).min() ? positions.0 : positions.1
        let text = horizontalLineAttributedText(line, color: color, font: font)
        UIGraphicsPushContext(ctx)
        _ = drawText(
            text,
            point: CGPoint(x: x, y: y),
            anchor: anchor,
            backgroundColor: color.withAlphaComponent(0.1),
            padding: padding
        )
        UIGraphicsPopContext()
    }

    /// 绘制一条裁剪在内容区域内的垂直参考线。
    private func drawVerticalLine(_ line: VerticalLine, ctx: CGContext) {
        guard configureLineStyle(line.lineStyle, ctx: ctx) else { return }
        let x = ptPointFromPoint(point: .init(x: line.x, y: 0)).x
        ctx.move(to: CGPoint(x: x, y: chartModel.chartContentInsert.top))
        ctx.addLine(to: CGPoint(x: x, y: layer.bounds.height - chartModel.chartContentInsert.bottom))
        ctx.strokePath()
    }

    /// 将实线或虚线样式应用到上下文，并返回是否需要描边。
    private func configureLineStyle(_ style: LineStyle, ctx: CGContext) -> Bool {
        switch style {
        case .line(let width, let color):
            ctx.setLineWidth(width)
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineDash(phase: 0, lengths: [])
            return true
        case .dashLine(let width, let color, let lengths):
            ctx.setLineWidth(width)
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineDash(phase: 0, lengths: lengths)
            return true
        case .none:
            return false
        }
    }
}

// MARK: - Tooltip Selection

extension LineChartDrawer {

    /// 绘制当前选中数据点的圆点、引导线和 Tooltip。
    func drawItemCircle(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        guard  let item = data.first(where: {$0.style != .normal}) else{return}
        guard case let .circle(radius ,width ,color) =  item.style else{return}
        let point = ptPointFromPoint(point: .init(x: item.x, y: item.y))
        guard isInsideChartContent(point) else { return }

        if item.dataType == .data {
            drawSelectedDataIndicator(
                item: item,
                point: point,
                radius: radius,
                width: width,
                defaultColor: color,
                ctx: ctx
            )
            drawDataTooltip(item: item, ctx: ctx)
            return
        }
        drawGapTooltip(item: item, ctx: ctx)
    }

    /// 判断绘制点是否位于图表内容区域内。
    private func isInsideChartContent(_ point: CGPoint) -> Bool {
        let right = layer.bounds.width - chartModel.chartContentInsert.right
        let bottom = layer.bounds.height - chartModel.chartContentInsert.bottom
        return point.x >= chartModel.chartContentInsert.left &&
            point.x <= right &&
            point.y >= chartModel.chartContentInsert.top &&
            point.y <= bottom
    }

    /// 绘制选中数据点的高亮圆、竖向引导线和数据 Tooltip。
    private func drawSelectedDataIndicator(
        item: ChartPointModel,
        point: CGPoint,
        radius: CGFloat,
        width: CGFloat,
        defaultColor: UIColor,
        ctx: CGContext
    ) {
        let rangeColor = chartModel.verticalColorRnages
            .first(where: { $0.top > item.y && $0.bottom <= item.y })?
            .topColor
        let strokeColor = rangeColor == nil ? defaultColor : .white
        let fillColor = rangeColor ?? .white
        let guideColor = rangeColor ?? defaultColor

        ctx.saveGState()
        defer { ctx.restoreGState() }
        drawSelectionCircle(
            point: point,
            radius: radius,
            width: width,
            strokeColor: strokeColor,
            fillColor: fillColor,
            ctx: ctx
        )
        drawSelectionGuideLine(atX: point.x, color: guideColor, ctx: ctx)
    }

    /// 绘制选中点的外圈与内圈。
    private func drawSelectionCircle(
        point: CGPoint,
        radius: CGFloat,
        width: CGFloat,
        strokeColor: UIColor,
        fillColor: UIColor,
        ctx: CGContext
    ) {
        ctx.setLineWidth(width)
        ctx.setLineDash(phase: 0, lengths: [])
        ctx.setStrokeColor(strokeColor.cgColor)
        ctx.addEllipse(in: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
        ctx.strokePath()

        let fillRadius = radius - width * 0.5
        ctx.setLineWidth(radius - width)
        ctx.setFillColor(fillColor.cgColor)
        ctx.addEllipse(in: CGRect(
            x: point.x - fillRadius,
            y: point.y - fillRadius,
            width: fillRadius * 2,
            height: fillRadius * 2
        ))
        ctx.fillPath()
    }

    /// 从选中点的 X 坐标绘制贯穿内容区的竖向虚线。
    private func drawSelectionGuideLine(atX x: CGFloat, color: UIColor, ctx: CGContext) {
        ctx.setStrokeColor(color.cgColor)
        ctx.setLineWidth(1)
        ctx.setLineDash(phase: 0, lengths: [6, 3])
        ctx.move(to: CGPoint(x: x, y: chartModel.chartContentInsert.top))
        ctx.addLine(to: CGPoint(x: x, y: layer.bounds.height - chartModel.chartContentInsert.bottom))
        ctx.strokePath()
    }

    /// 获取数据点格式化内容并绘制普通数据 Tooltip。
    private func drawDataTooltip(item: ChartPointModel, ctx: CGContext) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: item.detailFont,
            .foregroundColor: item.detailColor
        ]
        let defaultText = XYAttrModel(
            xAttr: NSAttributedString(
                string: LineChartDateFormatter.string(from: item.x, format: "yyyy/MM/dd HH:mm"),
                attributes: attributes
            ),
            yAttr: NSAttributedString(string: String(format: "%.1f", item.y), attributes: attributes)
        )
        let text = chartView.delegate?.lineChartViewTapedItemFormatStrs?(
            chartView: chartView,
            x: item.x,
            y: item.y,
            color: item.detailColor,
            font: item.detailFont
        ) ?? defaultText
        item.detailSize = deteminItemDetaiFrameSize(strs: [text.yAttr, text.xAttr])
        let detailPoint = deteminItemDetailCenter(item: item)
        drawTooltip(ctx: ctx, center: detailPoint, size: item.detailSize)
        drawDataTooltipText(text, center: detailPoint, ctx: ctx)
    }

    /// 绘制包含 X、Y 两行富文本的数据 Tooltip。
    private func drawDataTooltipText(_ text: XYAttrModel, center: CGPoint, ctx: CGContext) {
        let contentHeight = text.yAttr.size().height + text.xAttr.size().height
        let contentTop = center.y - contentHeight * 0.5
        UIGraphicsPushContext(ctx)
        _ = drawText(
            text.yAttr,
            point: CGPoint(x: center.x, y: contentTop + text.yAttr.size().height * 0.5),
            anchor: .center
        )
        _ = drawText(
            text.xAttr,
            point: CGPoint(x: center.x, y: contentTop + text.yAttr.size().height + text.xAttr.size().height * 0.5),
            anchor: .center
        )
        UIGraphicsPopContext()
    }

    /// 绘制 Gap 区域的开始时间和结束时间提示。
    private func drawGapTooltip(item: ChartPointModel, ctx: CGContext) {
        let format = "yyyy/MM/dd HH:mm"
        let leftText = LineChartDateFormatter.string(from: item.gapLeft, format: format)
        let rightText = LineChartDateFormatter.string(from: item.gapRight, format: format)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: item.detailFont,
            .foregroundColor: item.detailColor
        ]
        let texts = [
            NSAttributedString(string: "GAP", attributes: attributes),
            NSAttributedString(string: "\(leftText) ~ \(rightText)", attributes: attributes)
        ]
        item.detailSize = deteminItemDetaiFrameSize(strs: texts)
        let detailPoint = deteminItemDetailCenter(item: item)
        drawTooltip(ctx: ctx, center: detailPoint, size: item.detailSize)
        UIGraphicsPushContext(ctx)
        _ = drawText(texts[0], point: .init(x: detailPoint.x, y: detailPoint.y - 8), anchor: .center)
        _ = drawText(texts[1], point: .init(x: detailPoint.x, y: detailPoint.y + 8), anchor: .center)
        UIGraphicsPopContext()
    }
    
    //通过数据点获取半透明文案区域中心位置
    /// 在内容区内约束并返回 Tooltip 的最终中心点。
    func deteminItemDetailCenter(item:ChartPointModel)->CGPoint{
        let point = ptPointFromPoint(point: .init(x: item.x, y: item.y))
        let yOffset:CGFloat = 10
        var x = point.x
        var y = point.y+item.detailSize.height*0.5+yOffset
        if (x-item.detailSize.width*0.5)<chartModel.chartContentInsert.left{
            x = item.detailSize.width*0.5+chartModel.chartContentInsert.left
        }
        if (x+item.detailSize.width*0.5)>(layer.bounds.width-chartModel.chartContentInsert.right){
            x = layer.bounds.width-chartModel.chartContentInsert.right-item.detailSize.width*0.5
        }
        
        if y+item.detailSize.height*0.5>layer.bounds.height-chartModel.chartContentInsert.bottom{
            y = point.y-item.detailSize.height*0.5-yOffset
        }
        return .init(x: x, y: y)
    }
    
    /// 根据多行富文本计算 Tooltip 所需尺寸。
    func deteminItemDetaiFrameSize(strs:[NSAttributedString])->CGSize{
        var height:CGFloat = 0
        var width:CGFloat = 0
        for str in strs {
            let size = str.size()
            height += size.height
            width = max(size.width, width)
        }
        return .init(width: width+12, height: height+12)
    }
}

// MARK: - Axis Labels and Graduations

extension LineChartDrawer {

    /// 绘制底部和右侧坐标轴的刻度文字。
    func drawAxisLable(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        ctx.saveGState()
        defer { ctx.restoreGState() }

        drawBottomAxisLabels(ctx: ctx)
        drawRightAxisLabels(ctx: ctx)
    }

    /// 按底部标签样式绘制所有 X 轴刻度文字。
    private func drawBottomAxisLabels(ctx: CGContext) {
        guard case .bottom(let color, let font, let offset) = chartModel.bottomAxisLabelStyel else { return }
        let labels = bottomAxisLabels()
        let bottomY = layer.bounds.height - chartModel.chartContentInsert.bottom

        for label in labels {
            let x = ptPointFromPoint(point: .init(x: label.value, y: 0)).x
            let text = axisGraduationText(
                direction: .bottom,
                value: label.value,
                defaultText: label.text,
                color: color,
                font: font
            )
            drawAttributedText(
                text,
                point: CGPoint(x: x, y: bottomY + (offset ?? 0)),
                anchor: .centerxminy,
                ctx: ctx
            )
            addBottomGraduation(atX: x, bottomY: bottomY, ctx: ctx)
        }
        ctx.strokePath()
    }

    /// 根据底部刻度策略生成刻度值和默认显示文字。
    private func bottomAxisLabels() -> [(value: CGFloat, text: String)] {
        switch chartModel.bottomGraduationStepType {
        case .dateAdapt:
            let result = getDateAdaptStamps()
            return result.0.map {
                ($0, LineChartDateFormatter.string(from: $0, format: result.format))
            }
        case .seprateCountWithAllData(let count):
            return generateBottomAxisStepsWithAllData(count: count).map {
                ($0, String(format: "%.1f", $0))
            }
        case .distance, .seprateCount:
            return generateAxisSteps(
                min: chartModel.minX,
                max: chartModel.maxX,
                type: chartModel.bottomGraduationStepType
            ).map { ($0, String(format: "%.1f", $0)) }
        case .none:
            return []
        }
    }

    /// 将一个底部刻度线段加入当前上下文路径。
    private func addBottomGraduation(atX x: CGFloat, bottomY: CGFloat, ctx: CGContext) {
        let configuration = configureGraduation(chartModel.bottomGraduationType, ctx: ctx)
        guard configuration.isVisible else { return }
        let endY = configuration.length.map { bottomY - $0 } ?? chartModel.chartContentInsert.top
        ctx.move(to: CGPoint(x: x, y: bottomY))
        ctx.addLine(to: CGPoint(x: x, y: endY))
    }

    /// 按右侧标签样式绘制所有 Y 轴刻度文字。
    private func drawRightAxisLabels(ctx: CGContext) {
        let steps = generateAxisSteps(
            min: chartModel.minY,
            max: chartModel.maxY,
            type: chartModel.rightGraduationStepType
        )
        switch chartModel.rightAxisLabelStyel {
        case .right(let color, let font, let offset):
            drawRightAxisOutsideLabels(steps, color: color, font: font, offset: offset, ctx: ctx)
        case .left(let color, let font, let offset):
            drawRightAxisInsideLabels(steps, color: color, font: font, offset: offset, ctx: ctx)
        default:
            return
        }
        ctx.strokePath()
    }

    /// 在内容区域右侧绘制 Y 轴刻度和标签。
    private func drawRightAxisOutsideLabels(
        _ steps: [CGFloat],
        color: UIColor,
        font: UIFont,
        offset: CGFloat?,
        ctx: CGContext
    ) {
        let rightX = layer.bounds.width - chartModel.chartContentInsert.right
        for value in steps {
            let y = ptPointFromPoint(point: .init(x: 0, y: value)).y
            let text = axisGraduationText(
                direction: .right,
                value: value,
                defaultText: String(format: "%.1f", value),
                color: color,
                font: font
            )
            drawAttributedText(
                text,
                point: CGPoint(x: rightX + (offset ?? 0), y: y),
                anchor: .minxcentery,
                ctx: ctx
            )
            addOutsideRightGraduation(rightX: rightX, y: y, ctx: ctx)
        }
    }

    /// 在内容区域内侧绘制 Y 轴刻度和标签。
    private func drawRightAxisInsideLabels(
        _ steps: [CGFloat],
        color: UIColor,
        font: UIFont,
        offset: CGFloat?,
        ctx: CGContext
    ) {
        let rightX = layer.bounds.width - chartModel.chartContentInsert.right
        for value in steps {
            let y = ptPointFromPoint(point: .init(x: 0, y: value)).y
            let text = axisGraduationText(
                direction: .right,
                value: value,
                defaultText: String(format: "%.1f", value),
                color: color,
                font: font
            )
            let textRightX = rightX + (offset ?? 0)
            drawAttributedText(
                text,
                point: CGPoint(x: textRightX, y: y),
                anchor: .maxxcentery,
                ctx: ctx
            )
            let lineEndX = textRightX - text.size().width - 4
            guard lineEndX > chartModel.chartContentInsert.left else { continue }
            addInsideRightGraduation(lineEndX: lineEndX, y: y, ctx: ctx)
        }
    }

    /// 将向右延伸的 Y 轴刻度线段加入当前路径。
    private func addOutsideRightGraduation(rightX: CGFloat, y: CGFloat, ctx: CGContext) {
        let configuration = configureGraduation(chartModel.rightGraduationType, ctx: ctx)
        guard configuration.isVisible else { return }
        let endX = configuration.length.map { rightX - $0 } ?? chartModel.chartContentInsert.left
        ctx.move(to: CGPoint(x: rightX, y: y))
        ctx.addLine(to: CGPoint(x: endX, y: y))
    }

    /// 将向内容区内延伸的 Y 轴刻度线段加入当前路径。
    private func addInsideRightGraduation(lineEndX: CGFloat, y: CGFloat, ctx: CGContext) {
        let configuration = configureGraduation(chartModel.rightGraduationType, ctx: ctx)
        guard configuration.isVisible else { return }
        let contentLeft = chartModel.chartContentInsert.left
        let lineStartX = configuration.length.map { max(contentLeft, lineEndX - $0) } ?? contentLeft
        ctx.move(to: CGPoint(x: lineStartX, y: y))
        ctx.addLine(to: CGPoint(x: lineEndX, y: y))
    }

    /// 将刻度线配置应用到上下文并返回实际刻度长度。
    private func configureGraduation(
        _ type: GraduationType,
        ctx: CGContext
    ) -> (length: CGFloat?, isVisible: Bool) {
        switch type {
        case .line(let length, let width, let color):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            ctx.setLineDash(phase: 0, lengths: [])
            return (length, true)
        case .dashLine(let length, let width, let color, let lengths):
            ctx.setStrokeColor(color.cgColor)
            ctx.setLineWidth(width)
            ctx.setLineDash(phase: 0, lengths: lengths)
            return (length, true)
        case .none:
            return (nil, false)
        }
    }

    /// 优先使用代理富文本，否则按轴标签配置生成默认刻度文本。
    private func axisGraduationText(
        direction: AxisDirection,
        value: CGFloat,
        defaultText: String,
        color: UIColor,
        font: UIFont
    ) -> NSAttributedString {
        chartView.delegate?.lineChartViewAxisGraduationFormatStr?(
            chartView: chartView,
            direction: direction,
            value: value,
            color: color,
            font: font
        ) ?? NSAttributedString(
            string: defaultText,
            attributes: [.foregroundColor: color, .font: font]
        )
    }

    /// 在 Core Graphics 上下文中按锚点绘制富文本。
    private func drawAttributedText(
        _ text: NSAttributedString,
        point: CGPoint,
        anchor: TextDrawAnchor,
        ctx: CGContext
    ) {
        UIGraphicsPushContext(ctx)
        _ = drawText(text, point: point, anchor: anchor, clampToChartContent: false)
        UIGraphicsPopContext()
    }
    
    /// 按通用刻度策略生成指定区间内的轴刻度值。
    func generateAxisSteps(min: CGFloat, max: CGFloat, type: AxisStepType) -> [CGFloat] {
        guard min < max else {
            return []
        }
        
        switch type {
        case .distance(let distance, let align):
            guard distance > 0 else { return [] }
            guard let align else { return generateDistanceSteps(min: min, max: max, distance: distance) }
            return generateAlignedDistanceSteps(min: min, max: max, distance: distance, align: align)
        case .seprateCount(let count):
            guard count >= 2 else { return [min, max] }
            let step = (max - min) / CGFloat(count - 1)
            return (0..<count).map { min + step * CGFloat($0) }
        case .seprateCountWithAllData:
            // 该类型只支持底部 X 轴，由 generateBottomAxisStepsWithAllData 处理。
            return []
        default:return []
        }
    }

    /// 按固定间距生成刻度，可选择是否对齐到指定基准。
    private func generateDistanceSteps(
        min: CGFloat,
        max: CGFloat,
        distance: CGFloat
    ) -> [CGFloat] {
        var result: [CGFloat] = []
        var current = min
        while current <= max + 0.0001, result.count <= 10000 {
            result.append(current)
            current += distance
        }
        return result
    }

    /// 生成与基准值对齐且位于显示范围内的固定间距刻度。
    private func generateAlignedDistanceSteps(
        min: CGFloat,
        max: CGFloat,
        distance: CGFloat,
        align: CGFloat
    ) -> [CGFloat] {
        var result: [CGFloat] = []
        var current = ceil(min / align) * align
        while current <= max {
            if current >= min, isAligned(current, to: align) {
                result.append(current)
            }
            current += distance
            guard current <= max + distance else { break }
        }
        return result
    }

    /// 判断某个值是否已经与指定间距基准对齐。
    private func isAligned(_ value: CGFloat, to alignment: CGFloat) -> Bool {
        let remainder = value.truncatingRemainder(dividingBy: alignment)
        return abs(remainder) < 0.0001 || abs(remainder - alignment) < 0.0001
    }

    /// 按全部原始数据的 X 范围生成固定刻度，并只返回当前可视区内的部分。
    /// 按全量数据首尾范围等分生成底部轴刻度。
    private func generateBottomAxisStepsWithAllData(count: UInt8) -> [CGFloat] {
        let xValues = chartModel.lineModel.points.map(\.x)
        guard let dataMinX = xValues.min(), let dataMaxX = xValues.max() else {
            return []
        }
        guard dataMinX < dataMaxX else {
            return dataMinX >= chartModel.minX && dataMinX <= chartModel.maxX ? [dataMinX] : []
        }

        let allSteps = generateAxisSteps(
            min: dataMinX,
            max: dataMaxX,
            type: .seprateCount(count: count)
        )
        let tolerance = max(0.0001, (dataMaxX - dataMinX) * 0.000000001)
        return allSteps.filter {
            $0 >= chartModel.minX - tolerance && $0 <= chartModel.maxX + tolerance
        }
    }
    
    /// 按当前日期模式生成自适应时间刻度及对应格式。
    func getDateAdaptStamps()->([TimeInterval],format:String){
        var stamps = [TimeInterval]()
        let range = chartModel.maxX - chartModel.minX
        var dateFormat = "HH:mm"
        if range <= 1800{
            dateFormat = "HH:mm"
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .minutes(5))
        }else if range <= 3600{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .minutes(10))
            dateFormat = "HH:mm"
        }else if range <= 3600*6{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .hours(1))
            dateFormat = "HH:mm"
        }else if range <= 3600*12{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .hours(2))
            dateFormat = "HH:mm"
        }else if range <= 3600*24{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .hours(4))
            dateFormat = "HH:mm"
        }else if range <= 3600*24*7{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .days(1))
            dateFormat = "EEE"
        }else if range <= 3600*24*14{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .days(2))
            dateFormat = "MM/dd"
        }else if range <= 3600*24*30{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .days(5))
            dateFormat = "MM/dd"
        }else if range <= 3600*24*30*6{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .months(1))
            dateFormat = "MMM"
        }else if range <= 3600*24*30*12{
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .months(2))
            dateFormat = "MMM"
        }else{
            let count = range/6/(3600*24*30)
            stamps = alignedTimestamps(start: chartModel.minX, end: chartModel.maxX, step: .months(Int(count)))
            dateFormat = "MMM"
        }
        return (stamps,dateFormat)
    }
    
    /// 绘制坐标轴当前显示范围的首尾最大最小值标签。
    func drawAxisMaxMinLable(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        
        switch chartModel.bottomAxisMaxMinStyel {
            
        case .bottom(let color, let font, let offset):
            let minx = chartModel.horizontalAxisFullFrame ? 0:chartModel.chartContentInsert.left
            let miny = layer.bounds.height-(offset ?? 0)
            let minstr = chartView.delegate?.lineChartViewBottomAxisMaxMinFormatStr?(
                chartView: chartView,
                x: chartModel.minX,
                color: color,
                font: font
            ) ?? NSAttributedString(string: LineChartDateFormatter.string(from: chartModel.minX, format: "yyyy-MM-dd HH:mm:ss"), attributes: [.foregroundColor:color,.font:font])
            UIGraphicsPushContext(ctx)
            drawText(minstr, point: CGPoint.init(x: minx, y: miny), anchor: .minxmaxy, clampToChartContent: false)
            UIGraphicsPopContext()
            ctx.strokePath()
            let maxx = chartModel.horizontalAxisFullFrame ? layer.bounds.width:layer.bounds.width-chartModel.chartContentInsert.right
            let maxy = layer.bounds.height-(offset ?? 0)
            let maxstr = chartView.delegate?.lineChartViewBottomAxisMaxMinFormatStr?(
                chartView: chartView,
                x: chartModel.maxX,
                color: color,
                font: font
            ) ?? NSAttributedString(string: LineChartDateFormatter.string(from: chartModel.maxX, format: "yyyy-MM-dd HH:mm:ss"), attributes: [.foregroundColor:color,.font:font])
            UIGraphicsPushContext(ctx)
            drawText(maxstr, point: CGPoint.init(x: maxx, y: maxy), anchor: .maxxmaxy, clampToChartContent: false)
            UIGraphicsPopContext()
            ctx.strokePath()
        default:
            break
        }
        
        switch chartModel.rightAxisMaxMinStyel {
            
        case .left(let color, let font, let offset):
            let minx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
            let miny = layer.bounds.height - chartModel.chartContentInsert.bottom
            let minstr = NSAttributedString(string: "\(chartModel.minY)", attributes: [.foregroundColor:color,.font:font])
            UIGraphicsPushContext(ctx)
            drawText(minstr, point: CGPoint.init(x: minx, y: miny), anchor: .maxxmaxy,backgroundColor: .white,cornerRadius: 0,padding: .init(top: 4, left: 8, bottom: 4, right: 8))
            UIGraphicsPopContext()
            ctx.strokePath()
            let maxx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
            let maxy = chartModel.chartContentInsert.top
            let maxstr = NSAttributedString(string: "\(chartModel.maxY)", attributes: [.foregroundColor:color,.font:font])
            UIGraphicsPushContext(ctx)
            drawText(maxstr, point: CGPoint.init(x: maxx, y: maxy), anchor: .maxxminy,backgroundColor: .white,cornerRadius: 0,padding: .init(top: 4, left: 8, bottom: 4, right: 8))
            UIGraphicsPopContext()
            ctx.strokePath()
            break
        case .right(let color, let font, let offset):
            let minx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
            let miny = layer.bounds.height - chartModel.chartContentInsert.bottom
            let minstr = NSAttributedString(string: "\(chartModel.minY)", attributes: [.foregroundColor:color,.font:font])
            UIGraphicsPushContext(ctx)
            drawText(minstr, point: CGPoint.init(x: minx, y: miny), anchor: .maxxmaxy,backgroundColor: .white,cornerRadius: 0,padding: .init(top: 4, left: 8, bottom: 4, right: 8))
            UIGraphicsPopContext()
            ctx.strokePath()
            let maxx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
            let maxy = chartModel.chartContentInsert.top
            let maxstr = NSAttributedString(string: "\(chartModel.maxY)", attributes: [.foregroundColor:color,.font:font])
            UIGraphicsPushContext(ctx)
            drawText(maxstr, point: CGPoint.init(x: maxx, y: maxy), anchor: .maxxminy,backgroundColor: .white,cornerRadius: 0,padding: .init(top: 4, left: 8, bottom: 4, right: 8))
            UIGraphicsPopContext()
            ctx.strokePath()
            break
        default:break
        }
    }
    
    /// 绘制当前可视数据的 Y 最小值和最大值标签及辅助虚线。
    func drawAxisDataMaxMinLable(layer:CALayer,ctx:CGContext,chartModel:ChartModel,data:[ChartPointModel]){
        let vasivledata = data.filter({
            ($0.x>=chartModel.minX)&&($0.x<=chartModel.maxX)&&$0.dataType == .data
        })
        guard !vasivledata.isEmpty else { return }
        let padding:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        switch chartModel.rightAxisDataMaxMinStyel {
                
            case .left(let color, let font, let offset):
                let trump = rightAxisDataMaxMinDrawY(visibleData: vasivledata,font: font, insert: padding, distance: 0)

                let ys = vasivledata.map { $0.y }
                let dataMinY = ys.min() ?? 0
                let dataMaxY = ys.max() ?? 0
                let formatMaxMin = chartView.delegate?.lineChartViewRightAxisDataMaxMinFormatStr?(
                    chartView: chartView,
                    min: dataMinY,
                    max: dataMaxY,
                    color: color,
                    font: font
                )
                let minx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
                let minstr = formatMaxMin?.min ?? NSAttributedString(string: String(format: "%.1f", dataMinY), attributes: [.foregroundColor:color,.font:font])
                UIGraphicsPushContext(ctx)
                let minStrSize = drawText(minstr, point: CGPoint.init(x: minx, y: trump.0), anchor: .maxxcentery,backgroundColor: .white.withAlphaComponent(0.8),cornerRadius: 0,padding: padding)
                UIGraphicsPopContext()
                ctx.strokePath()
                let maxx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
                let maxstr = formatMaxMin?.max ?? NSAttributedString(string: String(format: "%.1f", dataMaxY), attributes: [.foregroundColor:color,.font:font])
                UIGraphicsPushContext(ctx)
                let maxStrSize = drawText(maxstr, point: CGPoint.init(x: maxx, y: trump.1), anchor: .maxxcentery,backgroundColor: .white.withAlphaComponent(0.8),cornerRadius: 0,padding: padding)
                UIGraphicsPopContext()
                ctx.strokePath()
                
                ctx.saveGState()
                let pointMin = ptPointFromPoint(point: .init(x: 0, y: dataMinY))
                ctx.setLineWidth(1)
                ctx.setStrokeColor(UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1.0).withAlphaComponent(0.5).cgColor)
                ctx.setLineDash(phase: 0, lengths: [6,3])
                var startPoint = CGPoint.init(x: chartModel.chartContentInsert.left, y: pointMin.y)
                var endPoint = CGPoint.init(x: layer.bounds.width-chartModel.chartContentInsert.right-minStrSize.width+(offset ?? 0), y: pointMin.y)
                ctx.move(to: startPoint)
                ctx.addLine(to: endPoint)
                ctx.strokePath()
                
                let pointMax = ptPointFromPoint(point: .init(x: 0, y: dataMaxY))
                startPoint = CGPoint.init(x: chartModel.chartContentInsert.left, y: pointMax.y)
                endPoint = CGPoint.init(x: layer.bounds.width-chartModel.chartContentInsert.right-maxStrSize.width+(offset ?? 0), y: pointMax.y)
                ctx.move(to: startPoint)
                ctx.addLine(to: endPoint)
                ctx.strokePath()
                
                ctx.restoreGState()
                break
            case .right(let color, let font, let offset):
                let trump = rightAxisDataMaxMinDrawY(visibleData: vasivledata,font: font, insert: padding, distance: 0)

                let ys = vasivledata.map { $0.y }
                let dataMinY = ys.min() ?? 0
                let dataMaxY = ys.max() ?? 0
                let formatMaxMin = chartView.delegate?.lineChartViewRightAxisDataMaxMinFormatStr?(
                    chartView: chartView,
                    min: dataMinY,
                    max: dataMaxY,
                    color: color,
                    font: font
                )
                let minx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
                let minstr = formatMaxMin?.min ?? NSAttributedString(string: "\(dataMinY)", attributes: [.foregroundColor:color,.font:font])
                UIGraphicsPushContext(ctx)
                let _ = drawText(minstr, point: CGPoint.init(x: minx, y: trump.0), anchor: .minxcentery,backgroundColor: .white.withAlphaComponent(0.8),cornerRadius: 0,padding: padding)
                UIGraphicsPopContext()
                ctx.strokePath()
                let maxx = layer.bounds.width - chartModel.chartContentInsert.right+(offset ?? 0)
                let maxstr = formatMaxMin?.max ?? NSAttributedString(string: "\(dataMaxY)", attributes: [.foregroundColor:color,.font:font])
                UIGraphicsPushContext(ctx)
                let _ = drawText(maxstr, point: CGPoint.init(x: maxx, y: trump.1), anchor: .minxcentery,backgroundColor: .white.withAlphaComponent(0.8),cornerRadius: 0,padding: padding)
                UIGraphicsPopContext()
                ctx.strokePath()
                
                ctx.saveGState()
                let pointMin = ptPointFromPoint(point: .init(x: 0, y: dataMinY))
                ctx.setLineWidth(1)
                ctx.setStrokeColor(UIColor(red: 196/255.0, green: 196/255.0, blue: 196/255.0, alpha: 1.0).withAlphaComponent(0.5).cgColor)
                ctx.setLineDash(phase: 0, lengths: [6,3])
                var startPoint = CGPoint.init(x: chartModel.chartContentInsert.left, y: pointMin.y)
                var endPoint = CGPoint.init(x: layer.bounds.width-chartModel.chartContentInsert.right+(offset ?? 0), y: pointMin.y)
                ctx.move(to: startPoint)
                ctx.addLine(to: endPoint)
                ctx.strokePath()
                
                let pointMax = ptPointFromPoint(point: .init(x: 0, y: dataMaxY))
                startPoint = CGPoint.init(x: chartModel.chartContentInsert.left, y: pointMax.y)
                endPoint = CGPoint.init(x: layer.bounds.width-chartModel.chartContentInsert.right+(offset ?? 0), y: pointMax.y)
                ctx.move(to: startPoint)
                ctx.addLine(to: endPoint)
                ctx.strokePath()
                
                ctx.restoreGState()
                break
        default:break
        }
    }
    

    
    /// 计算右侧数据最值标签避免越界和互相重叠后的 Y 坐标。
    func rightAxisDataMaxMinDrawY(visibleData:[ChartPointModel], font:UIFont,insert:UIEdgeInsets,distance:Double)->(Double,Double){
        let strSize = NSAttributedString(string: "00.00", attributes: [.font:font]).size()
        let ys = visibleData.map { $0.y }
        let dataMinY = ys.min() ?? 0
        let dataMaxY = ys.max() ?? 0
        let minY = ptPointFromPoint(point: .init(x: 0, y: dataMinY)).y
        let maxY = ptPointFromPoint(point: .init(x: 0, y: dataMaxY)).y
        let halfLabelHeight = strSize.height * 0.5 + insert.bottom
        let bottomLimit = layer.bounds.height - chartModel.chartContentInsert.bottom - halfLabelHeight
        let topLimit = chartModel.chartContentInsert.top + halfLabelHeight
        let requiredSpacing = strSize.height + insert.bottom * 2 + distance

        if minY >= bottomLimit {
            return positionsPinnedToBottom(minY: bottomLimit, maxY: maxY, spacing: requiredSpacing)
        }
        if maxY <= topLimit {
            return positionsPinnedToTop(minY: minY, maxY: topLimit, spacing: requiredSpacing)
        }
        guard minY - maxY < requiredSpacing + distance else { return (minY, maxY) }

        let centerY = (minY + maxY) * 0.5
        let adjustedMinY = centerY + requiredSpacing * 0.5
        let adjustedMaxY = centerY - requiredSpacing * 0.5
        if adjustedMinY >= bottomLimit {
            return positionsPinnedToBottom(minY: bottomLimit, maxY: adjustedMaxY, spacing: requiredSpacing)
        }
        if adjustedMaxY <= topLimit {
            return positionsPinnedToTop(minY: adjustedMinY, maxY: topLimit, spacing: requiredSpacing)
        }
        return (adjustedMinY, adjustedMaxY)
    }

    /// 在下边界固定最小值标签，并保证两个标签之间的间距。
    private func positionsPinnedToBottom(
        minY: CGFloat,
        maxY: CGFloat,
        spacing: CGFloat
    ) -> (Double, Double) {
        (Double(minY), Double(maxY >= minY - spacing ? minY - spacing : maxY))
    }

    /// 在上边界固定最大值标签，并保证两个标签之间的间距。
    private func positionsPinnedToTop(
        minY: CGFloat,
        maxY: CGFloat,
        spacing: CGFloat
    ) -> (Double, Double) {
        (Double(minY <= maxY + spacing ? maxY + spacing : minY), Double(maxY))
    }
    
    /// 获取水平参考线代理文本，未实现代理时生成默认富文本。
    func horizontalLineAttributedText(_ line: HorizontalLine, color: UIColor, font: UIFont) -> NSAttributedString {
        if let text = chartView.delegate?.lineChartViewHLineFormatAttributeStr?(
            chartView: chartView,
            y: line.y,
            color: color,
            font: font
        ) {
            return text
        }
        return NSAttributedString(
            string: String(format: "%.1f", line.y),
            attributes: [.foregroundColor: color, .font: font]
        )
    }

    /// 从水平参考线标签样式中提取字体颜色并生成富文本。
    func horizontalLineAttributedText(_ line: HorizontalLine) -> NSAttributedString {
        switch line.lableStyle {
        case .top(let color, let font, _),
             .bottom(let color, let font, _),
             .left(let color, let font, _),
             .right(let color, let font, _):
            return horizontalLineAttributedText(line, color: color, font: font)
        case .none:
            return NSAttributedString(string: String(format: "%.1f", line.y))
        }
    }

    /// 计算首尾水平参考线标签避免越界和互相重叠后的 Y 坐标。
    func horizontalLinesMaxMinDrawY(insert:UIEdgeInsets,distance:Double)->(Double,Double){
        guard let firstLine = chartModel.horizontalLines.first,let lastLine = chartModel.horizontalLines.last else{return (0,0)}
        let minLine = firstLine.y < lastLine.y ? firstLine : lastLine
        let maxLine = firstLine.y < lastLine.y ? lastLine : firstLine
        let minText = horizontalLineAttributedText(minLine)
        let maxText = horizontalLineAttributedText(maxLine)
        let minHeight = minText.size().height + insert.top + insert.bottom
        let maxHeight = maxText.size().height + insert.top + insert.bottom

        let dataMinY = minLine.y
        let dataMaxY = maxLine.y
        var miny = ptPointFromPoint(point: .init(x: 0, y: dataMinY)).y
        var maxy = ptPointFromPoint(point: .init(x: 0, y: dataMaxY)).y
        let minAllowedY = chartModel.chartContentInsert.top + maxHeight * 0.5
        let maxAllowedY = layer.bounds.height - chartModel.chartContentInsert.bottom - minHeight * 0.5
        let requiredDistance = maxHeight * 0.5 + minHeight * 0.5 + distance

        maxy = max(maxy, minAllowedY)
        miny = min(miny, maxAllowedY)
        if miny - maxy < requiredDistance {
            let center = (miny + maxy) * 0.5
            maxy = center - requiredDistance * 0.5
            miny = center + requiredDistance * 0.5
            if maxy < minAllowedY {
                let shift = minAllowedY - maxy
                maxy += shift
                miny += shift
            }
            if miny > maxAllowedY {
                let shift = miny - maxAllowedY
                maxy -= shift
                miny -= shift
            }
        }
        return (miny,maxy)
    }
}

// MARK: - Tooltip Rendering

extension LineChartDrawer {

    /// 在指定中心点绘制 Tooltip 的圆角半透明背景。
    func drawTooltip(
        ctx: CGContext,
        center: CGPoint,
        size: CGSize,
        backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.6),
        cornerRadius: CGFloat = 6
    ) {
        
        // 1️⃣ 根据 center + size 计算 rect
        let rect = CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
        
        // 2️⃣ 半透明背景
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        ctx.setFillColor(backgroundColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
    }
}

// MARK: - Drawing Utilities

extension LineChartDrawer {

    /// 计算普通字符串在指定字体下的绘制尺寸。
    func getStringSize(str:String,font:UIFont)->CGSize{
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
        ]
        
        let size = (str as NSString).size(withAttributes: attrs)
        return size
    }
    /// 使用指定字体、颜色和锚点绘制普通字符串。
    func drawText(
        _ text: String,
        point: CGPoint,
        anchor:TextDrawAnchor,
        font: UIFont,
        color: UIColor
    ) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let size = (text as NSString).size(withAttributes: attrs)
        
        let ascent = font.ascender
        let descent = abs(font.descender)
        let textHeight = ascent + descent
        var origin:CGPoint
        switch anchor {
        case .minxminy:
            origin = point
        case .maxxminy:
            origin = CGPoint(
                x: point.x - size.width,
                y: point.y
            )
        case .minxmaxy:
            origin = CGPoint(
                x: point.x,
                y: point.y - size.height
            )
        case .maxxmaxy:
            origin = CGPoint(
                x: point.x - size.width,
                y: point.y - size.height
            )
        case .centerxminy:
            origin = CGPoint(
                x: point.x - size.width * 0.5,
                y: point.y
            )
        case .minxcentery:
            origin = CGPoint(
                x: point.x,
                y: point.y - size.height * 0.5
            )
        case .maxxcentery:
            origin = CGPoint(
                x: point.x - size.width,
                y: point.y - size.height * 0.5
            )
        case .centerxmaxy:
            origin = CGPoint(
                x: point.x - size.width * 0.5,
                y: point.y - size.height
            )
        case .center:
            origin = CGPoint(
                x: point.x - size.width * 0.5,
                y: point.y - size.height * 0.5
            )
        }
        
        (text as NSString).draw(at: origin, withAttributes: attrs)
    }
    
    /// 使用锚点、背景和内边距绘制富文本，并返回背景尺寸。
    func drawText(
        _ text: NSAttributedString,
        point: CGPoint,
        anchor: TextDrawAnchor,
        backgroundColor: UIColor? = nil,
        cornerRadius:CGFloat? = nil,
        padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        clampToChartContent: Bool = true
    )->CGSize {
        // 1. 计算文本大小
        let textSize = text.size()
        
        // 2. 计算带内边距的背景大小
        let backgroundSize = CGSize(
            width: textSize.width + padding.left + padding.right,
            height: textSize.height + padding.top + padding.bottom
        )
        
        // 3. 根据锚点计算背景的绘制原点
        var backgroundOrigin: CGPoint
        switch anchor {
        case .minxminy:
            backgroundOrigin = point
        case .maxxminy:
            backgroundOrigin = CGPoint(
                x: point.x - backgroundSize.width,
                y: point.y
            )
        case .minxmaxy:
            backgroundOrigin = CGPoint(
                x: point.x,
                y: point.y - backgroundSize.height
            )
        case .maxxmaxy:
            backgroundOrigin = CGPoint(
                x: point.x - backgroundSize.width,
                y: point.y - backgroundSize.height
            )
        case .centerxminy:
            backgroundOrigin = CGPoint(
                x: point.x - backgroundSize.width * 0.5,
                y: point.y
            )
        case .minxcentery:
            backgroundOrigin = CGPoint(
                x: point.x,
                y: point.y - backgroundSize.height * 0.5
            )
        case .maxxcentery:
            backgroundOrigin = CGPoint(
                x: point.x - backgroundSize.width,
                y: point.y - backgroundSize.height * 0.5
            )
        case .centerxmaxy:
            backgroundOrigin = CGPoint(
                x: point.x - backgroundSize.width * 0.5,
                y: point.y - backgroundSize.height
            )
        case .center:
            backgroundOrigin = CGPoint(
                x: point.x - backgroundSize.width * 0.5,
                y: point.y - backgroundSize.height * 0.5
            )
        }
        if clampToChartContent {
            if backgroundOrigin.y<chartModel.chartContentInsert.top{
                backgroundOrigin.y = chartModel.chartContentInsert.top
            }
            if backgroundOrigin.y+backgroundSize.height>layer.bounds.height-chartModel.chartContentInsert.bottom{
                backgroundOrigin.y = layer.bounds.height-chartModel.chartContentInsert.bottom-backgroundSize.height
            }
        }
        
        // 4. 创建背景绘制区域
        let backgroundRect = CGRect(origin: backgroundOrigin, size: backgroundSize)
        
        
        // 5. 如果有背景色，绘制圆角背景 - 自动计算圆角半径
        if let bgColor = backgroundColor {
            // 自动计算圆角半径：使用背景高度的一半（胶囊形状）
            var corner = backgroundSize.height / 2
            if let cornerRadius = cornerRadius{
                corner = cornerRadius
            }
            let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: corner)
            bgColor.setFill()
            path.fill()
        }
        
        // 6. 计算文本绘制位置（在背景内部居中）
        let textOrigin = CGPoint(
            x: backgroundOrigin.x + padding.left,
            y: backgroundOrigin.y + padding.top
        )
        
        // 7. 绘制文本
        text.draw(in: CGRect(origin: textOrigin, size: textSize))
        return backgroundSize
    }
    
    /// 将数据坐标转换为图表内容区域内的视图坐标。
    func ptPointFromPoint(point:CGPoint)->CGPoint{
        let x = chartModel.chartContentInsert.left+(point.x - chartModel.minX)/(chartModel.maxX-chartModel.minX)*(layer.bounds.width - chartModel.chartContentInsert.left - chartModel.chartContentInsert.right)
        let y = layer.bounds.height - (chartModel.chartContentInsert.bottom+(point.y - chartModel.minY)/(chartModel.maxY-chartModel.minY)*(layer.bounds.height - chartModel.chartContentInsert.bottom - chartModel.chartContentInsert.top))
        return .init(x: x, y: y)
    }
    
    enum TextDrawAnchor{
        case minxminy
        case maxxminy
        case minxmaxy
        case maxxmaxy
        case centerxminy
        case minxcentery
        case maxxcentery
        case centerxmaxy
        case center
    }
    
}

// MARK: - Axis Step Data Processing

extension LineChartDrawer{
    
    /// 按固定数值步长生成闭区间内的全部刻度。
    func getTicks(min: Double, max: Double, step: Double) -> [Double] {
        guard step > 0 else { return [] }
        guard min <= max else { return [] }
        
        var ticks: [Double] = []
        // 找到第一个 >= min 且是 step 的整数倍的刻度
        let start = ceil(min / step) * step
        
        var value = start
        while value <= max {
            ticks.append(value)
            value += step
        }
        
        return ticks
    }
    
    /// 按日历单位对齐并生成指定时间范围内的时间轴刻度。
    //获取时间轴刻度
    func alignedTimestamps(
        start: TimeInterval,
        end: TimeInterval,
        step: TimeIntervalStep,
        calendar: Calendar = .current
    ) -> [TimeInterval] {
        guard start < end else { return [] }
        var startDate = Date()
        var endDate = Date()
        if chartModel.horizontalAxisFullFrame{
            startDate = Date(timeIntervalSince1970: start - (end-start)/(layer.bounds.width-chartModel.chartContentInsert.left-chartModel.chartContentInsert.right)*chartModel.chartContentInsert.left)
            endDate = Date(timeIntervalSince1970: end+(end-start)/(layer.bounds.width-chartModel.chartContentInsert.left-chartModel.chartContentInsert.right)*chartModel.chartContentInsert.right)
        }else{
            startDate = Date(timeIntervalSince1970: start)
            endDate = Date(timeIntervalSince1970: end)
        }


        var current: Date?

        switch step {

        case .minutes(let m):
            var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
            if let minute = comps.minute {
                let r = minute % m
                comps.minute = r == 0 ? minute : minute + (m - r)
            }
            comps.second = 0
            current = calendar.date(from: comps)

        case .hours(let h):
            var comps = calendar.dateComponents([.year, .month, .day, .hour], from: startDate)
            if let hour = comps.hour {
                let r = hour % h
                comps.hour = r == 0 ? hour : hour + (h - r)
            }
            comps.minute = 0
            comps.second = 0
            current = calendar.date(from: comps)

        case .days(let d):
            var comps = calendar.dateComponents([.year, .month, .day], from: startDate)
            if let day = comps.day {
                let r = (day - 1) % d
                comps.day = r == 0 ? day : day + (d - r)
            }
            comps.hour = 0
            comps.minute = 0
            comps.second = 0
            current = calendar.date(from: comps)

        case .months(let m):
            var comps = calendar.dateComponents([.year, .month], from: startDate)
            if let month = comps.month {
                let r = (month - 1) % m
                comps.month = r == 0 ? month : month + (m - r)
            }
            comps.day = 1
            comps.hour = 0
            comps.minute = 0
            comps.second = 0
            current = calendar.date(from: comps)
        }

        guard var date = current else { return [] }

        // 如果对齐时间仍然早于 start，推进一个 step
        while date < startDate {
            date = calendar.date(byAdding: step.calendarComponent, value: step.value, to: date)!
        }

        var result: [TimeInterval] = []
        while date <= endDate {
            result.append(date.timeIntervalSince1970)
            date = calendar.date(byAdding: step.calendarComponent, value: step.value, to: date)!
        }

        return result
    }
}

enum TimeIntervalStep {
    case minutes(Int)   // 5、10、30
    case hours(Int)     // 1、2…
    case days(Int)      // 1
    case months(Int)    // 1
}

extension TimeIntervalStep {
    var calendarComponent: Calendar.Component {
        switch self {
        case .minutes: return .minute
        case .hours:   return .hour
        case .days:    return .day
        case .months:  return .month
        }
    }

    var value: Int {
        switch self {
        case .minutes(let v),
             .hours(let v),
             .days(let v),
             .months(let v):
            return v
        }
    }
}

/// Package-private date formatting helper that avoids requiring a global Date extension.
private enum LineChartDateFormatter {
    /// Formats a Unix timestamp using the current calendar and locale.
    static func string(from timestamp: TimeInterval, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}
