//
//  LineChartModel.swift
//  ChartTest
//
//  Created by Carlo on 8/27/26.
//
import UIKit
//图标模型
@objcMembers public class ChartModel: NSObject{
    //图表线模型
    public var lineModel:ChartLineModel = ChartLineModel()
    //图表曲线显示内容的insert
    public var chartContentInsert:UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)

    
    //顶部轴线类型
    public var topAxisLineStyle:LineStyle = .none
    //底部轴线类型
    public var bottomAxisLineStyle:LineStyle = .none
    //左部轴线类型
    public var leftAxisLineStyle:LineStyle = .none
    //右部轴线类型
    public var rightAxisLineStyle:LineStyle = .none

    
    //顶部轴线文字配置
    public var topAxisLabelStyel:AxisLabelStyle = .none
    //底部轴线文字配置
    public var bottomAxisLabelStyel:AxisLabelStyle = .none
    //左部轴线文字配置
    public var leftAxisLabelStyel:AxisLabelStyle = .none
    //右部轴线文字配置
    public var rightAxisLabelStyel:AxisLabelStyle = .none

    public var topGraduationStepType:AxisStepType = .none
    public var bottomGraduationStepType:AxisStepType = .none
    public var leftGraduationStepType:AxisStepType = .none
    public var rightGraduationStepType:AxisStepType = .none
    
    //底部刻度线配置
    public var bottomGraduationType:GraduationType = .none
    //右侧刻度线配置
    public var rightGraduationType:GraduationType = .none


    //顶部轴线最大最小值配置
    public var topAxisMaxMinStyel:AxisLabelStyle = .none
    //底部轴线最大最小值配置
    public var bottomAxisMaxMinStyel:AxisLabelStyle = .none
    //左部轴线最大最小值配置
    public var leftAxisMaxMinStyel:AxisLabelStyle = .none
    //右部轴线最大最小值配置
    public var rightAxisMaxMinStyel:AxisLabelStyle = .none

    
    //右部数据最大最小值配置
    public var rightAxisDataMaxMinStyel:AxisLabelStyle = .none

    
    //横向线段配置
    public var horizontalLines:[HorizontalLine] = []
    //竖向线段配置
    public var verticalLines:[VerticalLine] = []
    //竖向线段颜色配置
    public var verticalColorRnages:[VerticalColorRange] = []

    //竖向线段底部颜色配置
    public var verticalBGColorRnages:[VerticalColorRange]? = nil
    // gap 配置；默认关闭，配置距离后相邻点超过该 X 距离才显示 gap。
    public var gapStyle: GapStyle = .none
    // 曲线模式下，相邻点小于该屏幕距离时退化为直线，降低密集点绘制开销；0 表示关闭。
    public var bezierToLineMinDistance: CGFloat = 2
    // X 轴允许缩放到的最小时间跨度，单位为秒；0 表示不限制。
    public var minimumXRange: CGFloat = 3600
    //日期显示模式
    public var dateMode:DateMode = .day
    //图标数据显示范围，四个参数定义的区间的数据才会绘制到图表（定义窗口大小）
    public var minX:CGFloat = 0
    public var maxX:CGFloat = 0
    public var minY:CGFloat = 0
    public var maxY:CGFloat = 0
    //保存当前点击的图标数据
    public var tapedItem:ChartPointModel?
    //是否自适应y轴范围
    public var yRangeType:YRangeType = .fixed(min: 19, max: 100)
    //是否自适应y轴范围
    public var XRangeType:XRangeType = .limitedByData
    //水平坐标轴是否全屏显示
    public var horizontalAxisFullFrame = false
    //垂直坐标轴是否全屏显示
    public var verticalAxisFullFrame = false
    //是否开启左右滑动惯性
    public var enableDeceleration = false

    public override init() {
        super.init()
    }



}

@objcMembers public class MaxMinAttrModel:NSObject{
    public var max:NSAttributedString
    public var min:NSAttributedString
    public init(max: NSAttributedString, min: NSAttributedString) {
        self.max = max
        self.min = min
    }
}

@objcMembers public class XYAttrModel:NSObject{
    public var xAttr:NSAttributedString
    public var yAttr:NSAttributedString
    public init(xAttr: NSAttributedString, yAttr: NSAttributedString) {
        self.yAttr = yAttr
        self.xAttr = xAttr
    }
}


