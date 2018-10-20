//------------------------------------------------------------------
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrLime
#property indicator_color2  clrDimGray
#property indicator_color3  clrRed
#property indicator_color4  clrDimGray
#property indicator_color5  clrLime
#property indicator_color6  clrLime
#property indicator_color7  clrRed
#property indicator_color8  clrRed
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property indicator_width7  2
#property indicator_width8  2
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_minimum -5
#property indicator_maximum 105
#property strict

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enColorOn
{
   cl_slope, // Change color on slope change
   cl_mid,   // Change color on middle level cross
   cl_out    // Change color on outer levels cross
};
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
};

extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame
extern enPrices Price            = pr_hatbiased2;   // Price to use 
extern int      StochasticDepth  = 1;          // Depth
extern int      StochasticLength = 55;         // Period
input int       MAPeriod         = 5;          // Smoothing period 
input enMaTypes MAMethod         = ma_lwma;     // Smoothing method
input enColorOn ColorOn          = cl_slope;     // Color change on :  
extern int      flLookBack       = 25;         // Floating levels look back period
extern double   flLevelUp        = 90;         // Floating levels up level %
extern double   flLevelDown      = 10;         // Floating levels down level %
extern bool     alertsOn         = false;      // Turn alerts on
extern bool     alertsOnCurrent  = true;       // Alerts on current
extern bool     alertsMessage    = true;       // Alerts message
extern bool     alertsSound      = false;      // Alerts sound
extern bool     alertsEmail      = false;      // Alerts email
extern bool     Interpolate      = true;           // Interpolate in multi time frame mode?
extern int    YDistance          = 68;
extern int    XDistance          = 2;
extern int    corner             = 0;
extern string ButtonID           = "Recursive stochastic";

