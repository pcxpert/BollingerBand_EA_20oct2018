//+------------------------------------------------------------------+
//|                                                 BandsMA_2dev.mq4 |
//|                                     Copyright © 2005, RobertHill |
//|                                        http://www.mrpipforex.com |
//|                                                                  |
//| Modified Bollinger Bands by Robert Hill to use any standard MA   |
//| as well as LSMA to replace SMA                                   |
//| Two standard deviation lines are displayed based on user input   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Robert Hill"
#property link      "http://www.mrpipforex.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 White
#property indicator_color2 Lime
#property indicator_color3 Aqua

//---- indicator parameters
extern string  m = "--Moving Average Types--";
extern string  m0 = " 0 = SMA";
extern string  m1 = " 1 = EMA";
extern string  m2 = " 2 = SMMA";
extern string  m3 = " 3 = LWMA";
extern string  m4 = " 4 = LSMA";
extern int     MA_Type=0;
extern string  p = "--Applied Price Types--";
extern string  p0 = " 0 = close";
extern string  p1 = " 1 = open";
extern string  p2 = " 2 = high";
extern string  p3 = " 3 = low";
extern string  p4 = " 4 = median(high+low)/2";
extern string  p5 = " 5 = typical(high+low+close)/3";
extern string  p6 = " 6 = weighted(high+low+close+close)/4";
extern int     MA_AppliedPrice = 5;
extern string  b = "--Bands Inputs--";
extern int     BandsPeriod=72;
extern int     BandsShift=3;
extern double  BandsDeviations1 = 1.6185;
extern double  BandsDeviations2 = 1.6185;
extern bool    DisplayMidLine = true;

//---- buffers
double MovingBuffer[];
double UpperBuffer1[];
double LowerBuffer1[];
double UpperBuffer2[];
double LowerBuffer2[];

//---- variables

int    MA_Mode;
string strMAType;
double myPoint;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,STYLE_DOT,0);
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1,UpperBuffer1);
   SetIndexStyle(2,DRAW_LINE, STYLE_SOLID,2);
   SetIndexBuffer(2,LowerBuffer1);
  
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
   SetIndexDrawBegin(3,BandsPeriod+BandsShift);
   SetIndexDrawBegin(4,BandsPeriod+BandsShift);
//----

switch (MA_Type)
   {
      case 1: strMAType="EMA"; MA_Mode=MODE_EMA; break;
      case 2: strMAType="SMMA"; MA_Mode=MODE_SMMA; break;
      case 3: strMAType="LWMA"; MA_Mode=MODE_LWMA; break;
      case 4: strMAType="LSMA"; break;
      default: strMAType="SMA"; MA_Mode=MODE_SMA; break;
   }
   IndicatorShortName( strMAType+ " (" +BandsPeriod + ") ");
   myPoint = SetPoint();

   return(0);
  }

//+------------------------------------------------------------------+
//| LSMA with PriceMode                                              |
//| LSMA - Least Squares Moving Average function calculation         |
//|        Indicator plots the end of the linear regression line     |
//| PrMode  0=close, 1=open, 2=high, 3=low, 4=median(high+low)/2,    |
//| 5=typical(high+low+close)/3, 6=weighted(high+low+close+close)/4  |
//+------------------------------------------------------------------+

double LSMA(int TimeFrame, int LSMAPeriod, int LSMAPrice,int shift)
{
   double wt;
   
   double ma1=iMA(NULL,TimeFrame,LSMAPeriod,0,MODE_SMA ,LSMAPrice,shift);
   double ma2=iMA(NULL,TimeFrame,LSMAPeriod,0,MODE_LWMA,LSMAPrice,shift);
   wt = MathFloor((3.0*ma2-2.0*ma1)/myPoint)*myPoint;
   return(wt);
}  

double SetPoint()
{
   double mPoint;
   
   if (Digits < 4)
      mPoint = 0.01;
   else
      mPoint = 0.0001;
   
   return(mPoint);
}

//+------------------------------------------------------------------+
//| Bollinger Bands                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    i,k,counted_bars=IndicatorCounted();
   double deviation1, deviation2;
   double sum,oldval,newres;
//----
   if(Bars<=BandsPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=BandsPeriod;i++)
        {
         MovingBuffer[Bars-i]=EMPTY_VALUE;
         UpperBuffer1[Bars-i]=EMPTY_VALUE;
         LowerBuffer1[Bars-i]=EMPTY_VALUE;
         UpperBuffer2[Bars-i]=EMPTY_VALUE;
         LowerBuffer2[Bars-i]=EMPTY_VALUE;
        }
//----
   int limit=Bars-counted_bars;
   if(counted_bars>0) limit++;
   for(i=0; i<limit; i++)
   {
     if (MA_Type == 4)
      MovingBuffer[i]=LSMA(0, BandsPeriod, MA_AppliedPrice,i);
     else
      MovingBuffer[i]=iMA(NULL,0,BandsPeriod,BandsShift,MA_Mode,MA_AppliedPrice,i);
   }
//----
   i=Bars-BandsPeriod+1;
   if(counted_bars>BandsPeriod-1) i=Bars-counted_bars-1;
   while(i>=0)
     {
      sum=0.0;
      k=i+BandsPeriod-1;
      oldval=MovingBuffer[i];
      while(k>=i)
        {
         newres=Close[k]-oldval;
         sum+=newres*newres;
         k--;
        }
      deviation1=BandsDeviations1*MathSqrt(sum/BandsPeriod);
      deviation2=BandsDeviations2*MathSqrt(sum/BandsPeriod);
      UpperBuffer1[i]=oldval+deviation1;
      LowerBuffer1[i]=oldval-deviation1;
      UpperBuffer2[i]=oldval+deviation2;
      LowerBuffer2[i]=oldval-deviation2;
      i--;
     }
   if (DisplayMidLine == false)
   {
      for(i=1;i<=Bars;i++)
         MovingBuffer[i]=EMPTY_VALUE;
   }
   //----
   return(0);
  }
//+------------------------------------------------------------------+