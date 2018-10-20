#property copyright "Masakazu Corp., remix Kilian19@FF, remix by Scriptong"
#property link      "http://advancetools.net"
#property version "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 3 
#property indicator_color1 clrRed 
#property indicator_color2 clrGreen 
#property indicator_color3 clrDodgerBlue
#property indicator_width1 1 
#property indicator_width2 1 
#property indicator_width3 2 

enum ENUM_YESNO
{
   NO,                                                                                             // No / Нет
   YES                                                                                             // Yes / Да
};

// Input parameters of indicator
input int                      i_dev_period          = 5;                                          // RSI period / Период RSI
input int                      i_maPeriod            = 13;                                         // MA period / Период МА
input ENUM_MA_METHOD           i_maMethod            = MODE_EMA;                                   // MA calculation method / Метод расчета МА
input double                   i_maRatio             = 1.0;                                        // MA ratio / Коэффициент умножения МА
input ENUM_YESNO               i_useAlert            = YES;                                        // Use alert? / Использовать оповещения?
input int                      i_indBarsCount        = 10000;                                      // The number of bars to display / Количество баров отображения

// The indicator's buffers
double            g_sellBuffer[];
double            g_buyBuffer[];
double            g_maBuffer[];

// Other global variables of indicator
bool              g_activate;                                                                      // Sign of successful initialization of indicator
double            g_maSourceValues[];                                                              

     
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   g_activate = false;                                                                             
   
   if (!IsTuningParametersCorrect())                                                               
      return INIT_FAILED;                                 
      
   iTime(NULL, PERIOD_D1, 0);   

   if (!BuffersBind())                             
      return (INIT_FAILED);                                 
      
   g_activate = true;                                                                              
   return INIT_SUCCEEDED;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of input parameters                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
{
   string name = WindowExpertName();
   
   bool isRussianLang = (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian");

   if (i_dev_period < 1)
   {
      Alert(name, (isRussianLang)? ": период RSI должен быть 1 и более. Индикатор отключен." :
                                   ": the RSI period must be 1 or more. The indicator is turned off.");
      return false;
   }

   if (i_maPeriod < 1)
   {
      Alert(name, (isRussianLang)? ": период MA должен быть 1 и более. Индикатор отключен." :
                                   ": the MA period must be 1 or more. The indicator is turned off.");
      return false;
   }
   
   if (i_maRatio <= 0.0)
   {
      Alert(name, (isRussianLang)? ": коэффициент умножения MA должен быть положительным. Индикатор отключен." :
                                   ": the MA ratio must have a positive value. The indicator is turned off.");
      return false;
   }

   if (ArrayResize(g_maSourceValues, i_maPeriod) < 0)
   {
      Alert(name, (isRussianLang)? ": не удалось распределить память для массива исходных значений MA. Индикатор отключен." :
                                   ": unable to allocate the memory for array of source MA values. The indicator is turned off.");
      return false;
   }

   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int& total, const int ratesTotal, const int prevCalculated)
{
   total = ratesTotal - 1;                                                                         
                                                   
   if (i_indBarsCount > 0 && i_indBarsCount < total)
      total = MathMin(i_indBarsCount, total);                      
                                                   
   if (prevCalculated < ratesTotal - 1)                     
   {       
      InitializeBuffers();
      return (total);
   }
   
   return (MathMin(ratesTotal - prevCalculated, total));                            
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Initialize of all indicator buffers                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void InitializeBuffers()
{
   ArrayInitialize(g_sellBuffer, EMPTY_VALUE);
   ArrayInitialize(g_buyBuffer, EMPTY_VALUE);
   ArrayInitialize(g_maBuffer, EMPTY_VALUE);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Binding the indicator buffers with arrays                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool BuffersBind()
{
   string name = WindowExpertName();
   bool isRussianLang = (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian");

   if (!SetIndexBuffer(0, g_sellBuffer)       ||
       !SetIndexBuffer(1, g_buyBuffer)        ||
       !SetIndexBuffer(2, g_maBuffer))
   {
      Alert(name, (isRussianLang)? ": ошибка связывания массивов с буферами индикатора. Ошибка №" + IntegerToString(GetLastError()) :
                                   ": error of binding of the arrays and the indicator buffers. Error N" + IntegerToString(GetLastError()));
      return false;
   }
   
   for (int i = 0; i < 3; i++)
      SetIndexStyle(i, DRAW_LINE);
      
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculate main buffers values                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CalculateBuyAndSellBuffers(int barIndex, int total)
{
   double curHigh = 0.0, curLow = 0.0;
   double bullPower = 0.0, bearPower = 0.0;
   for (int i = 0; i < i_dev_period; i++)    
   { 
      int shift = i + barIndex;  
      double rsi = iRSI(NULL, 0, i_dev_period, PRICE_CLOSE, shift); 
      double high = iHigh(NULL, 0, shift); 
      double low = iLow(NULL, 0, shift); 
      double power = rsi * iClose(NULL, 0, shift);                 

      if (high > curHigh) 
      { 
         curHigh = high; 
         bullPower += power; 
      } 
      
      if (low < curLow || curLow == 0.0) 
      { 
         curLow = low; 
         bearPower += power; 
      }               
   } 
   
   if (bullPower != 0.0)
      g_sellBuffer[barIndex] = bearPower / bullPower; 
   
   if (bearPower != 0.0)
      g_buyBuffer[barIndex] = bullPower / bearPower;   
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculate MA buffer                                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CalculateMA(int barIndex, int total)
{
   if (total - barIndex < i_maPeriod)
      return;
      
   int lastIndex = barIndex + i_maPeriod;
   for (int i = barIndex; i < lastIndex; i++)
      g_maSourceValues[i - barIndex] = MathMax(g_sellBuffer[i], g_buyBuffer[i]);
      
   g_maBuffer[barIndex] = iMAOnArray(g_maSourceValues, 0, i_maPeriod, 0, i_maMethod, 0) * i_maRatio;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Produces the sound if Kiosotto value greater than value of MA                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DoAlert()
{
   if (i_useAlert == NO)
      return;

   static datetime lastAlert = 0;
   if (lastAlert == iTime(NULL, 0, 0))
      return;
      
   lastAlert = iTime(NULL, 0, 0);
   string name = WindowExpertName();
   bool isRussianLang = (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian");

   if (g_maBuffer[1] < g_buyBuffer[1])
      Alert(name, (isRussianLang)? ": значение Buy больше средней величины." :
                                   ": the Buy value greater than average value.");
   if (g_maBuffer[1] < g_sellBuffer[1])
      Alert(name, (isRussianLang)? ": значение Sell больше средней величины." :
                                   ": the Sell value greater than average value.");
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Displaying of indicators values                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit, int total)
{
   for (int i = limit; i > 0; i--)
   {
      CalculateBuyAndSellBuffers(i, total);
      CalculateMA(i, total);         
   }

   DoAlert();   
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (!g_activate)                                                                                
      return prev_calculated;  
      
   int total;   
   int limit = GetRecalcIndex(total, rates_total, prev_calculated);                                

   ShowIndicatorData(limit, total);                                                                
   
   return rates_total;
}
