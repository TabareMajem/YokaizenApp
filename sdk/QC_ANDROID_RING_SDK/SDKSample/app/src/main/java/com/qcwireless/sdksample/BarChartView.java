package com.qcwireless.sdksample;


import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.VelocityTracker;
import android.view.View;
import android.widget.Scroller;

import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;

/**
 * @Author: Hzy
 * @CreateDate: 2022/11/7 23:02
 * <p>
 * "程序应该是写给其他人读的,
 * 让机器来运行它只是一个附带功能"
 */
public class BarChartView extends View {

    private Paint axisPaint;//画L线
    private int axisWidth= (int) dp2px(getContext(),2);//线的宽度
    private int axisColor = Color.LTGRAY;//线的颜色

    private int paddingLeft = (int) dp2px(getContext(),20);
    private int paddingTop = (int) dp2px(getContext(),20);
    private int paddingRight =  (int) dp2px(getContext(),20);
    private int paddingBottom =  (int) dp2px(getContext(),20);
    private int xTextHeight = (int) dp2px(getContext(),20);//X轴底部文字高度


    private TextPaint axisTextPaint;//画坐标轴的文字
    private int axisTextSize= (int) dp2px(getContext(),12);//文字大小
    private int axisTextColor = Color.BLACK;

    private TextPaint axisXTextPaint;//画坐标轴的文字
    private int axisXTextSize= (int) dp2px(getContext(),10);//文字大小
    private int axisXTextColor = Color.BLACK;

    private TextPaint barTextPaint;//画坐标轴的文字
    private int barTextSize= (int) dp2px(getContext(),10);//文字大小
    private int barTextColor = Color.BLACK;
    private int barTextHeight =  (int) dp2px(getContext(),15);

    public void setBarTextColor(int barTextColor) {
        this.barTextColor = barTextColor;
    }

    private int barWidth = (int) dp2px(getContext(),10);//柱子宽度
    private int barSpace = (int) dp2px(getContext(),10);//柱子间距

    //设置柱子宽度
    public void setBarWidth(int barWidth) {
        this.barWidth = barWidth;
    }

    private Paint barPaint;//画柱子
    private int barColor = Color.GREEN;//柱子颜色

    //设置柱子颜色
    public void setBarColor(int barColor) {
        this.barColor = barColor;
    }

    private Paint LegendPaint;
    private TextPaint legendTextPaint;
    private int legendTextColor = Color.BLACK;
    private int legendTextSize = (int) dp2px(getContext(),10);


    private List<Float> yList;//y轴数据
    private List<String> xList;

    private int maxOffset;
    private float lastX;

    private VelocityTracker tracker;
    private Scroller scroller;

    private boolean isLegend;
    private String legendText;

    public float dp2px(Context context, float dp) {

        final float scale = context.getResources().getDisplayMetrics().density;
        return dp * scale + 0.5f;
    }

    //设置数据
    public void setChartData(List<String> xList,List<Float> yList,boolean isLegend,String legendText){
        this.yList = yList;
        this.xList = xList;
        this.isLegend = isLegend;
        this.legendText = legendText;
        invalidate();
    }

    //得到Y轴最大值
    private float maxYData(List<Float> lists){
        HashSet<Float> hashSet = new HashSet<>(lists);
        List<Float> list = new ArrayList<>(hashSet);
        Collections.sort(list);//升序
        return list.get(list.size()-1);
    }

    public BarChartView(Context context) {
        this(context,null);
    }

    public BarChartView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs,0);
    }

    public BarChartView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
//        axisPaint = new Paint();
//        axisPaint.setStrokeWidth(axisWidth);
//        axisPaint.setColor(axisColor);
//        axisPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
//        axisPaint.setAntiAlias(true);

        axisTextPaint = new TextPaint();
        axisTextPaint.setAntiAlias(true);
        axisTextPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        axisTextPaint.setTextSize(axisTextSize);
        axisTextPaint.setColor(axisTextColor);

        axisXTextPaint = new TextPaint();
        axisXTextPaint.setAntiAlias(true);
        axisXTextPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        axisXTextPaint.setTextSize(axisXTextSize);
        axisXTextPaint.setColor(axisXTextColor);

        barTextPaint = new TextPaint();
        barTextPaint.setAntiAlias(true);
        barTextPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        barTextPaint.setTextSize(barTextSize);
        barTextPaint.setColor(barTextColor);

        barPaint = new Paint();
        barPaint.setColor(barColor);
        barPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        barPaint.setAntiAlias(true);

        LegendPaint = new Paint();
        LegendPaint.setColor(barColor);
        LegendPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        LegendPaint.setAntiAlias(true);

        legendTextPaint = new TextPaint();
        legendTextPaint.setAntiAlias(true);
        legendTextPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        legendTextPaint.setTextSize(legendTextSize);
        legendTextPaint.setColor(legendTextColor);

        scroller = new Scroller(getContext());

    }
    private float ageY;//平均没等分是多少


    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int width = getMeasuredWidth();
        int height = getMeasuredHeight();

        if (yList==null || yList.size()==0)return;
        int maxTextWidth = (int) axisTextPaint.measureText(maxYData(yList)+"0000000");
        int left = paddingLeft+axisWidth/2+maxTextWidth;//paddingLeft+线的宽度/2+Y轴值最大宽度
        int right = width - paddingRight;
        int top = paddingTop;
        int bottom = height-paddingBottom-axisWidth/2;//预留X轴文字高度
        canvas.save();
        canvas.translate(getScrollX(),0);
        //画Legend
