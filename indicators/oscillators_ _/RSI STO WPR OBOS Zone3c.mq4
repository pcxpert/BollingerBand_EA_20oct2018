//+------------------------------------------------------------------+
//|                                    RSI_STO_WPR__OBOS_zones3c.mq4 |
//|               http://www.metaquotes.net http://www.forex-station.com |
//+------------------------------------------------------------------+
//2008fxtsd    ki 
//(obos zone - mladen's Laguerre v1.0)

#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property copyright  "www.forex-station.com; mladenfx@gmail.com"
#property link       "www.forex-station.com; mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 DeepSkyBlue
#property indicator_color2 ForestGreen
#property indicator_color3 YellowGreen
#property indicator_color4 Orange

#property indicator_maximum 105
#property indicator_minimum -5

//--- 

extern int RSI_Period = 21;
extern int RSI_Price  = 0;
extern bool Show_RSI  = true;  

extern int StoK_Period    = 14;
extern int StoD_Period    = 3;
extern int StoSl_Period   = 3;
extern int StoMA_method   = 0;
extern int StoPrice_field = 1;
extern bool Show_STO      = true;  


extern int   WPR_Period = 55; //wpr+100; overlay sto,rsi obos zones 20/80 
extern bool  Show_WPR   = true;  


extern double Level1        = 80; // zone- mladen's laguerre
extern double Level2        = 50; // if zero - no level(zone)
extern double Level3        = 20;
extern bool   ShowLevels    = true;  
extern color  Level1Color   = C'0,0,72';
extern color  Level2Color   = C'33,56,56';
extern color  Level3Color   = C'72,0,0';
extern bool   BeckGr        = true; 

extern string   note_Price = "0C,1O 2H3L,4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6";
extern string   MA_Method_ = "SMA0 EMA1 SMMA2 LWMA3";
extern string   Pricefield = "0Low/High  1Close/Close";
extern string   obos_zone_ = "wpr+100;  sto,rsi obos zones 20/80 overlay";

//---

double Buffer0[];
double Buffer1[];
double Buffer2[];
double Buffer3[];

string  ShortName;


//+---
int init()
  {

   int draw0 = 12; if (Show_RSI)draw0 = 0;
   int draw1 = 12; if (Show_STO)draw1 = 0;
   int draw3 = 12; if (Show_WPR)draw3 = 0;



   SetIndexBuffer(0, Buffer0);
   SetIndexStyle (0, draw0);

   SetIndexBuffer(1, Buffer1);
   SetIndexStyle (1, draw1);
 
   SetIndexBuffer(2, Buffer2);
   SetIndexStyle (2, draw1);

   SetIndexBuffer(3, Buffer3);
   SetIndexStyle (3, draw3);


   string rsi_str =" RSI("+RSI_Period+") ";  if (!Show_RSI)rsi_str ="";
   string wpr_str =" WPR("+WPR_Period+") ";  if (!Show_WPR)wpr_str ="";

   string sto_str =" STO("+StoK_Period+","+StoD_Period+","+StoSl_Period+") "; 
                                             if (!Show_STO)sto_str ="";



   ShortName =("OBOS Zone: "+rsi_str+" "+sto_str+" "+wpr_str+"");
   
   
      SetIndexLabel (0, rsi_str);
      SetIndexLabel (1, sto_str);
      SetIndexLabel (2, sto_str);
      SetIndexLabel (3, wpr_str);


   IndicatorShortName(ShortName);


   return(0);
  }


//+---

int deinit()
  {
   DeleteBounds();
   return(0);
  }


//+---

int start()
  {
 

   int i,limit,    CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   if (CountedBars>0) CountedBars--;

      limit= Bars-CountedBars;
      for (i=limit;i>=0;i--)

      {
   Buffer0[i] = iRSI(NULL, 0, RSI_Period, RSI_Price,i);
   Buffer1[i] = iStochastic(NULL,0,StoK_Period,StoD_Period,StoSl_Period,StoMA_method,StoPrice_field,MODE_MAIN,i);
   Buffer2[i] = iStochastic(NULL,0,StoK_Period,StoD_Period,StoSl_Period,StoMA_method,StoPrice_field,MODE_SIGNAL,i);
   Buffer3[i] = iWPR(NULL,0,WPR_Period,i)+100;
      }
     

   
   if (ShowLevels) UpdateBounds();

   return(0);
 }
//+---

//
//
//
//
//

void DeleteBounds()
{
   ObjectDelete(ShortName+"-1");
   ObjectDelete(ShortName+"-2");
   ObjectDelete(ShortName+"-3");
}
void UpdateBounds()
{
   if (Level1 > 0) SetUpBound(ShortName+"-1", 100        , Level1     , Level1Color);
   if (Level2 > 0) SetUpBound(ShortName+"-2", Level2*1.01, Level2*0.99, Level2Color);
   if (Level3 > 0) SetUpBound(ShortName+"-3", Level3     ,        0.00, Level3Color);
}
void SetUpBound(string name, double up, double down,color theColor)
{
   if (ObjectFind(name) == -1)
      {
         ObjectCreate(name,OBJ_RECTANGLE,WindowFind(ShortName),0,0);
         ObjectSet(name,OBJPROP_PRICE1,up);
         ObjectSet(name,OBJPROP_PRICE2,down);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_BACK,BeckGr);
         ObjectSet(name,OBJPROP_TIME1,iTime(NULL,0,Bars-1));
      }
   if (ObjectGet(name,OBJPROP_TIME2) != iTime(NULL,0,0))
       ObjectSet(name,OBJPROP_TIME2,    iTime(NULL,0,0));
}