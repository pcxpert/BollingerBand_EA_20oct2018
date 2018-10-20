//+------------------------------------------------------------------+
//|                                                          Atr&CandleLength .mq4 |
//|            ATR code Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

/* 
An indi calculating & drawing bar/candle length as a % of atr (as a histo) 
it checks if a bar is in the range > 0.5 x atr, < 2 x atr 
- candles inside that range are in the 2nd color 
- outside, in the third color. 
the scaler variable allows choosing between a candle length divisor of 
- 1 - for real values - which, because some candles are 2 x atr, flattens the atr curve visuals 
- 2 - for values / 2 - which preserves the atr curve visuals 
To see the effect of your choice, load a standard atr indi at the same time and compare the two. 
*/

#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow // atr curve 
#property  indicator_color2  DarkBlue // in range 
#property  indicator_color3  Yellow // out of range 

// #property indicator_level1 0.9

//---- input parameters
extern int AtrPeriod=377;
extern int scaler= 2 ;
//---- buffers
double AtrBuffer[], InBuffer[], OutBuffer[], TempBuffer[], HiLoBuffer[] ;
double Atrval, high, low, candlelen ;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- 1 additional buffer used for counting.
   IndicatorBuffers(5);
   IndicatorDigits(Digits);
//---- indicator 

   SetIndexStyle(0,DRAW_LINE); //				atr curve 
   SetIndexBuffer(0,AtrBuffer);
   SetIndexDrawBegin(0,AtrPeriod);

   SetIndexBuffer(1,InBuffer); //				in range 
   SetIndexDrawBegin(1,AtrPeriod);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY, 2);
   SetIndexLabel(1," - > 50%, < 200%");

   SetIndexBuffer(2,OutBuffer); //				out of range 
   SetIndexDrawBegin(2,AtrPeriod);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY, 2);
   SetIndexLabel(2," - < 50% or > 200%"); 

   SetIndexBuffer(3,HiLoBuffer); //				high - low 
   SetIndexDrawBegin(3,AtrPeriod);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexLabel(3," - Hi-Lo"); 

   SetIndexBuffer(4,TempBuffer);

//---- name for DataWindow and indicator subwindow label
   short_name="ATR("+AtrPeriod+") vs CandleLength ";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetLevelValue(1,0.0);
//   SetLevelValue(2,0.06);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=AtrPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=AtrPeriod;i++) AtrBuffer[Bars-i]=0.0;
//----
   i=Bars-counted_bars-1;
   while(i>=0)
     {
      high=High[i];
      low =Low[i];
      if(i==Bars-1) TempBuffer[i]=high-low;
      else
        {
         double prevclose=Close[i+1];
         TempBuffer[i]=MathMax(high,prevclose)-MathMin(low,prevclose);
        }
      i--;
     }
//----
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   for(i=0; i<limit; i++)
    {
      Atrval=iMAOnArray(TempBuffer,Bars,AtrPeriod,0,MODE_SMA,i);
      AtrBuffer[i]=Atrval ;
      high=High[i];
      low =Low[i];
      candlelen = NormalizeDouble(high - low,Digits) ; 
//      HiLoBuffer[i] = candlelen ;
      if ( candlelen < ( Atrval *2 ) || candlelen > ( Atrval /2 ) ) 
       {
         InBuffer[i] = candlelen / scaler ;
         OutBuffer[i] = 0 ;
       }
      if ( candlelen > ( Atrval *2 ) || candlelen < ( Atrval /2 ) ) 
//      else 
       {
         OutBuffer[i] = candlelen / scaler ;
         InBuffer[i] = 0 ;
       }
    }
//----

   return(0);
  }
//+------------------------------------------------------------------+