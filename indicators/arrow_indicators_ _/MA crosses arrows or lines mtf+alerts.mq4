//+------------------------------------------------------------------+
//|                                                   ma crosses.mq4 |
//+------------------------------------------------------------------+
//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrRed
#property indicator_color3  clrAqua
#property indicator_color4  clrMagenta
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
enum enDisplay
{
   en_lin,  // Display line
   en_lid,  // Display lines with arrows
   en_dot   // Display arrows
};
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};
enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1,     // Monthly
   tf_cus = 12345678        // Custom time frame
};

extern enTimeFrames   TimeFrame       = tf_cu;        // Time frame
extern int            TimeFrameCustom = 0;            // Custom time frame to use (if custom time frame used)
extern int            FastMaPeriod    = 8;            // Fast moving average period
extern enMaTypes      FastMaMethod    = ma_sma;       // Fast moving average method   
extern enPrices       FastMaPrice     = pr_close;     // Fast moving average price to use 
extern int            SlowMaPeriod    = 33;           // Slow moving average period
extern enMaTypes      SlowMaMethod    = ma_sma;       // Slow moving average method   
extern enPrices       SlowMaPrice     = pr_close;     // Slow moving average price to use 
extern enDisplay      DisplayType     = en_lin;       // Display type
extern int            LinesWidth      = 3;            // Lines width (when lines are included in display)
extern int            ArrowSize       = 2;            // Arrow size
extern bool           alertsOn        = false;        // Turn alerts on?
extern bool           alertsOnCurrent = true;         // Alerts on current (still opened) bar?
extern bool           alertsMessage   = true;         // Alerts should show pop-up message?
extern bool           alertsSound     = false;        // Alerts should play alert sound?
extern bool           alertsPushNotif = false;        // Alerts should send push notification?
extern bool           alertsEmail     = false;        // Alerts should send email?
extern string         soundFile       = "alert2.wav"; // Sound file
extern int            ArrowCodeUp     = 233;          // Arrow code up
extern int            ArrowCodeDn     = 234;          // Arrow code down
extern double         ArrowGapUp      = 0.5;          // Gap for arrow up        
extern double         ArrowGapDn      = 0.5;          // Gap for arrow down
extern bool           ArrowOnFirst    = true;         // Arrow on first bars
extern bool           Interpolate     = true;         // Interpolate in multi time frame mode?

//
//
//
//
//

double fastMa[],slowMa[],arrowu[],arrowd[],trend[],count[];

string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,FastMaPeriod,FastMaMethod,FastMaPrice,SlowMaPeriod,SlowMaMethod,SlowMaPrice,DisplayType,0,0,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsPushNotif,alertsEmail,soundFile,ArrowCodeUp,ArrowCodeDn,ArrowGapUp,ArrowGapDn,ArrowOnFirst,_buff,_y)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int init()
{
   IndicatorBuffers(6);   
   int lstyle = DRAW_LINE;     if (DisplayType==en_dot) lstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;    if (DisplayType<en_lid)  astyle = DRAW_NONE;
   SetIndexBuffer(0,arrowu);  SetIndexStyle(0,astyle,0,ArrowSize); SetIndexArrow(0,ArrowCodeUp);
   SetIndexBuffer(1,arrowd);  SetIndexStyle(1,astyle,0,ArrowSize); SetIndexArrow(1,ArrowCodeDn);
   SetIndexBuffer(2,fastMa);  SetIndexStyle(2,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(3,slowMa);  SetIndexStyle(3,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(4,trend);
   SetIndexBuffer(5,count);  
   
   
         indicatorFileName = WindowExpertName();
         if (TimeFrameCustom==0) TimeFrameCustom = MathMax(TimeFrameCustom,_Period);
         if (TimeFrame!=tf_cus)
               TimeFrame = MathMax(TimeFrame,_Period);
         else  TimeFrame = (enTimeFrames)TimeFrameCustom;
   IndicatorShortName(timeFrameToString(TimeFrame)+  " MA Cross ");
return(0);
}

//
//
//
//
//

int deinit() {  return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int start() 
{
  int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;

   //
   //
   //
   //
   //

   if (TimeFrame == _Period)
   {
     for(i=limit; i>=0; i--)
     {
        fastMa[i] = iCustomMa(FastMaMethod,getPrice(FastMaPrice,Open,Close,High,Low,i,0),FastMaPeriod,i,0);           
        slowMa[i] = iCustomMa(SlowMaMethod,getPrice(SlowMaPrice,Open,Close,High,Low,i,1),SlowMaPeriod,i,1);  
        arrowu[i]  = EMPTY_VALUE;
        arrowd[i]  = EMPTY_VALUE;
        trend[i] = (i<Bars-1) ? (fastMa[i]>slowMa[i]) ? 1 : (fastMa[i]<slowMa[i]) ? -1 : trend[i+1] : 0;
        if (i<Bars-1 && trend[i]!=trend[i+1])
         {
            if (trend[i] ==  1) arrowu[i] = Low[i] -iATR(NULL,0,15,i)*ArrowGapUp;
            if (trend[i] == -1) arrowd[i] = High[i]+iATR(NULL,0,15,i)*ArrowGapDn;
         }
      }   
      
      //
      //
      //
      //
      //
        
      if (alertsOn)
      {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(" up");
            if (trend[whichBar] ==-1) doAlert(" down");       
         }         
       }              
   return(0);
   }
      
   //
   //
   //
   //
   //

   limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(5,0)*TimeFrame/_Period));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
      int x = y;
      if (ArrowOnFirst)
            {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);               }
      else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
         fastMa[i]  = _mtfCall(2,y);
         slowMa[i]  = _mtfCall(3,y);
         arrowu[i]  = EMPTY_VALUE;
         arrowd[i]  = EMPTY_VALUE;
         if (x!=y)
         {
            arrowu[i] = _mtfCall(0,y);
            arrowd[i] = _mtfCall(1,y);
         }
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
         //
         //
         //
         //
         //
                  
         #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
         int n,k; datetime time = iTime(NULL,TimeFrame,y);
            for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
            for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
            {
               _interpolate(fastMa);
               _interpolate(slowMa);
             }          
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

#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   int bars = Bars; r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
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
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
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

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
   {
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Ma crossing "+doWhat;
             if (alertsMessage)     Alert(message);
             if (alertsPushNotif )  SendNotification(message);
             if (alertsEmail)       SendMail(_Symbol+" Ma crossing ",message);
             if (alertsSound)       PlaySound(soundFile);
      }
}

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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 2
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