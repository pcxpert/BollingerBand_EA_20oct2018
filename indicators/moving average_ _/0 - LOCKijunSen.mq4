//+---------------------------------------------------------------------+
//|                                                  LOC-KijunSen.mq4    |
//| For more EXPERTS, INDICATORS, TRAILING EAs and SUPPORT Please visit:|
//|                                      http://www.landofcash.net      |
//|           Our forum is at:   http://forex-forum.landofcash.net      |
//+---------------------------------------------------------------------+
#property copyright "Mikhail"
#property link      "http://www.landofcash.net"

#property indicator_chart_window
#property indicator_buffers 1
//Line
#property indicator_color1 OrangeRed 
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID


string _name = "LOC-RKijunSen";
string _ver="v1.1";
//---------------------------------------------
//indicator parameters
extern int _period=26;

//---------------------------------------------
double _line[];
double _pipsMultiplyer=1;

int init()
{
   Print(_name+" - " + _ver);
   IndicatorShortName(_name+" - " + _ver);
   Comment(_name+" " + _ver+" @ "+"http://www.landofcash.net");
//init buffers
   IndicatorBuffers(1);    
   SetIndexBuffer(0,_line);

//set draw style   
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexLabel(0,"RKijunSen");

   //get pip value
   if(Digits == 2 || Digits == 4) {
      _pipsMultiplyer = 1;
   } else {
      if(Digits == 3 || Digits == 5) {
         _pipsMultiplyer = 10;
      }
   }
   return(0);
}

int deinit()
{
   return(0);
}

int start()
  {
   int    counted_bars=IndicatorCounted();
   if(Bars<=_period) {return(0);}
   int i=Bars-counted_bars-1;
   while(i>=0)
   {
      double minMax=iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,_period,i));
      double maxMin=iLow(Symbol(),Period(),iLowest(Symbol(),Period(),MODE_LOW,_period,i));
       _line[i]=(minMax+maxMin)/2;

      i--;
   }
   return(0);
  }

