//+------------------------------------------------------------------+
//|                                              HurstChannel_v2.mq4 |
//|                             Copyright © 2008-09, TrendLaboratory |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"

#property indicator_chart_window
#property indicator_buffers   6
#property indicator_color1    Aqua
#property indicator_width1    1
#property indicator_style1    3
#property indicator_color2    Aqua
#property indicator_width2    1
#property indicator_style2    2       
#property indicator_color3    Aqua
#property indicator_width3    2
#property indicator_color4    Aqua
#property indicator_width4    1
#property indicator_style4    2 
#property indicator_color5    Aqua
#property indicator_width5    2
#property indicator_color6    Aqua
#property indicator_width6    1
#property indicator_style6    2

//---- external variables
extern int     Price          =   4;   //Apply to Price(0-Close;1-Open;2-High;3-Low;4-Median price;5-Typical price;6-Weighted Close)
extern int     Length         =  55;   //Number of bars for an evaluation
extern double  AmplMult       =   5;   //Amplitude multiplier
extern int     ProjLength     =  15;   //Length of Projection 
extern double  K_v            =   1;   //Volatility Multiplier
extern int     BarsBack       =   0;   //Shift in history
extern int     VoltyMode      =   0;   //Volatility Mode: 0-ATR,1-StdDev,2-Percent of Price
extern int     VisualMode     =   0;   //0-lines,1-dots
extern int     CenterMode     =   1;   //Center Mode: 0-off,1-on
//---- indicator buffers
double Center[];
double Project[];
double UpBand[];
double UpProject[];
double DnBand[];
double DnProject[];
double SMA[];
double aPrice[];
//---- global variables
double PriceArray[];
int m,sShift, sLen;
datetime pUpTime = 0, pDnTime = 0;
double pi = 3.1415926535, Volty;
datetime prevtime;  
//+---------------------------------------------------------------------------+
//| Custom indicator initialization function                                  |
//+---------------------------------------------------------------------------+
int init()
{
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   IndicatorBuffers(8);   
   if(VisualMode==0)
   {
      for (m=0;m<=5;m++)
      SetIndexStyle(m, DRAW_LINE);
   }
   else
   {
      for (m=0;m<=5;m++)
      {
      SetIndexStyle(m, DRAW_ARROW);
      SetIndexArrow(m,159);
      }
   }
      
   SetIndexBuffer(0, Center);
   SetIndexBuffer(1, Project);
   SetIndexBuffer(2, UpBand);
   SetIndexBuffer(3, UpProject);
   SetIndexBuffer(4, DnBand);
   SetIndexBuffer(5, DnProject);
   SetIndexBuffer(6, SMA);
   SetIndexBuffer(7, aPrice);
      
   SetIndexDrawBegin(0, Length);
   SetIndexDrawBegin(2, Length);
   SetIndexDrawBegin(4, Length);
         
   SetIndexShift(1, ProjLength - BarsBack);
   SetIndexShift(3, ProjLength - BarsBack);
   SetIndexShift(5, ProjLength - BarsBack);
   
   string short_name="HurstChannel("+Price+","+Length+","+ProjLength+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Center");
   SetIndexLabel(1,"CenterProject");
   SetIndexLabel(2,"UpBand");
   SetIndexLabel(3,"UpProjection");
   SetIndexLabel(4,"DnBand");
   SetIndexLabel(5,"DnProjection");
   
   sLen = MathFloor((Length+1)/2.0)+1;
   sShift = MathFloor((sLen-1)/2.0)+1;  
   ArrayResize(PriceArray, 8*Length);
      
   return(0);
}
//+------------------------------------------------------------------+
//| HurstChannel_v2                                                     |
//+------------------------------------------------------------------+
int start()
{
   int i,k,shift, counted_bars=IndicatorCounted(), limit;

   if (counted_bars < 0) return(0);
   if (counted_bars ==0) limit = Bars-1; 
   if (counted_bars > 0) limit = Bars - counted_bars + sShift + BarsBack;
   
   if (counted_bars < 1)
   { 
      for(i=1;i<Bars;i++)
      { 
      Center[i]=EMPTY_VALUE; 
      UpBand[i]=EMPTY_VALUE;
      DnBand[i]=EMPTY_VALUE;
      Project[i]=EMPTY_VALUE;  
      UpProject[i]=EMPTY_VALUE;
      DnProject[i]=EMPTY_VALUE;
      }
   }   
   for(shift=limit; shift>=0; shift--)
   aPrice[shift] = iMA(NULL,0,1,0,0,Price,shift); 
     
   for(shift=limit;shift>=BarsBack;shift--)
   {
      if(shift >= sShift + BarsBack)
      {
      SMA[shift] = TriMA(aPrice,sLen,shift-sShift); //iMA(NULL,0,sLen,-sShift,MODE_SMA,Price,shift); 
         if(VoltyMode == 0) Volty = iATR(NULL,0,sLen,shift+sShift);
         else
         if(VoltyMode == 1)
         {
            double sum = 0;
            for(i=shift;i<shift+sLen;i++)
            {
            double del = SMA[i] - iMA(NULL,0,1,0,0,Price,i);
            sum += del * del;
            }
            
         if(sLen < 32) Volty = MathSqrt(sum/(sLen-1));   
         else
         Volty = MathSqrt(sum/sLen);       
         }    
         else
         if(VoltyMode == 2) Volty = iMA(NULL,0,1,0,0,Price,shift+sShift)/100;
      if(CenterMode == 1) Center[shift] = SMA[shift];           
      UpBand[shift] = SMA[shift] + K_v * Volty;    
      DnBand[shift] = SMA[shift] - K_v * Volty;
      }
   }
   
   for(i=1;i<8*Length;i++)
   {
      if(i < sShift) PriceArray[i] = iMA(NULL,0,1,0,MODE_SMA,Price,i + BarsBack);    
      else
      if(i >= sShift) PriceArray[i] = SMA[i + BarsBack];   
   }
      
   double Ampl  = _fourier(PriceArray,Length,8,0); 
   double Phase = _fourier(PriceArray,Length,1,1); 
   double Incr  = 2*pi/Length;
      
   k = sShift + ProjLength;
   
   for(i=sShift + BarsBack;i>=-ProjLength + BarsBack;i--)
   {
   double delta = Ampl*MathCos(Phase-(i-BarsBack)*Incr)*AmplMult;
   if(i==sShift + BarsBack) double sval = SMA[i] - delta;
   double proj = delta + sval; 
   if(CenterMode == 1) Project[k] = proj;
   UpProject[k] = proj + K_v * Volty;
   DnProject[k] = proj - K_v * Volty;
   k = k-1;
   }
   
   for(i=sShift+ProjLength+1;i<=sShift+ProjLength+5;i++)
   {
   Project[i] = EMPTY_VALUE; 
   UpProject[i] = EMPTY_VALUE;
   DnProject[i] = EMPTY_VALUE;
   } 
   
   prevtime=Time[0];

   return(0);
}
//+---------------------------------------------------------------------------+

