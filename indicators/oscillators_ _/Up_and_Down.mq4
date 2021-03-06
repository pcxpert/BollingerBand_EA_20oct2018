//+------------+-----------------------------------------------------+
//| v.22.04.05 |                                     up and Down.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_style1 STYLE_SOLID
#property indicator_color1 Yellow

#property indicator_level1 0
//#property indicator_level2 -2
//#property indicator_level3 2
//#property indicator_level4 -1
//#property indicator_level5 1
#property indicator_minimum -3
#property indicator_maximum 3
#define PREFIX "xxx"

extern int    period          = 18;
extern bool   Arrow           = true;
extern int    ArrowSize       = 1;
extern int    SIGNAL_BAR      = 1;
extern color  clArrowBuy      = Blue;
extern color  clArrowSell     = Red; 

double      ExtBuffer0[];
// -------------------------------------------------------------------------------------------------------------
int init()
  {
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,ExtBuffer0);
    IndicatorShortName("Up and Down");
    return(0);
  }
// -------------------------------------------------------------------------------------------------------------
int deinit()                            
  {                                           
    for (int i = ObjectsTotal()-1; i >= 0; i--)   
    if (StringSubstr(ObjectName(i), 0, StringLen(PREFIX)) == PREFIX)
       ObjectDelete(ObjectName(i));
    return(0);  
  }
// -------------------------------------------------------------------------------------------------------------
int start()
  {
    int limit;
    int counted_bars;
    //double prev, current, old;
    double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
    double price;
    double MinL=0;
    double MaxH=0;
   
    counted_bars = IndicatorCounted();
    if ( counted_bars > 0 ) counted_bars--;
    limit = Bars - counted_bars;

    for(int i=0; i<limit; i++)
      {
        MaxH = High[iHighest(NULL,0,MODE_CLOSE,period,i)];                       
        MinL = Low[iLowest(NULL,0,MODE_CLOSE,period,i)];                          
        price = (Open[i]+ Close[i])/2;                                             

        if(MaxH-MinL == 0) Value = 0.33*2*(0-0.5) + 0.67*Value1;
        else Value = 0.33*2*((price-MaxH)/(MinL-MaxH)-0.5) + 0.67*Value1;

        Value=MathMin(MathMax(Value,-0.999),0.999);
 
        if(1-Value == 0) ExtBuffer0[i]=0.5+0.5*Fish1;
        else ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;

        Value1=Value;
        Fish1=ExtBuffer0[i];
      }
    int counted_bars2 = IndicatorCounted();
    if ( counted_bars2 > 0 ) counted_bars2--;
    int limit2 = Bars - counted_bars2;
    for ( int j = limit2; j >= 0; j-- )
      {
        if ( Arrow )
          {
            if ( ExtBuffer0[j+SIGNAL_BAR+1] > 0.0  && ExtBuffer0[j+SIGNAL_BAR] < 0.0 ) manageArr(j+1, clArrowBuy,  233, false);
            if ( ExtBuffer0[j+SIGNAL_BAR+1] < 0.0  && ExtBuffer0[j+SIGNAL_BAR] > 0.0 ) manageArr(j+1, clArrowSell, 234, true );
          }
      }
    return(0);
  }
// -------------------------------------------------------------------------------------------------------------
void manageArr(int j, color clr, int theCode, bool up)   
  {
    string objName = PREFIX + Time[j];
    double gap  = 3.0*iATR(NULL,0,20,j)/4.0;
    
    ObjectCreate(objName, OBJ_ARROW,0,Time[j],0);
    ObjectSet   (objName, OBJPROP_COLOR, clr);  
    ObjectSet   (objName, OBJPROP_ARROWCODE,theCode);
    ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);  
    if ( up )
      ObjectSet(objName,OBJPROP_PRICE1,Open[j]+gap);
    else  
      ObjectSet(objName,OBJPROP_PRICE1,Close[j] -gap);
  }
// -------------------------------------------------------------------------------------------------------------

