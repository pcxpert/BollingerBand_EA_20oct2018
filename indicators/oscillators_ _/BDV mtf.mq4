//+------------------------------------------------------------------+
//|                                                      BDV mtf.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2015"
#property link      ""
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_levelcolor LimeGreen
#property indicator_width1 3
#property indicator_level1 0
#property indicator_level2 -30
#property indicator_level3 100
#property indicator_level4 40
#property indicator_level5 -50

extern ENUM_TIMEFRAMES    TimeFrame = PERIOD_CURRENT;
extern int Periods   = 20;
extern int StartBar  = 1;
extern int RangeBars = 100;

double PercentVariation[], SimpleVariaton[],AverageSD[];
string indicatorFileName;
bool   returnBars;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
IndicatorBuffers(3);

SetIndexBuffer(0,PercentVariation);
SetIndexStyle (0,DRAW_LINE);
SetIndexBuffer(1,AverageSD);
SetIndexBuffer(2,SimpleVariaton);
indicatorFileName = WindowExpertName();
returnBars        = TimeFrame==-99;
TimeFrame         = MathMax(TimeFrame,_Period);
IndicatorShortName(timeFrameToString(TimeFrame)+" BDV");
   return(INIT_SUCCEEDED);
  }

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1); 
         if (returnBars) { PercentVariation[0] = limit+1; return(0); }
         if (TimeFrame != Period())
         {
            limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
            for (int i=limit; i>=0; i--)
            {
               int x = iBarShift(NULL,TimeFrame,Time[i]);               
                  PercentVariation[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Periods,StartBar,RangeBars,0,x);     
            }
         return(0);                
         }
//average stddev 
//differrence std dev- average
for (i =0; i < limit; i++)
{
   
   double sumSDev; int cont;
   for (int y = StartBar; y <= RangeBars+StartBar; y ++)
      {
         sumSDev += iStdDev(Symbol(),0,Periods,0,MODE_SMA,PRICE_CLOSE,i+y);
         cont++;
      }
   
   if (cont == 0) cont = 1;
   AverageSD[i]=sumSDev/cont;
   
   SimpleVariaton[i]=iStdDev(Symbol(),0,Periods,0,MODE_SMA,PRICE_CLOSE,i)-AverageSD[i];
   
   if(AverageSD[i]!=0) 
     PercentVariation[i] = SimpleVariaton[i]/AverageSD[i]*100;
   else
     PercentVariation[i]=0;
}


return(0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}