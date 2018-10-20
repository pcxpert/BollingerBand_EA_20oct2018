//+------------------------------------------------------------------+
//|                                           CandleWicksDisplay.mq4 |
//|                                  Copyright © 2011, Andriy Moraru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andriy Moraru"
#property link      "http://www.earnforex.com"

/*
   Alerts you when the candle's wick (shadow) reaches a certain length.
   Your e-mail settings are set in Tools -> Options -> Email.
   Also displays the candle wicks' length above and below the candles.
*/

// The indicator uses only objects for display, but the line below is required for it to work.

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
 #property indicator_color2 Red



extern int DisplayWickLimit = 5; // In standard pips
extern color DisplayHighWickColor = Red;
extern color DisplayLowWickColor = LimeGreen;
extern int DisplayWickDistance = 10; // Distance from High to Pip Count
extern int UpperWickLimit = 10; // In broker pips
extern int LowerWickLimit = 10; // In broker pips
extern bool WaitForClose = true; // Wait for a candle to close before checking wicks' length
extern bool EmailAlert = true;
extern bool SoundAlert = false;
extern bool VisualAlert = false;
extern int TopBottomPercent = 0; // if > 0 and <= 100, displays length only for bars where Open & Close within top or bottom % of candle
input int ArrowSize = 1;
input int ArrowDistance = 6;
// //---- buffers
double DwnBuffer[];
double UpBuffer[];

input bool DrawVlines        = FALSE;
string ID ="FXPTeng_";

// Time of the bar of the last alert
datetime AlertDone;

double Poin;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void){



if (Point == 0.00001) Poin = 0.0001; 
else if (Point == 0.001) Poin = 0.01; 
else Poin = Point;    
   
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DwnBuffer);
   SetIndexDrawBegin(0,0); 
  SetIndexDrawBegin(1,0); 
   
  //  SetIndexEmptyValue(0,0.0);
//    SetIndexEmptyValue(1,0.0);

//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   for (int i = 0; i < Bars; i++)
   {
      ObjectDelete("Red-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES));
      ObjectDelete("Green-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES));
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{

   string name, length;
   bool DoAlert = false;
   int index = 0;
   
   if (WaitForClose) index = 1;
   
   int counted_bars = IndicatorCounted();
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
//    if (limit > 500) limit = 500;
     
   for (int i = 0; i <= limit; i++){
     if ((TopBottomPercent > 0) && (TopBottomPercent <= 100)){
      
         double percent = (High[i] - Low[i]) * TopBottomPercent / 100;
         if (!(((Open[i] >= High[i] - percent) && (Close[i] >= High[i] - percent)) ||
             ((Open[i] <= Low[i] + percent) && (Close[i] <= Low[i] + percent)))) continue;
      }
      
      if (Open[i] <= Close[i]){  
         if (High[i] - Close[i] >= DisplayWickLimit * Poin){ // Upper wick length display
            name = "Red-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
            length = DoubleToStr(MathRound((High[i] - Close[i]) / Poin), 0);
            DwnBuffer[i]=length;
            //DwnBuffer[i]=High[i]+((DisplayWickDistance+ArrowDistance)*Poin);;
    
           if (ObjectFind(name) != -1) ObjectDelete(name);
            ObjectCreate(name, OBJ_TEXT, 0, Time[i], High[i] + DisplayWickDistance * Poin);
            ObjectSetText(name, length, 10, "Verdana", DisplayHighWickColor);
            
         }
         if (Open[i] - Low[i] >= DisplayWickLimit * Poin){// Lower wick length display
            name = "Green-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
            length = DoubleToStr(MathRound((Open[i] - Low[i]) / Poin), 0);
          UpBuffer[i]=length;
//           UpBuffer[i]=Low[i] - ((DisplayWickDistance+ArrowDistance)*Poin);;

            if (ObjectFind(name) != -1) ObjectDelete(name);
            ObjectCreate(name, OBJ_TEXT, 0, Time[i], Low[i]);
            ObjectSetText(name, length, 10, "Verdana", DisplayLowWickColor);
         }
      }
      
      
      else{
         if (High[i] - Open[i] >= DisplayWickLimit * Poin){ // Upper wick length display        
            name = "Red-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
            length = DoubleToStr(MathRound((High[i] - Open[i]) / Poin), 0);
            DwnBuffer[i]=length;
//             DwnBuffer[i]=High[i]+((DisplayWickDistance+ArrowDistance)*Poin);;
            
                        
            if (ObjectFind(name) != -1) ObjectDelete(name);
            ObjectCreate(name, OBJ_TEXT, 0, Time[i], High[i] + DisplayWickDistance * Poin);
            ObjectSetText(name, length, 10, "Verdana", DisplayHighWickColor);
         }
         if (Close[i] - Low[i] >= DisplayWickLimit * Poin){ // Lower wick length display
            name = "Green-" + TimeToStr(Time[i], TIME_DATE|TIME_MINUTES);
            length = DoubleToStr(MathRound((Close[i] - Low[i]) / Poin), 0);
           UpBuffer[i]=length;
//            UpBuffer[i]=Low[i]-((DisplayWickDistance+ArrowDistance)*Poin);;
           
           if (ObjectFind(name) != -1) ObjectDelete(name);
            ObjectCreate(name, OBJ_TEXT, 0, Time[i], Low[i]);
            ObjectSetText(name, length, 10, "Verdana", DisplayLowWickColor);
         }
   }
   }
   
   if (AlertDone == Time[index]) return(0); // Already sent an alert for this candle
   
   if (Close[index] >= Open[index]) // Bullish candle
   {
      if ((High[index] - Close[index] >= UpperWickLimit * Point) || (Open[index] - Low[index] >= LowerWickLimit * Point)) DoAlert = true;
   }
   else // Bearish candle
   {
      if ((High[index] - Open[index] >= UpperWickLimit * Point) || (Close[index] - Low[index] >= LowerWickLimit * Point)) DoAlert = true;
   }
   
   if (DoAlert)
   {
      datetime tc = TimeCurrent();
      string time = TimeYear(tc) + "-" + TimeMonth(tc) + "-" + TimeDay(tc) + " " + TimeHour(tc) + ":" + TimeMinute(tc);
      if (VisualAlert) Alert(Symbol() + " " + time + " - wick limit reached!");
      if (SoundAlert) PlaySound("alert.wav");
      if (EmailAlert) SendMail("CandleWick Alert", Symbol() + " " + time + " - wick limit reached!");
      AlertDone = Time[index];
   }
      
   return(0);
}
//+------------------------------------------------------------------+
//                                                                   +
//+------------------------------------------------------------------+
void DrawLine(int BarCnt, color LineClr){

string  TimeNow=TimeToStr(Time[BarCnt],TIME_DATE|TIME_MINUTES);

string sObjName=ID+"vline"+TimeNow;
ObjectCreate(sObjName,OBJ_VLINE,0,Time[BarCnt],0);
ObjectSet(sObjName,OBJPROP_WIDTH,1);
 ObjectSet(sObjName,OBJPROP_STYLE,STYLE_DOT);
 ObjectSet(sObjName,OBJPROP_BACK,FALSE);
 ObjectSet(sObjName,OBJPROP_COLOR, LineClr);
// CheckStats(thisi);

return;

}
//+------------------------------------------------------------------+