public enum YRangeType{
    case selfAdaptAll //所有数据最大最小Y值
    case selfAdaptVisible //可视数据最大最小Y值
    case selfAdaptVisibleWithType(type:XSChartType)
    case selfAdaptVisibleWithMinMax(min:Double,max:Double)//限定的可视数据最大最小Y值
    case fixed(min:Double,max:Double)//手动配置最大最小Y值
}

public enum XRangeType{
    case unlimited  //无限制，图表可以任意滑动，缩放
    case limitedByData  //限定在数据区间内滑动，缩放
    case distaceByNow(Double)// 限定在当前时间到之前的一定间隔间间滑动，缩放，范围：[当前时间戳-Double参数===>当前时间戳]
}

//图表线模型
public class ChartLineModel{
//    var datalineStyle:DataLineStyle = .straight(width: 2, color: UIColor.blue)
    //线段类型
    public var datalineStyle:DataLineStyle = .bezier(width: 2, color: .black)
    //数据线阴影，nil 表示不绘制阴影
    public var dataLineShadow: DataLineShadow?
    //数据点数组
    public var points:[ChartPointModel] = [ChartPointModel]()
    //需要绘制的区域的数据
    public var pointsShouldDraw:[ChartPointModel] = [ChartPointModel]()
    //数据空白区域
    public var emptyAreas = [horizontalEmptyAreaModel]()

    public init() {}



}

//数据线阴影配置
public struct DataLineShadow {
    public var color: UIColor
    public var offset: CGSize
    public var blur: CGFloat

    public init(color: UIColor, offset: CGSize = .zero, blur: CGFloat) {
        self.color = color
        self.offset = offset
        self.blur = max(0, blur)
    }
}

//空白区域模型
public class horizontalEmptyAreaModel{
    public var left:CGFloat = 0
    public var right:CGFloat = 0
    public var tapded = false
    public init(left: CGFloat, right: CGFloat, tapded: Bool = false) {
        self.left = left
        self.right = right
        self.tapded = tapded
    }
}

//图表点模型
@objcMembers public class ChartPointModel {
    public enum DataType{
        case gap
        case data
    }
    public enum Style:Equatable {
        case normal
        case circle(radius:CGFloat,width:CGFloat,color:UIColor)
        public static func == (lhs: Style, rhs: Style) -> Bool {
            switch (lhs, rhs) {
            case (.normal, .normal):
                return true
                
            case  (.circle, .circle):
                return true
            default:
                return false
            }
        }
    }
    public var x:Double = 0
    public var y:Double = 0
    public var dataType =  DataType.data
    //点击后显示的半透明块的大小
    public var detailSize:CGSize = .init(width: 80, height: 40)
    public var detailFont:UIFont = .systemFont(ofSize: 12)
    public var detailColor:UIColor = .white
    public var canTouch:Bool = false
    public var style:Style = .normal

    public var gapLeft:Double = 0
    public var gapRight:Double = 0
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    public init() {
    }
}
//横向背景颜色
public class HorizontalColorRange{
    public enum ShowType{
        case line
        case background
    }
    public var showType:ShowType
    public var left:CGFloat
    public var right:CGFloat
    public var color:UIColor
    public init(showType: ShowType, left: CGFloat, right: CGFloat, color: UIColor) {
        self.showType = showType
        self.left = left
        self.right = right
        self.color = color
    }
}
//竖向背景颜色
public class VerticalColorRange{
    public var top:CGFloat
    public var bottom:CGFloat
    public var topColor:UIColor
    public var bottomColor:UIColor

    public init(top: CGFloat, bottom: CGFloat, topColor: UIColor,bottomColor: UIColor) {
        self.top = top
        self.bottom = bottom
        self.topColor = topColor
        self.bottomColor = bottomColor
    }

}
//横向指示线模型
public class HorizontalLine{
    public var y:CGFloat = 0
    public var lineStyle:LineStyle
    public var lableStyle:AxisLabelStyle
    public init(y: CGFloat, lineStyle: LineStyle, lableStyle: AxisLabelStyle = .none) {
        self.y = y
        self.lineStyle = lineStyle
        self.lableStyle = lableStyle
    }
}
//竖向指示线模型
public class VerticalLine{
    public var x:CGFloat
    public var lineStyle:LineStyle
    public init(x: CGFloat, lineStyle: LineStyle) {
        self.x = x
        self.lineStyle = lineStyle
    }
}

//日期显示模型
@objc public enum DateMode:Int{
    case none = 0
    case hour = 1
    case day = 2
    case week = 3
    case month = 4
    case year = 5
}

