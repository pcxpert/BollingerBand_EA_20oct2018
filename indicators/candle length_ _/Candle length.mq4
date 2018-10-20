//+------------------------------------------------------------------+
//|                                                Candle length.mq4 |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_level1 0
#property indicator_levelcolor Gray
#property  indicator_buffers 2
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_width1  3
#property  indicator_width2  3

extern bool   CandleBodyOnly         = true;
extern bool   AboveBelowAxis         = true;
extern int    RefreshEveryXMins      = 1;

double     ind_buffer1[], ind_buffer2[];
datetime   prev_time;
string     sym;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()  {
//---- drawing settings
  ArrayInitialize(ind_buffer1,EMPTY_VALUE);
  SetIndexBuffer(0,ind_buffer1);
  SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);
  SetIndexDrawBegin(0,0);

  ArrayInitialize(ind_buffer2,EMPTY_VALUE);
  SetIndexBuffer(1,ind_buffer2);
  SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);
  SetIndexDrawBegin(1,0);

  IndicatorShortName("Candle length");

  if (RefreshEveryXMins > 240)                             RefreshEveryXMins = 240;
  if (RefreshEveryXMins > 60 && RefreshEveryXMins < 240)   RefreshEveryXMins = 60;
  if (RefreshEveryXMins > 30 && RefreshEveryXMins < 60)    RefreshEveryXMins = 30;
  if (RefreshEveryXMins > 15 && RefreshEveryXMins < 30)    RefreshEveryXMins = 15;
  if (RefreshEveryXMins > 5  && RefreshEveryXMins < 15)    RefreshEveryXMins = 5;
  if (RefreshEveryXMins > 1  && RefreshEveryXMins < 5)     RefreshEveryXMins = 1;
  
  sym = Symbol();
  prev_time = -9999;
  plot_ind();
  return(0);
}

//+------------------------------------------------------------------+
int deinit()  {
//+------------------------------------------------------------------+
  return(0);
}

//+------------------------------------------------------------------+
int start()  {
//+------------------------------------------------------------------+
  if (RefreshEveryXMins < 0)
    return(0);
  if (RefreshEveryXMins == 0) {
    plot_ind();    
  }
  else {
    if(prev_time != iTime(sym,RefreshEveryXMins,0))  {
      plot_ind();
      prev_time = iTime(sym,RefreshEveryXMins,0);
  } }      
  return(0);
}

//+------------------------------------------------------------------+
int plot_ind()   {
//+------------------------------------------------------------------+
  for(int i=0; i<=Bars; i++)  {
    if (CandleBodyOnly)
      double length = MathAbs(Open[i]-Close[i])/Point;
    else
      length = (High[i]-Low[i])/Point;
	   if (Open[i] < Close[i] || !AboveBelowAxis)
      ind_buffer1[i] = length;	
	   else
	     ind_buffer2[i] = -length;
  }
  return(0);
}


