//+------------------------------------------------------------------+
//| Bandwidth Indicator.mq4
//| Copyright © 2007, Fxid10t@yahoo.com
//| http://www.fxstreet.com/education/technical/identifying-budding-trends-with-bollinger-bands/2006-06-14.html
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Fxid10t@yahoo.com"
#property link      "http://www.fxstreet.com/education/technical/identifying-budding-trends-with-bollinger-bands/2006-06-14.html"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- input parameters
extern int charttimeframe=0; 
extern int period=20;
extern int deviation=2;
extern int bandsshift=0;
extern int appliedprice=0;
double BWI,ub,lb,mb;
//---- indicator buffers
double BWIBuffer[];


int init()  {   
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, BWIBuffer);
   IndicatorShortName("BWI");
   SetIndexDrawBegin(0,period);
   SetIndexLabel(0,"BWI");

return(0); }

int deinit()  {return(0);}

int start() {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- the last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- main loop
   for(int i=0; i<limit; i++)  {
      ub=iBands(Symbol(),charttimeframe,period,deviation,bandsshift,appliedprice,1,i);
      lb=iBands(Symbol(),charttimeframe,period,deviation,bandsshift,appliedprice,2,i);
      mb=iBands(Symbol(),charttimeframe,period,deviation,bandsshift,appliedprice,0,i);
      //Print(ub,lb,mb);
      BWIBuffer[i]=((ub-lb)/mb)*100;}

   return(0);}