//数据线类型
public enum DataLineStyle {
    case straight(width:CGFloat,color:UIColor)//直线
    case bezier(width:CGFloat,color:UIColor)//传统贝塞尔
    case monotoneCubic(width:CGFloat,color:UIColor)//单调三次插值
    case catmullRom(width:CGFloat,color:UIColor)//Catmull-Rom 平滑曲线
}

//数据空白区域配置
public enum GapStyle {
    case none
    case distance(CGFloat)
}

//线段类型
public enum LineStyle {
    case line(width:CGFloat,color:UIColor)//实线
    case dashLine(width:CGFloat,color:UIColor,lengths:[CGFloat])//虚线
    case none //不绘制
}
//轴线文本配置
public enum AxisLabelStyle{
    case top(color:UIColor,font:UIFont,offset:CGFloat?)//显示在轴线的左边
    case bottom(color:UIColor,font:UIFont,offset:CGFloat?)
    case left(color:UIColor,font:UIFont,offset:CGFloat?)
    case right(color:UIColor,font:UIFont,offset:CGFloat?)
    case none
}

public enum AxisStepType{
    case dateAdapt
    case distance(distace:CGFloat,align:CGFloat?)
    case seprateCount(count:UInt8)
    case seprateCountWithAllData(count:UInt8)
    case none
}

@objc public enum AxisDirection:Int{
    case top = 0
    case bottom
    case left
    case right
}

public enum GraduationType{
    case line(lenght:CGFloat? = nil,width:CGFloat,color:UIColor)
    case dashLine(lenght:CGFloat? = nil,width:CGFloat,color:UIColor,lengths:[CGFloat])
    case none
}

//用于oc使用
@objcMembers public class ChartPoint:NSObject{
    public var x:CGFloat = 0
    public var y:CGFloat = 0

    public override init() {
        super.init()
    }
}
//用于oc使用
@objc public enum XSChartType: Int {
    case radon = 1
    case temperature
    case humidity
}

//提供给oc 定义样式
public extension ChartModel{
    @objc convenience init(points:[ChartPoint],type:XSChartType) {
        self.init(points: points, type: type, minThreshold: 75, maxThreshold: 150)
    }

    @objc convenience init(points:[ChartPoint], type:XSChartType, minThreshold: Double, maxThreshold: Double) {
        self.init()

        var modelPoints = [ChartPointModel]()
        for point in points {
            let item = ChartPointModel()
            item.style = .normal
            item.x = point.x
            item.y = point.y
            modelPoints.append(item)
        }
        lineModel.points = modelPoints

        switch type {
        case .radon:
            setupRadonStyle(minThreshold: minThreshold, maxThreshold: maxThreshold)
        case .temperature:
            setupTemperatureStyle()
        case .humidity:
            setupHumidityStyle()
        default:
            break
        }
    }

    private func setupRadonStyle(minThreshold: Double, maxThreshold: Double) {

        chartContentInsert = .init(top: 8, left: 40, bottom: 40, right: 0)
        yRangeType = .selfAdaptVisibleWithMinMax(min: minThreshold, max: maxThreshold)
        lineModel.datalineStyle = .bezier(width: 3, color: .black)
        enableDeceleration = true
        topAxisLineStyle    = .none
        rightAxisLineStyle  = .none
        leftAxisLineStyle   = .none
        bottomAxisLineStyle = .dashLine(width: 1, color: .axisLineColor, lengths: [5, 5])

        bottomAxisLabelStyel      = .bottom(color: .bottomLabelColor, font: .systemFont(ofSize: 11), offset: 8)
        rightAxisLabelStyel       = .left(color: .rightLabelColor,  font: .systemFont(ofSize: 11), offset: 0)
        rightAxisMaxMinStyel      = .none
        rightAxisDataMaxMinStyel  = .left(color: .rightLabelColor,  font: .systemFont(ofSize: 11), offset: 0)
        bottomAxisMaxMinStyel     = .bottom(color: .rightLabelColor, font: .systemFont(ofSize: 11), offset: 0)

        horizontalLines = [
            .init(y: maxThreshold, lineStyle: .dashLine(width: 1, color: .lineColorRed, lengths: [5, 5]),
                  lableStyle: .left(color: .lineColorRed, font: .systemFont(ofSize: 11), offset: 0)),
            .init(y: minThreshold, lineStyle: .dashLine(width: 1, color: .lineColorGreen,  lengths: [5, 5]),
                  lableStyle: .left(color: .lineColorGreen,  font: .systemFont(ofSize: 11), offset: 0))
        ]
        verticalColorRnages = [
            .init(top: 100000000, bottom: maxThreshold, topColor: .lineColorRed,bottomColor: .lineColorRed),
            .init(top:  maxThreshold, bottom: minThreshold, topColor: .lineColorYellow,bottomColor: .lineColorYellow),
            .init(top:  minThreshold, bottom:  0, topColor: .lineColorGreen,bottomColor: .lineColorGreen)
        ]

        horizontalAxisFullFrame = true
        verticalAxisFullFrame   = false
        bottomGraduationStepType = .dateAdapt
        gapStyle = .distance(7200)
        XRangeType              = .limitedByData
    }

