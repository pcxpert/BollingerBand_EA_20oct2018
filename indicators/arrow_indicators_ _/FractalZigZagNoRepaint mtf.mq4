//+------------------------------------------------------------------+
//| FractalZigZagNoRepaint.mq4
//| Copyright © Pointzero-indicator.com
//| Shows ZigZag signals without repainting, ever.        
//+------------------------------------------------------------------+
#property copyright "Copyright © Arturo Lopez Perez"
 
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
 
#define IName          "Fractal ZigZag No-Repaint"
#define ZZBack         1
 
//-------------------------------
// Input parameters
//-------------------------------
extern string TimeFrame        = "Current time frame";
extern bool CalculateOnBarClose    = true;
extern int  ZZDepth                = 12;
extern int  ZZDev                  = 5;
 
 
//-------------------------------
// Buffers
//-------------------------------
double ExtMapBuffer1[];
double ExtMapBuffer2[];
string indicatorFileName;
int    timeFrame;
 
//-------------------------------
// Internal variables
//-------------------------------
 
// Fractals value -mine-
double fr_resistance       = 0;
double fr_support          = EMPTY_VALUE;
bool fr_resistance_change  = EMPTY_VALUE;
bool fr_support_change     = EMPTY_VALUE;
 
// zzvalues
double zzhigh = 0;
double zzlow = 0;
 
// Offset in chart
int    nShift;   
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    // Arrows
    SetIndexStyle(0, DRAW_ARROW, STYLE_DOT, 1);
    SetIndexArrow(0, 233);
    SetIndexBuffer(0, ExtMapBuffer1);
    SetIndexStyle(1, DRAW_ARROW, STYLE_DOT, 1);
    SetIndexArrow(1, 234);
    SetIndexBuffer(1, ExtMapBuffer2);
         indicatorFileName = WindowExpertName();
         timeFrame         = stringToTimeFrame(TimeFrame);
    // Data window
    IndicatorShortName("Fractal Zig Zag No Repaint");
    SetIndexLabel(0, "Fractal Up");
    SetIndexLabel(1, "Fractal Down"); 
    
    // Copyright
   
    // Chart offset calculation
    switch(Period())
    {
        case     1: nShift = 1;   break;    
        case     5: nShift = 3;   break; 
        case    15: nShift = 5;   break; 
        case    30: nShift = 10;  break; 
        case    60: nShift = 15;  break; 
        case   240: nShift = 20;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 100; break; 
        case 43200: nShift = 200; break;               
    }
    nShift = nShift * 2;
    return(0);
}
 
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
    return(0);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   if (timeFrame!=Period())
   {
      int limit = MathMax(MathMin(Bars-IndicatorCounted(),Bars-1),4*timeFrame/Period());
   
       for(int i = limit; i >= 0; i--)
       {
         int y = iBarShift(NULL,timeFrame,Time[i]);
         int x = iBarShift(NULL,timeFrame,Time[i+1]);
            if (x!=y)
            {
               ExtMapBuffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"",CalculateOnBarClose,ZZDepth,ZZDev,0,y);
               ExtMapBuffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"",CalculateOnBarClose,ZZDepth,ZZDev,1,y);
            }
            else
            {
               ExtMapBuffer1[i] = EMPTY_VALUE;
               ExtMapBuffer2[i] = EMPTY_VALUE;
            }
       }
       return(0);
   }
   
    // Start, limit, etc..
    int start = 0;
    int counted_bars = IndicatorCounted();
 
    // nothing else to do?
    if(counted_bars < 0) 
        return(-1);
 
    // do not check repeated bars
    limit = Bars - 1 - counted_bars;
    
    // Check if ignore bar 0
    if(CalculateOnBarClose == true) start = 1;

    // Check the signal foreach bar from past to present
    for(i = limit; i >= start; i--)
    {
        // Zig Zag high
        double zzhighn = iCustom(Symbol(), 0, "ZigZag", ZZDepth, ZZDev, ZZBack, 1, i);
        if(zzhighn != 0) zzhigh = zzhighn;
        
        // Zig Zag low
        double zzlown  = iCustom(Symbol(), 0, "ZigZag", ZZDepth, ZZDev, ZZBack, 2, i);
        if(zzlown != 0) zzlow = zzlown;
     
        // Last fractals
        double resistance = upper_fractal(i);
        double support = lower_fractal(i);
        
        //--------------------------------------------------------
        // Show signals
        //--------------------------------------------------------
        
        // Show signal if it is a fractal and matches last zigzag high value
        if(fr_support_change == true && fr_support == zzlow)
        {
            // Show arrow on fractal and pricetag
            ExtMapBuffer1[i+2] = fr_support - nShift*Point;
            
        } else 
       
        // Show signal if it is a fractal and matches last zigzag low value
        if(fr_resistance_change == true && fr_resistance == zzhigh)
        {
            // Show arrow on fractal and pricetag
            ExtMapBuffer2[i+2] = fr_resistance + nShift*Point;
        }
    }
    return(0);
}
 
//+------------------------------------------------------------------+
//| Custom code ahead
//+------------------------------------------------------------------+
 
/**
* Returns fractal resistance
* @param int shift
*/
 
double upper_fractal(int shift = 1)
{
   double middle = iHigh(Symbol(), 0, shift + 2);
   double v1 = iHigh(Symbol(), 0, shift);
   double v2 = iHigh(Symbol(), 0, shift+1);
   double v3 = iHigh(Symbol(), 0, shift + 3);
   double v4 = iHigh(Symbol(), 0, shift + 4);
   if(middle > v1 && middle > v2 && middle > v3 && middle > v4/* && v2 > v1 && v3 > v4*/)
   {
      fr_resistance = middle;
      fr_resistance_change = true;
   } else {
      fr_resistance_change = false;
   }
   return(fr_resistance);
}
 
/**
* Returns fractal support and stores wether it has changed or not
* @param int shift
*/
 
double lower_fractal(int shift = 1)
{
   double middle = iLow(Symbol(), 0, shift + 2);
   double v1 = iLow(Symbol(), 0, shift);
   double v2 = iLow(Symbol(), 0, shift+1);
   double v3 = iLow(Symbol(), 0, shift + 3);
   double v4 = iLow(Symbol(), 0, shift + 4);
   if(middle < v1 && middle < v2 && middle < v3 && middle < v4/* && v2 < v1 && v3 < v4*/)
   {
      fr_support = middle;
      fr_support_change = true;
   } else {
      fr_support_change = false;
   }
   return(fr_support);
}
 
//+------------------------------------------------------------------+

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int charr = StringGetChar(s, length);
         if((charr > 96 && charr < 123) || (charr > 223 && charr < 256))
                     s = StringSetChar(s, length, charr - 32);
         else if(charr > -33 && charr < 0)
                     s = StringSetChar(s, length, charr + 224);
   }
   return(s);
}