//        if (isLegend){
//            Rect rect = new Rect();
//            rect.left = (width-left-paddingRight)/2;
//            rect.top= top;
//            rect.right=rect.left+20;
//            rect.bottom= top+20;
//            canvas.drawRect(rect,LegendPaint);
//            Paint.FontMetricsInt LegendmetricsInt = legendTextPaint.getFontMetricsInt();
//            int dyLegend = (LegendmetricsInt.bottom-LegendmetricsInt.top)/2-LegendmetricsInt.bottom;
//            float ydyLegend = dyLegend+rect.top+10;
//            canvas.drawText(legendText,rect.right+20,ydyLegend,legendTextPaint); //
//        }

        //画Y轴值
        float maxdata = maxYData(yList);//最大值
        float agedata = maxdata/8;//平均每份
        ageY = (height-paddingBottom-paddingTop)/8;//线的每等分
//        for (int i=0;i<8;i++){
//            if (i==0){
//                canvas.drawText("0",paddingLeft,height-paddingBottom-xTextHeight,axisTextPaint);//画Y轴刻度
//            }else {
//                Paint.FontMetricsInt metricsInt = axisTextPaint.getFontMetricsInt();
//                int dy = (metricsInt.bottom-metricsInt.top)/2-metricsInt.bottom;
//                float y = dy+(height-paddingBottom)-ageY*i-xTextHeight;
//                canvas.drawText(""+i*agedata*1.2,paddingLeft,y,axisTextPaint); //画Y轴刻度
//            }
//
//        }
//        canvas.drawLine(left,top,left,bottom-xTextHeight,axisPaint);//画Y轴
//        canvas.drawLine(left,bottom-xTextHeight,right,bottom-xTextHeight,axisPaint);//画X轴
        for (int i=0;i<yList.size();i++){
            int x0 = left+(barSpace+barWidth)*i+barSpace+getScrollX();
            int x1 = x0+barWidth;
            if (x1<=left || x0>=right){
                continue;
            }
            float top0 =(float)( height-paddingBottom-(yList.get(i)*ageY/(agedata*1.2))-xTextHeight);
            canvas.clipRect(left,top,right,bottom);//剪切柱状图区域
            canvas.drawRect(x0,top0,x1,bottom-xTextHeight,barPaint);//画柱状图
            //底部X轴文字
            String xtext = xList.get(i);
            float xtextwidth = axisXTextPaint.measureText(xtext);//X文字宽度
            Paint.FontMetricsInt metricsInt = axisXTextPaint.getFontMetricsInt();
            int dy = (metricsInt.bottom-metricsInt.top)/2-metricsInt.bottom;
            float y = height-xTextHeight-dy;
            canvas.drawText(xtext,x0+(barWidth-xtextwidth)/2f,y,axisXTextPaint);
//            //柱状图上加文字
//            String ytext = String.valueOf(yList.get(i));
//            float ytextwidth = barTextPaint.measureText(ytext);
//            canvas.drawText(ytext,x0+(barWidth-ytextwidth)/2f,top0-barTextHeight,barTextPaint);
        }
        maxOffset = (yList.size() * (barWidth+barSpace)-(getMeasuredWidth()-paddingRight-paddingLeft-maxTextWidth));//计算可滑动距离
        if (maxOffset<0){
            maxOffset=0;
        }

        canvas.restore();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()){
            case MotionEvent.ACTION_DOWN:
                if (tracker!=null){
                    tracker.clear();
                }
                lastX = event.getX();
                break;
            case MotionEvent.ACTION_MOVE:
                if (tracker==null){
                    tracker = VelocityTracker.obtain();
                }
                if (tracker!=null){
                    tracker.addMovement(event);
                }
                int sX= getScrollX();
                sX += event.getX()-lastX;
                sX = Math.max(Math.min(0,sX),-maxOffset);
                scrollTo(sX,0);
                lastX=event.getX();
                break;
            case MotionEvent.ACTION_UP:
                setTracker();
                break;
            case MotionEvent.ACTION_CANCEL:
                setTracker();
                break;
        }
        invalidate();
        return true;
    }

    private void setTracker(){
        if (tracker!=null){
            tracker.computeCurrentVelocity(1000);
            scroller.forceFinished(true);
            scroller.fling(getScrollX(),0,(int) (0.5*tracker.getXVelocity()),0,-maxOffset,0,0,0);
            tracker.recycle();
        }
        tracker=null;
    }

    @Override
    public void computeScroll() {
        if (scroller.computeScrollOffset()){
            scrollTo(scroller.getCurrX(),0);
            postInvalidate();
        }
    }
}