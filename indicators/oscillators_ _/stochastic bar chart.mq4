//------------------------------------------------------------------
// original idea for this indicator from Godfreyh
// this version by mladen
//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-station.com"
#property indicator_separate_window
#property indicator_buffers 4

extern int    StoPeriod     = 14;
extern int    StoSlowing    = 3;
extern int    DrawBars      = 500;
extern color  WickColor     = Gray;
extern color  BodyUpColor   = LimeGreen;
extern color  BodyDownColor = PaleVioletRed;
extern int    BodyWidth     = 4;
extern bool   DrawAsBack    = false;
extern string UniqueID      = "Stochasric bars 1";

//
//
//
//
//

double open[];
double close[];
double high[];
double low[];
int    window;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   SetIndexBuffer(0,open);  SetIndexStyle(0,EMPTY,EMPTY,EMPTY,clrNONE);
   SetIndexBuffer(1,close); SetIndexStyle(1,EMPTY,EMPTY,EMPTY,clrNONE);
   SetIndexBuffer(2,high);  SetIndexStyle(2,EMPTY,EMPTY,EMPTY,clrNONE);
   SetIndexBuffer(3,low);   SetIndexStyle(3,EMPTY,EMPTY,EMPTY,clrNONE);
	IndicatorShortName(UniqueID); 
   return(0);
}

//
//
//
//
//

int deinit()
{
   string lookFor       = UniqueID+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i); if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int start()
{
   int countedBars = IndicatorCounted();
      if (countedBars<0) return(-1);
      if (countedBars>0) countedBars--;
         int drawBars = DrawBars; if (drawBars<1) drawBars = Bars;
         int limit = MathMin(MathMin(Bars-countedBars,Bars-1),drawBars);
            window = WindowFind(UniqueID);

   //
   //
   //
   //
   //
   
   for (int i=limit; i>=0; i--)
   {
      open[i]  = iStoch(iMA(NULL,0,1,0,MODE_SMA,PRICE_OPEN ,i),StoPeriod,StoSlowing,i,0);
      close[i] = iStoch(iMA(NULL,0,1,0,MODE_SMA,PRICE_CLOSE,i),StoPeriod,StoSlowing,i,1);
      high[i]  = iStoch(iMA(NULL,0,1,0,MODE_SMA,PRICE_HIGH ,i),StoPeriod,StoSlowing,i,2);
      low[i]   = iStoch(iMA(NULL,0,1,0,MODE_SMA,PRICE_LOW  ,i),StoPeriod,StoSlowing,i,3);
         drawCandle(i);
   }
   return(0);
}

  
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][8];
double iStoch(double price, int period, int smooth, int i, int instanceNo)
{
   if (ArrayRange(work,0) != Bars) ArrayResize(work,Bars); i = Bars-i-1; instanceNo *= 2;
   
   //
   //
   //
   //
   //
   
   work[i][instanceNo] = price;
      double max = work[i][instanceNo];
      double min = work[i][instanceNo];
      for (int k=1; k<period && (i-k)>=0; k++)
         {
            max = MathMax(work[i-k][instanceNo],max);
            min = MathMin(work[i-k][instanceNo],min);
         }
      if (min!=max)
            work[i][instanceNo+1] = (price-min)/(max-min);
      else  work[i][instanceNo+1] = 0.5;
      
      double avg = work[i][instanceNo+1];
      for (k=1; k<smooth && (i-k)>=0; k++) avg += work[i-k][instanceNo+1];
                                           avg /= 1.0*k;

   //
   //
   //
   //
   //
   
   return(100.0*avg);                                           
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
  
void drawCandle(int i)
{
   datetime time = Time[i];
   string   name = UniqueID+":"+time+":";
   
      ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
         ObjectSet(name,OBJPROP_COLOR,WickColor);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,MathMax(high[i],MathMax(close[i],open[i])));
         ObjectSet(name,OBJPROP_PRICE2,MathMin(low[i] ,MathMin(close[i],open[i])));
         ObjectSet(name,OBJPROP_RAY ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
      
   //
   //
   //
   //
   //
         
   name = name+"body";
      ObjectCreate(name,OBJ_TREND,window,0,0,0,0);
         ObjectSet(name,OBJPROP_TIME1,time);
         ObjectSet(name,OBJPROP_TIME2,time);
         ObjectSet(name,OBJPROP_PRICE1,open[i]);
         ObjectSet(name,OBJPROP_PRICE2,close[i]);
         ObjectSet(name,OBJPROP_WIDTH,BodyWidth);
         ObjectSet(name,OBJPROP_RAY  ,false);
         ObjectSet(name,OBJPROP_BACK,DrawAsBack);
         if (open[i]<close[i])
               ObjectSet(name,OBJPROP_COLOR,BodyUpColor);
         else  ObjectSet(name,OBJPROP_COLOR,BodyDownColor);
}