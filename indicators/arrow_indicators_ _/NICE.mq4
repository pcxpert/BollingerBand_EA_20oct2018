#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 MediumSpringGreen
#property indicator_color4 Fuchsia
#property indicator_color5 Black
#property indicator_color6 Black
#property indicator_width3 3
#property indicator_width4 3
int Gi_period_76 = 20;
int Gi_80 = 2;
double gd_84 = 1.0;
int Gi_92 = 1;
int Gi_96 = 1;
int G_shift_100 = 1000;
double G_ibuf_104[];
double G_ibuf_108[];
double G_ibuf_112[];
double G_ibuf_116[];
double G_ibuf_120[];
double G_ibuf_124[];
extern bool SoundON = TRUE;
bool Gi_132 = TRUE;
bool Gi_136 = TRUE;
datetime G_time_140;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexBuffer(0, G_ibuf_104);
   SetIndexBuffer(1, G_ibuf_108);
   SetIndexBuffer(2, G_ibuf_112);
   SetIndexBuffer(3, G_ibuf_116);
   SetIndexBuffer(4, G_ibuf_120);
   SetIndexBuffer(5, G_ibuf_124);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexArrow(0, 32);
   SetIndexArrow(1, 32);
   SetIndexArrow(2, SYMBOL_ARROWUP);
   SetIndexArrow(3, SYMBOL_ARROWDOWN);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   string ls_0 = "BuySell Entry";
   IndicatorShortName(ls_0);
   SetIndexLabel(0, "UpTrend Stop");
   SetIndexLabel(1, "DownTrend Stop");
   SetIndexLabel(2, "UpTrend Signal");
   SetIndexLabel(3, "DownTrend Signal");
   SetIndexLabel(4, "UpTrend Line");
   SetIndexLabel(5, "DownTrend Line");
   SetIndexDrawBegin(0, Gi_period_76);
   SetIndexDrawBegin(1, Gi_period_76);
   SetIndexDrawBegin(2, Gi_period_76);
   SetIndexDrawBegin(3, Gi_period_76);
   SetIndexDrawBegin(4, Gi_period_76);
   SetIndexDrawBegin(5, Gi_period_76);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int li_0;
   double lda_4 [2500];
   double lda_8 [2500];
   double lda_12[2500];
   double lda_16[2500];
   if (G_ibuf_112[1] != -1.0 && G_time_140 != Time[0]) {
      Alert("Buy Signal symbol : ", Symbol(), "  Period: ", Period());
      G_time_140 = Time[0];
   }
   if (G_ibuf_116[1] != -1.0 && G_time_140 != Time[0]) {
      Alert("Sell Signal Symbol : ", Symbol(), "  Period: ", Period());
      G_time_140 = Time[0];
   }
   for (int shift_20 = G_shift_100; shift_20 >= 0; shift_20--) {
      G_ibuf_104[shift_20] = 0;
      G_ibuf_108[shift_20] = 0;
      G_ibuf_112[shift_20] = 0;
      G_ibuf_116[shift_20] = 0;
      G_ibuf_120[shift_20] = EMPTY_VALUE;
      G_ibuf_124[shift_20] = EMPTY_VALUE;
   }
   for (shift_20 = G_shift_100 - Gi_period_76 - 1; shift_20 >= 0; shift_20--) {
      lda_4[shift_20] = iBands(NULL, 0, Gi_period_76, Gi_80, 0, PRICE_HIGH, MODE_UPPER, shift_20);
      lda_8[shift_20] = iBands(NULL, 0, Gi_period_76, Gi_80, 0, PRICE_LOW, MODE_LOWER, shift_20);
      if (Close[shift_20] > lda_4[shift_20 + 1]) li_0 = 1;
      if (Close[shift_20] < lda_8[shift_20 + 1]) li_0 = -1;
      if (li_0 > 0 && lda_8[shift_20] < lda_8[shift_20 + 1]) lda_8[shift_20] = lda_8[shift_20 + 1];
      if (li_0 < 0 && lda_4[shift_20] > lda_4[shift_20 + 1]) lda_4[shift_20] = lda_4[shift_20 + 1];
      lda_12[shift_20] = lda_4[shift_20] + (gd_84 - 1.0) / 2.0 * (lda_4[shift_20] - lda_8[shift_20]);
      lda_16[shift_20] = lda_8[shift_20] - (gd_84 - 1.0) / 2.0 * (lda_4[shift_20] - lda_8[shift_20]);
      if (li_0 > 0 && lda_16[shift_20] < lda_16[shift_20 + 1]) lda_16[shift_20] = lda_16[shift_20 + 1];
      if (li_0 < 0 && lda_12[shift_20] > lda_12[shift_20 + 1]) lda_12[shift_20] = lda_12[shift_20 + 1];
      if (li_0 > 0) {
         if (Gi_92 > 0 && G_ibuf_104[shift_20 + 1] == -1.0) {
            G_ibuf_112[shift_20] = lda_16[shift_20];
            G_ibuf_104[shift_20] = lda_16[shift_20];
            if (Gi_96 > 0) G_ibuf_120[shift_20] = lda_16[shift_20];
            if (SoundON == TRUE && shift_20 == 0 && (!Gi_132)) {
               Alert("Buy Alert ", Symbol(), "-", Period());
               Gi_132 = TRUE;
               Gi_136 = FALSE;
            }
         } else {
            G_ibuf_104[shift_20] = lda_16[shift_20];
            if (Gi_96 > 0) G_ibuf_120[shift_20] = lda_16[shift_20];
            G_ibuf_112[shift_20] = -1;
         }
         if (Gi_92 == 2) G_ibuf_104[shift_20] = 0;
         G_ibuf_116[shift_20] = -1;
         G_ibuf_108[shift_20] = -1.0;
         G_ibuf_124[shift_20] = EMPTY_VALUE;
      }
      if (li_0 < 0) {
         if (Gi_92 > 0 && G_ibuf_108[shift_20 + 1] == -1.0) {
            G_ibuf_116[shift_20] = lda_12[shift_20];
            G_ibuf_108[shift_20] = lda_12[shift_20];
            if (Gi_96 > 0) G_ibuf_124[shift_20] = lda_12[shift_20];
            if (SoundON == TRUE && shift_20 == 0 && (!Gi_136)) {
               Alert("Sell Alert ", Symbol(), "-", Period());
               Gi_136 = TRUE;
               Gi_132 = FALSE;
            }
         } else {
            G_ibuf_108[shift_20] = lda_12[shift_20];
            if (Gi_96 > 0) G_ibuf_124[shift_20] = lda_12[shift_20];
            G_ibuf_116[shift_20] = -1;
         }
         if (Gi_92 == 2) G_ibuf_108[shift_20] = 0;
         G_ibuf_112[shift_20] = -1;
         G_ibuf_104[shift_20] = -1.0;
         G_ibuf_120[shift_20] = EMPTY_VALUE;
      }
   }
   return (0);
}