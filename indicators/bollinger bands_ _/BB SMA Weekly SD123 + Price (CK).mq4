#property link      "wiedstone@yahoo.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Magenta
#property indicator_color2 Magenta
#property indicator_color3 Magenta
#property indicator_color4 Magenta
#property indicator_color5 Magenta
#property indicator_color6 Magenta
#property indicator_color7 Magenta

       int periode            = 20;
       int BandsShift         = 0;
       double BandsDeviations = 1.0;
extern int MA_Mode            = MODE_SMA;
extern int Applied_Price      = PRICE_WEIGHTED;
extern bool Show_SD1          = true;
extern bool Show_SD2          = true;
extern bool Show_SD3          = true;
extern bool Show_Price        = false;

double indexbuffer_0[];
double indexbuffer_1[];
double indexbuffer_2[];
double indexbuffer_3[];
double indexbuffer_4[];
double indexbuffer_5[];
double indexbuffer_6[];

int init() {
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexBuffer(0, indexbuffer_0);
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(1, indexbuffer_1);
   SetIndexStyle(2, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(2, indexbuffer_2);
   SetIndexStyle(3, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(3, indexbuffer_3);
   SetIndexStyle(4, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(4, indexbuffer_4);
   SetIndexStyle(5, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(5, indexbuffer_5);
   SetIndexStyle(6, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(6, indexbuffer_6);
   getPeriod();
   return (0);
}
int deinit()
  {
//----
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringFind(label, "W1", 0) < 0)
           continue;
       ObjectDelete(label);
     }   
//----
   return(0);
  }

int start() {
   int candle;
   double SD1;
   double SD2;
   double SD3;
   double poin;
   double angka_MA;
   double setelah_shift;
   int bar_hitung = IndicatorCounted();
   if (Bars <= periode) return (0);
   if (bar_hitung < 1) {
      for (int geser = 1; geser <= periode; geser++) {
         indexbuffer_0[Bars - geser] = EMPTY_VALUE;
         indexbuffer_1[Bars - geser] = EMPTY_VALUE;
         indexbuffer_2[Bars - geser] = EMPTY_VALUE;
      }
   }
   int jml_bars = Bars - bar_hitung;
   if (bar_hitung > 0) jml_bars++;
   for (geser = 0; geser < jml_bars; geser++) 
       { 
         indexbuffer_0[geser] = iMA(NULL, 0, periode, BandsShift, MA_Mode, Applied_Price, geser);
         if(Show_Price)SetPrice("W1 Mid prc", Time[0], indexbuffer_0[0], indicator_color1);
                       SetText("W1 Mid txt", " ", Time[0], indexbuffer_0[0], indicator_color1);
       }
   geser = Bars - periode + 1;
   if (bar_hitung > periode - 1) geser = Bars - bar_hitung - 1;
   while (geser >= 0) {
      poin = 0.0;
      candle = geser + periode - 1;
      angka_MA = indexbuffer_0[geser];
      while (candle >= geser) {
         setelah_shift = Close[candle] - angka_MA;
         poin += setelah_shift * setelah_shift;
         candle--;
      }
      SD1 = 1.0 * MathSqrt(poin / periode);
      SD2 = 2.0 * MathSqrt(poin / periode);
      SD3 = 3.0 * MathSqrt(poin / periode);
      
      if(Show_SD1) {
                    indexbuffer_1[geser] = angka_MA + SD1;
                    indexbuffer_2[geser] = angka_MA - SD1;
                    if(Show_Price)SetPrice("W1 SD+1 prc", Time[0], indexbuffer_1[0], indicator_color4);
                                  SetText("W1 SD+1 txt", "        +1", Time[0], indexbuffer_1[0], indicator_color1);
                    if(Show_Price)SetPrice("W1 SD-1 prc", Time[0], indexbuffer_2[0], indicator_color4);
                                  SetText("W1 SD-1 txt", "        -1", Time[0], indexbuffer_2[0], indicator_color1);                   
                   }
      if(Show_SD2) {
                    indexbuffer_3[geser] = angka_MA + SD2;
                    indexbuffer_4[geser] = angka_MA - SD2;
                    if(Show_Price)SetPrice("W1 SD+2 prc", Time[0], indexbuffer_3[0], indicator_color4);
                                  SetText("W1 SD+2 txt", "        +2", Time[0], indexbuffer_3[0], indicator_color1);
                    if(Show_Price)SetPrice("W1 SD-2 prc", Time[0], indexbuffer_4[0], indicator_color4);
                                  SetText("W1 SD-2 txt", "        -2", Time[0], indexbuffer_4[0], indicator_color1);                   
                  }
      if(Show_SD3) {
                    indexbuffer_5[geser] = angka_MA + SD3;
                    indexbuffer_6[geser] = angka_MA - SD3;
                    if(Show_Price)SetPrice("W1 SD+3 prc", Time[0], indexbuffer_5[0], indicator_color4);
                                  SetText("W1 SD+3 txt", "        +3", Time[0], indexbuffer_5[0], indicator_color1);
                    if(Show_Price)SetPrice("W1 SD-3 prc", Time[0], indexbuffer_6[0], indicator_color4);
                                  SetText("W1 SD-3 txt", "        -3", Time[0], indexbuffer_6[0], indicator_color1);                   
                   }
      geser--;
   }
   return (0);
}
void SetPrice(string name, int datetime_0, double price_0, color color_0) {
   if (ObjectFind(name) == -1) {
      ObjectCreate(name, OBJ_ARROW, 0, datetime_0, price_0);
      ObjectSet(name, OBJPROP_COLOR, color_0);
      ObjectSet(name, OBJPROP_WIDTH, 1);
      ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
      return;
   }
   ObjectSet(name, OBJPROP_TIME1, datetime_0);
   ObjectSet(name, OBJPROP_PRICE1, price_0);
   ObjectSet(name, OBJPROP_COLOR, color_0);
   ObjectSet(name, OBJPROP_WIDTH, 1);
   ObjectSet(name, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
}

void SetText(string name, string text, int datetime_1, double price_1, color color_1) {
   if (ObjectFind(name) == -1) {
      ObjectCreate(name, OBJ_TEXT, 0, datetime_1, price_1);
      ObjectSetText(name, text, 6, " Tahoma", color_1);
      return;
   }
   ObjectSet(name, OBJPROP_TIME1, datetime_1);
   ObjectSet(name, OBJPROP_PRICE1, price_1);
   ObjectSetText(name, text, 6, "Tahoma", color_1);
}
void getPeriod() {
   switch (Period()) {
   case PERIOD_M1:
      periode = 0;
      return;
   case PERIOD_M5:
      periode = 1440;
      return;
   case PERIOD_M15:
      periode = 480;
      return;
   case PERIOD_M30:
      periode = 240;
      return;
   case PERIOD_H1:
      periode = 120;
      return;
   case PERIOD_H4:
      periode = 30;
      return;
   case PERIOD_D1:
      periode = 5;
      return;
   case PERIOD_W1:
      periode = 0;
      return;
   case PERIOD_MN1:
      periode = 0;
      return;
   }
}