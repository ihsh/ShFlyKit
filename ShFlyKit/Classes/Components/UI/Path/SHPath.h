//
//  SHLabelLine.hpp
//  SHLabel
//
//  Created by hsh on 15/10/21.
//  Copyright © 2019年 hsh. All rights reserved.
//


#ifdef __cplusplus

#include <stdio.h>
#include <vector>


struct SHPoint {
    double  x;
    double  y;
};


#pragma mark - 路径基类
class SHPath {
public:
    SHPath(SHPoint point);
    SHPath(SHPath *other);
    virtual ~SHPath();
    
    //在路径链结尾附加一个路径链。必须要附加路径链起点才能调用成功
    bool appendPath(SHPath *path);
    //移除前面的路径，使自身成为起点
    bool removeFrontPath();
    //移除后续路径
    bool removeBackPath(bool release = true);
    
    //获取长度
    double getLength(bool isTotal = false);
    //计算两点之间的距离
    double pointSpace(SHPoint point1, SHPoint point2);
    /**
     *  @brief  获取路径的点坐标数组。
     *  @param precision 精度值，两点之间的距离。
     *  @param outBuffer 接收点坐标的容器。
     */
    void getPosTan(double precision, std::vector<SHPoint> *outBuffer);
    //路径点数组强制刷新
    void setNeedsUpdate();
    
    void setEndPoint(SHPoint endPoint) {m_endPoint = endPoint; setNeedsUpdate();};
    //深度复制一条路径，包括后续路径。不过没有复制前面的路径，所以拷贝出来的对象是起
    virtual SHPath *clone(bool needsUpdate = true) = 0;
    
    SHPoint getEndPoint() {return m_endPoint;};
    
protected:
    // 子类只需重写下面两个方法就行
    virtual double getSelfLength() = 0;
    virtual void updatePosTan(double precision) = 0;
    // 属性方法也可重写
    virtual SHPath* getLastPath() { return m_lastPath; };
    virtual void setLastPath(SHPath *lastPath) { m_lastPath = lastPath; setNeedsUpdate(); };
    virtual SHPath* getNextPath() { return m_nextPath; };
    virtual void setNextPath(SHPath *nextPath) { m_nextPath = nextPath; };
    
protected:
    bool m_needsUpdate;
    double m_length;
    /// 路径结束点
    SHPoint m_endPoint;
    std::vector<SHPoint> *m_pointBuffer;
    
private:
    /// 上一条路径，如果为null则表示此对象是起点。
    SHPath *m_lastPath;
    /// 下一条路径
    SHPath *m_nextPath;
};


#pragma mark - 点
class SHPointPath : public SHPath{
public:
    SHPointPath(SHPoint point);
    virtual SHPointPath *clone(bool needsUpdate = true);
    
protected:
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
};


#pragma mark - 直线
class SHLinePath : public SHPath{
public:
    SHLinePath(SHPoint point);
    virtual SHLinePath *clone(bool needsUpdate = true);
    
protected:
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
};


#pragma mark - 圆
class SHRoundPath : public SHPath{
public:
    /**
     *  @brief  圆曲线构造函数。
     *  @param centrePoint 圆心。圆半径由圆心和上一条路径结束点共同决定，如果上一条路径为空则半径为0.
     *  @param angle 路径旋转弧度，2π为一圈，正数为逆时针，负数为顺时针。
     */
    SHRoundPath(SHPoint centrePoint, double angle);
    virtual SHRoundPath *clone(bool needsUpdate = true);
    
protected:
    virtual void setLastPath(SHPath *lastPath);
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
    
private:
    /// 旋转弧度
    double  m_angle;
    /// 开始弧度
    double  m_beginAngle;
    /// 半径
    double  m_radii;
    /// 圆心
    SHPoint m_centrePoint;
};



#pragma mark - 贝塞尔曲线
class SHBezierPath : public SHPath{
public:
    SHBezierPath(SHPoint anchorPoint, SHPoint endPoint);
    virtual SHBezierPath *clone(bool needsUpdate = true);
    
protected:
    virtual void setLastPath(SHPath *lastPath);
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
private:
    /// 锚点
    SHPoint m_anchorPoint;
private:
    ///长度函数反函数，使用牛顿切线法求解
    double invertLength(double t, double l);
    double speed(double t);
    double getBezierLength(double t);
private:
    /// 下面都是求值过程中的中间变量
    int m_ax;
    int m_ay;
    int m_bx;
    int m_by;
    
    double m_A;
    double m_B;
    double m_C;
};



#pragma mark - 自定义曲线
class SHCustomPath : public SHPath{
public:
    SHCustomPath(std::vector<SHPoint> *customPoint);
    virtual ~SHCustomPath();
    virtual SHCustomPath *clone(bool needsUpdate = true);
    
protected:    
    virtual double getSelfLength();
    virtual void updatePosTan(double precision);
    
private:
    std::vector<SHPoint> *m_customPoint;
    
    double calcSegmentPoint(SHPoint point1, SHPoint point2, double precision, double offset, std::vector<SHPoint> *outBuffer);
};


#endif /* SHLabelPath_h */