double dssBuffer[];
double dssBufferua[];
double dssBufferub[];
double dssBufferda[];
double dssBufferdb[];
double slope[],levup[],levmi[],levdn[];
bool returnBars;
string indicatorFileName;
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
   IndicatorBuffers(9);
   SetIndexBuffer(0,levup);
   SetIndexBuffer(1,levmi);
   SetIndexBuffer(2,levdn);
   SetIndexBuffer(3,dssBuffer);
   SetIndexBuffer(4,dssBufferua);
   SetIndexBuffer(5,dssBufferub);
   SetIndexBuffer(6,dssBufferda);
   SetIndexBuffer(7,dssBufferdb);
   SetIndexBuffer(8,slope);
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame==-99;
   TimeFrame         = MathMax(TimeFrame,_Period);
   StochasticLength = MathMax(1,StochasticLength);
   IndicatorShortName((string)StochasticDepth+" times smoothed stochastic ("+(string)StochasticDepth+","+(string)StochasticLength+","+(string)MAPeriod+")");
   
   if (ObjectFind(ButtonID)!=0)
   {
       ObjectCreate(ChartID(),ButtonID,OBJ_BUTTON,WindowOnDropped(),0,0);
         ObjectSetString(ChartID(),ButtonID,OBJPROP_TEXT,timeFrameToString(TimeFrame)+" "+ButtonID+" is on");
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_FONTSIZE,10);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_CORNER,corner);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_COLOR,clrWhite);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrDimGray);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_YDISTANCE,YDistance);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_XDISTANCE,XDistance);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_XSIZE,190);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_YSIZE,20);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_HIDDEN,true);
         ObjectSetInteger(ChartID(),ButtonID,OBJPROP_STATE,true);
   }
   return(0);
}
void OnDeinit(const int reason)
{ 
   if (!returnBars)
      switch(reason)
      {
         case REASON_PARAMETERS  : ObjectDelete(ButtonID);
         case REASON_CHARTCHANGE : ObjectDelete(ButtonID);
         case REASON_RECOMPILE   : ObjectDelete(ButtonID);
         case REASON_CLOSE       : break;
         default :
         {
            ObjectDelete(ButtonID);
         }                  
      }
}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   static string prevState ="";
   if (id==CHARTEVENT_OBJECT_CLICK && sparam==ButtonID)
   {
   string newState = GetButtonState(ButtonID);
         if (newState!=prevState)
         if (newState=="off")
         { 
            for (int i=0; i<8; i++) SetIndexStyle(i,DRAW_NONE);
            prevState=newState;
         }
         else  
         { 
            for (int i=0; i<8; i++) SetIndexStyle(i,DRAW_LINE);
            prevState=newState;
         }
         
           ObjectSetString(ChartID(),ButtonID,OBJPROP_TEXT,timeFrameToString(TimeFrame)+" "+ButtonID+" is "+newState);
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _maxDepth 15
int start()
{
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
      int limit = MathMin(Bars-counted_bars,Bars-1);
      int stochasticDepth = MathMax(MathMin(StochasticDepth,_maxDepth),1);
            if (TimeFrame!=_Period)
            {
               #define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Price,StochasticDepth,StochasticLength,MAPeriod,MAMethod,ColorOn,flLookBack,flLevelUp,flLevelDown,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,_buff,_y)
               limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
               if (slope[limit]==-1) CleanPoint(limit,dssBufferda,dssBufferdb);
               if (slope[limit]== 1) CleanPoint(limit,dssBufferua,dssBufferub);
               for(int i=limit; i>=0; i--)
               {   
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                  levup[i]      = _mtfCall(0,y);
                  levmi[i]      = _mtfCall(1,y);
                  levdn[i]      = _mtfCall(2,y);
                  dssBuffer[i]  = _mtfCall(3,y);
                  slope[i]      = _mtfCall(8,y);
                                    
                  dssBufferua[i] = EMPTY_VALUE;
                  dssBufferub[i] = EMPTY_VALUE;
                  dssBufferda[i] = EMPTY_VALUE;
                  dssBufferdb[i] = EMPTY_VALUE;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  #define _interpolate(buff,i,k,n) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                        {
                           _interpolate(levup,i,k,n);
                           _interpolate(levmi,i,k,n);
                           _interpolate(levdn,i,k,n);
                           _interpolate(dssBuffer,i,k,n);
                        }
                  
                  
               }
               
            for(int i=limit; i>=0; i--)
            {
               if (slope[i]==-1) PlotPoint(i,dssBufferda,dssBufferdb,dssBuffer);
               if (slope[i]== 1) PlotPoint(i,dssBufferua,dssBufferub,dssBuffer);
            }                  
            if(slope[0]==  1) ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrGreen);
            if(slope[0]== -1) ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrFireBrick);
            if(slope[0]==  0) ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrDimGray);
            
            return(0);
            
            }
   //
   //
   //
   //
   //
   
   
   if (slope[limit]==-1) CleanPoint(limit,dssBufferda,dssBufferdb);
   if (slope[limit]== 1) CleanPoint(limit,dssBufferua,dssBufferub);
 	for(int i = limit; i>=0; i--)
 	{
 	    double price = getPrice(Price,Open,Close,High,Low,i);
              dssBuffer[i] = iDss(price,price,price,StochasticLength,MAPeriod,MAMethod,i,Bars,0);
              for (int k=1; k<stochasticDepth; k++)
                     dssBuffer[i] = iDss(dssBuffer[i],dssBuffer[i],dssBuffer[i],StochasticLength,MAPeriod,MAMethod,i,Bars,k);
 	                  dssBufferda[i] = EMPTY_VALUE;
 	                  dssBufferdb[i] = EMPTY_VALUE;
                double min   = dssBuffer[ArrayMinimum(dssBuffer,flLookBack,i)];
                double max   = dssBuffer[ArrayMaximum(dssBuffer,flLookBack,i)];
                double range = max-min;
          levup[i] = min+flLevelUp*range/100.0;
          levdn[i] = min+flLevelDown*range/100.0;
          levmi[i] = min+0.5*range;
          slope[i] = (i<Bars-1) ? slope[i+1] : 0;
          
          dssBufferua[i] = EMPTY_VALUE;
          dssBufferub[i] = EMPTY_VALUE;
          dssBufferda[i] = EMPTY_VALUE;
          dssBufferdb[i] = EMPTY_VALUE;
          
          switch (ColorOn)
          {
            case cl_mid:
               if (dssBuffer[i]>levmi[i]) slope[i] =  1;  
               if (dssBuffer[i]<levmi[i]) slope[i] = -1;  
               break;
            case cl_out:
               slope[i] = 0;
               if (dssBuffer[i]>levup[i]) slope[i] =  1;  
               if (dssBuffer[i]<levdn[i]) slope[i] = -1;  
               break;
            default :
               if (i<Bars-1)
               {
                  if (dssBuffer[i]>dssBuffer[i+1]) slope[i] =  1;  
                  if (dssBuffer[i]<dssBuffer[i+1]) slope[i] = -1;  
               }                  
          }
          if (slope[i]==-1) PlotPoint(i,dssBufferda,dssBufferdb,dssBuffer);
          if (slope[i]== 1) PlotPoint(i,dssBufferua,dssBufferub,dssBuffer);
   } 	       
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (slope[whichBar] != slope[whichBar+1])
      {
         if (slope[whichBar] == 1) doAlert((string)stochasticDepth+" times smoothed dss state changed to up");
         if (slope[whichBar] ==-1) doAlert((string)stochasticDepth+" times dss state changed to down");
      }         
   }
   if(slope[0]==  1) ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrGreen);
   if(slope[0]== -1) ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrFireBrick);
   if(slope[0]==  0) ObjectSetInteger(ChartID(),ButtonID,OBJPROP_BGCOLOR,clrDimGray);
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

