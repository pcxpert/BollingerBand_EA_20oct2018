
#property copyright "Copyright � 2004, by konKop, GOODMAN, Mstera, af + wellx; 2006 mbkennel"
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 Fuchsia

extern int periodAMA = 6;
extern int nfast = 2;
extern int nslow = 60;
extern double G = 2.5;
extern double EMAofKaufPeriod = 16.0;
extern int offset = 1;
double gda_108[];
double gda_112[];
int gi_116 = 0;
double gd_120;
double gd_128;

int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, gda_108);
   SetIndexBuffer(1, gda_112);
   IndicatorDigits(6);
   gi_116 = IndicatorCounted();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double ld_8;
   double ld_24;
   double ld_40;
   double ld_48;
   double ld_56;
   double ld_64;
   double ld_72;
   int li_4 = 0;
   gd_120 = 2.0 / (nslow + 1);
   gd_128 = 2.0 / (nfast + 1);
   if (Bars <= periodAMA + 2) return (0);
   if (gi_116 < 0) return (-1);
   if (gi_116 > 0) gi_116--;
   li_4 = Bars - periodAMA - 2;
   double ld_32 = Close[li_4 + 1];
   while (li_4 >= offset) {
      if (li_4 == Bars - periodAMA - 2) ld_32 = Close[li_4 + 1];
      ld_40 = MathAbs(Close[li_4] - (Close[li_4 + periodAMA]));
      ld_8 = 0;
      for (int li_0 = 0; li_0 < periodAMA; li_0++) ld_8 += MathAbs(Close[li_4 + li_0] - (Close[li_4 + li_0 + 1]));
      if (ld_8 != 0.0) ld_48 = ld_40 / ld_8;
      ld_56 = gd_128 - gd_120;
      ld_64 = ld_48 * ld_56;
      ld_72 = ld_64 + gd_120;
      ld_24 = ld_32 + MathPow(ld_72, G) * (Close[li_4] - ld_32);
      gda_108[li_4 - offset] = ld_24;
      ld_32 = ld_24;
      li_4--;
   }
   li_4 = Bars - periodAMA - 2;
   f0_0(li_4 - 1, 2.0 / (EMAofKaufPeriod + 1.0), gda_108, gda_112, offset);
   return (0);
}

void f0_0(int ai_0, double ad_4, double ada_12[], double &ada_16[], int ai_20) {
   double ld_44;
   double ld_24 = 1.0 - ad_4;
   double ld_32 = ada_12[ai_0 - 1];
   for (int li_40 = ai_0 - 1; li_40 >= ai_20; li_40--) {
      ld_44 = ada_12[li_40];
      ld_32 = ad_4 * ld_44 + ld_24 * ld_32;
      ada_16[li_40 - ai_20] = ld_32;
   }
}