double _fourier(double price[],int per,int numbars,int mode)
{
	int maxd = numbars*per;
		   
	double af = 2*pi/per;
	double xf = MathCos(af); 
	double yf = MathSin(af);
	double gf = 0; 
	double ef = price[maxd-1];
   
	double efhold = ef; 
	double efslope = (price[1]-ef)/(maxd-1);
	ef=0;

      for (int i=maxd-1;i>=1;i--)
	   { 
	   af = ef;
	   efhold = efhold + efslope;
      ef = af * xf - gf * yf + (price[i]-efhold);
      gf = af * yf + gf * xf;
  	   }
   
 	ef = 2 * ef/maxd; 
 	gf = 2 * gf/maxd;

  	double peaka = MathAbs(ef * ef + gf * gf);
	if(peaka > 0) peaka = MathSqrt(peaka);
   else peaka = 0;

   if(ef!=0) double degs = MathArctan(gf / ef);
   else degs = 0;

	if (gf < 0 && ef > 0) degs = degs + 2*pi;
  	if (ef < 0) degs = degs + pi;

	double fportion = (1.0*maxd/per)-MathFloor(maxd/per);  
	if (fportion > 0.01) degs=degs + maxd/per*2*pi;

  	while(degs > 2*pi) degs = degs - 2*pi;
  	while(degs < 0) degs = degs + 2*pi; 
 
	if (mode == 0) return(peaka);
	else
	if (mode == 1) return(degs);
}

double TriMA(double array[],int per,int bar)
{
   double sma[];
   int len = MathCeil((per+1)*0.5);
   ArrayResize(sma,len);
   
   for(int i = 0;i < len;i++) sma[i] = SMA(array,len,bar+i);
   double trima = SMA(sma,len,0);
   
   return(trima);
}

double SMA(double array[],int per,int bar)
{
   double Sum = 0;
   for(int i = 0;i < per;i++) Sum += array[i+bar];
  
   return(Sum/per);
}                	