#define _dssInstances    _maxDepth
#define _dssInstancesSize 3
double   workDss[][_dssInstances*_dssInstancesSize];
#define _sst    0
#define _pHigh  1
#define _pLow   2


double iDss(double close, double high, double low, int length, double smooth, int mode, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workDss,0)!=bars) ArrayResize(workDss,bars); int maInstance = instanceNo*2, r=i; i=Bars-i-1; instanceNo*=_dssInstancesSize;
   
   //
   //
   //
   //
   //
   
         workDss[i][instanceNo+_pHigh] = high;
         workDss[i][instanceNo+_pLow]  = low;
     
            double min = workDss[i][instanceNo+_pLow];
            double max = workDss[i][instanceNo+_pHigh];
            for (int k=1; k<length && (i-k)>=0; k++)
            {
               min = MathMin(min,workDss[i-k][instanceNo+_pLow]);
               max = MathMax(max,workDss[i-k][instanceNo+_pHigh]);
            }
            double stoch  = (min!=max) ? 100*(close-min)/(max-min) : 0;
            workDss[i][instanceNo+_sst] = iCustomMa(mode,stoch,smooth,r,bars,maInstance+0);

            min = workDss[i][instanceNo+_sst];
            max = workDss[i][instanceNo+_sst];
            for (int k=1; k<length && (i-k)>=0; k++)
            {
               min = MathMin(min,workDss[i-k][instanceNo+_sst]);
               max = MathMax(max,workDss[i-k][instanceNo+_sst]);
            }
            stoch = (min!=max) ? 100*(workDss[i][instanceNo+_sst]-min)/(max-min) : 0;
   return(iCustomMa(mode,stoch,smooth,r,bars,maInstance+1));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances _dssInstances*2
#define _maWorkBufferx1 _maInstances
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r=Bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); int k=1;

   workSma[r][instanceNo+0] = price;
   double avg = price; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  avg /= (double)k;
   return(avg);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = _Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(_Symbol+" DSS Bressert jurik",message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
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

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

string GetButtonState(string whichbutton)
{
    bool selected=ObjectGetInteger(ChartID(),whichbutton,OBJPROP_STATE);
    if (selected)
        {return ("on");} 
    else
        {return ("off");}
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}