    private func setupTemperatureStyle() {

        chartContentInsert = .init(top: 8, left: 0, bottom: 40, right: 0)
        yRangeType = .selfAdaptVisibleWithType(type: .temperature)
        lineModel.datalineStyle = .bezier(width: 3, color: .black)
        enableDeceleration = true

        topAxisLineStyle    = .none
        rightAxisLineStyle  = .none
        leftAxisLineStyle   = .none
        bottomAxisLineStyle = .dashLine(width: 1, color: .axisLineColor, lengths: [5, 5])

        bottomAxisLabelStyel      = .bottom(color: .bottomLabelColor, font: .systemFont(ofSize: 11), offset: 8)
        rightAxisLabelStyel       = .left(color: .rightLabelColor,  font: .systemFont(ofSize: 11), offset: 0)
        rightAxisMaxMinStyel      = .none
        rightAxisDataMaxMinStyel  = .left(color: .rightLabelColor,  font: .systemFont(ofSize: 11), offset: 0)
        bottomAxisMaxMinStyel     = .bottom(color: .rightLabelColor, font: .systemFont(ofSize: 11), offset: 0)

        horizontalLines = []
        verticalColorRnages = [.init(top: 100, bottom: -50, topColor: .lineColorBlue,bottomColor: .lineColorBlue)]
        horizontalAxisFullFrame = true
        verticalAxisFullFrame   = false
        bottomGraduationType          = .none
        bottomGraduationStepType = .dateAdapt
        gapStyle = .distance(7200)
        XRangeType              = .limitedByData
    }

    private func setupHumidityStyle() {

        chartContentInsert = .init(top: 8, left: 0, bottom: 40, right: 0)
        yRangeType = .selfAdaptVisibleWithType(type: .humidity)
        lineModel.datalineStyle = .bezier(width: 3, color: .black)
        enableDeceleration = true

        topAxisLineStyle    = .none
        rightAxisLineStyle  = .none
        leftAxisLineStyle   = .none
        bottomAxisLineStyle = .dashLine(width: 1, color: .axisLineColor, lengths: [5, 5])

        bottomAxisLabelStyel      = .bottom(color: .bottomLabelColor, font: .systemFont(ofSize: 11), offset: 8)
        rightAxisLabelStyel       = .left(color: .rightLabelColor,  font: .systemFont(ofSize: 11), offset: 0)
        rightAxisMaxMinStyel      = .none
        rightAxisDataMaxMinStyel  = .left(color: .rightLabelColor,  font: .systemFont(ofSize: 11), offset: 0)
        bottomAxisMaxMinStyel     = .bottom(color: .rightLabelColor, font: .systemFont(ofSize: 11), offset: 0)

        horizontalLines = []
        verticalColorRnages = [.init(top: 100, bottom: 0, topColor: .lineColorBlue,bottomColor: .lineColorBlue)]

        horizontalAxisFullFrame = true
        verticalAxisFullFrame   = false
        bottomGraduationType          = .none
        bottomGraduationStepType = .dateAdapt
        gapStyle = .distance(7200)
        XRangeType              = .limitedByData
    }
}

public extension UIColor {
    static func hex(_ hexValue: Int , alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: (CGFloat)((hexValue & 0xFF0000) >> 16) / 255.0, green: (CGFloat)((hexValue & 0xFF00) >> 8) / 255.0, blue: (CGFloat)(hexValue & 0xFF) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: alpha
        )
    }
}

@objc
extension UIColor {
    @objc static let lineColorGreen = UIColor.hex(0x56C06F)
    @objc static let lineColorYellow = UIColor.hex(0xFFCF31)
    @objc static let lineColorRed = UIColor.hex(0xE67077)
    @objc static let lineColorBlue = UIColor.hex(0x68A7ED)
    
    @objc static let axisLineColor = UIColor.hex(0xeeeeee)
    @objc static let bottomLabelColor = UIColor.hex(0x666666)
    @objc static let rightLabelColor = UIColor.hex(0x999999)
}
