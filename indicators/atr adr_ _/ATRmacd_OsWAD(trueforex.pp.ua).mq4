//+------------------------------------------------------------------+
//
// Bookkeeper: Осциллятор на основе индикатора:
//+------------------------------------------------------------------+
//|                                         Waddah_Attar_Def_RSI.mq4 |
//|                              Copyright © 2007, Eng. Waddah Attar |
//|                                          waddahattar@hotmail.com |
//+------------------------------------------------------------------+
//----
//mod atr

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1  Lime
#property  indicator_color2  Green
#property  indicator_color3  Maroon
#property  indicator_color4  Red

#property indicator_width1   2
#property indicator_width2   2
#property indicator_width3   2
#property indicator_width4   2

//----
extern int Period1=7;
extern int Period2=49;

extern int smzPeriod1=5;
extern int smzPeriod2=7;
extern int sigPeriod =3;
extern bool usesigma =0;
extern bool showbar =0;
extern double barlevel =0.005;

//extern bool showOsma=true;

double   up_buffer1[];
double   up_buffer2[];
double   dn_buffer1[];
double   dn_buffer2[];
double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   MABuffer1[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);
//----   
   SetIndexBuffer(0, up_buffer1);
   SetIndexBuffer(1, up_buffer2);
   SetIndexBuffer(2, dn_buffer1);
   SetIndexBuffer(3, dn_buffer2);
   SetIndexBuffer(4, ind_buffer1);
   SetIndexBuffer(5, MABuffer1);
   SetIndexBuffer(6, ind_buffer2);
   SetIndexBuffer(7, ind_buffer3);
//----   
//   string snm="macd";if (showOsma)snm="osma";
   
   IndicatorShortName("OsWAD ATR ("+Period1+","+Period2+") ");

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double RSI1,RSI2,Explo;

   int  limit, i, counted_bars = IndicatorCounted();
//----
   if(counted_bars < 0) 
       return(-1);
//----
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
//----
   for(i = limit; i >= 0; i--)
   {
     MABuffer1[i]   = iATR(NULL, 0, Period1, i);
     ind_buffer1[i] = iATR(NULL, 0, Period2, i);
   }
 
 
   for(i = 0; i <= limit; i++)
     ind_buffer2[i]= iMAOnArray(MABuffer1,0,smzPeriod1,0,MODE_SMA,i)- 
                     iMAOnArray(ind_buffer1,0,smzPeriod2,0,MODE_SMA,i);

   for(i = 0; i <= limit; i++)
     ind_buffer3[i]= iMAOnArray(ind_buffer2,0,sigPeriod,0,MODE_SMA,i); 
   
   
   
   for(i = 0; i <= limit; i++)
   {
//            double os = 0.0, os1 = 0.0;  
//                        if (showOsma)  {  os  =ind_buffer3[i]; 
//                                          os1 =ind_buffer3[i+1];
 //                                         }
                                          
      double  curr =ind_buffer2[i];
      double  prev =ind_buffer2[i+1];

      if (usesigma)  {  curr =ind_buffer3[i];
                        prev =ind_buffer3[i+1];
                        }

       if (!showbar) barlevel =curr;
   
     if(curr >0)
     {
        dn_buffer1[i]=0;
        dn_buffer2[i]=0;
        if(curr>prev)
        {
           up_buffer1[i]=barlevel;
           up_buffer2[i]=0;
        }
        else
        {
           up_buffer1[i]=0;
           up_buffer2[i]=barlevel;
        }
     }
     else
     {
        up_buffer1[i]=0;
        up_buffer2[i]=0;
        if(curr<prev)
        {
           dn_buffer1[i]=barlevel;
           dn_buffer2[i]=0;
        }
        else
        {
           dn_buffer1[i]=0;
           dn_buffer2[i]=barlevel;
        }
     }


   }
   return(0);
}
//+------------------------------------------------------------------+


