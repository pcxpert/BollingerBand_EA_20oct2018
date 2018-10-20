//+------------------------------------------------------------------+
//|                                                Kalman filter.mq4 |
//|                                                                  |
//| based on original made by GammaRat                               |
//| http://www.gammarat.com/Forex/                                   |
//| this version by mladen
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Goldenrod
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_style1 0
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT
#property indicator_style6 0
#property indicator_style7 0

//
//
//
//
//

extern string TimeFrame         = "Current time frame";
extern double Samples           = 41;
extern double DevLevel1         =  0;
extern double DevLevel2         =  1;
extern double Suppression_dB    =  0;
extern bool   AutoGainOn        = true;
extern bool   Interpolate       = true;

//
//
//
//
//

double KalmanBuffer[];
double KalmanBufferPlus1[];
double KalmanBufferNeg1[];
double KalmanBufferPlus2[];
double KalmanBufferNeg2[];
double KalmanBufferPlus3[];
double KalmanBufferNeg3[];

double xkk[2][1],xkk1[2][1],xk1k1[2][1],yk[1][1],zk[2][1];
double Pkk[2][2],pkk1[2][2],Pk1k1[2][2];
double Qkk[2][2],Hk[1][2],Hk_t[2][1],Sk[1][1],Sk_inv[1][1],Rk[1][1],Kk[2][1];
double Fk[2][2],Fk_t[2][2],GGT[2][2];
double Eye[2][2];
double temp22[2][2],temp21[2][1],temp12[1][2],temp11[1][1];
double LookAhead=0;

//
//
//
//
//

double tBuffer[][12];
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   if(LookAhead <0)LookAhead=0;
   SetIndexBuffer(0,KalmanBuffer);  SetIndexShift(0,LookAhead); SetIndexDrawBegin(0,LookAhead); SetIndexLabel(0,"Kalman Trend");
   
   //
   //
   //
   //
   //

   int type1 = DRAW_NONE; if(MathAbs(DevLevel1) > 0) type1 = DRAW_LINE;
   int type2 = DRAW_NONE; if(MathAbs(DevLevel2) > 0) type2 = DRAW_LINE;
      SetIndexBuffer(1,KalmanBufferPlus1); SetIndexStyle(1,type1); SetIndexLabel(1,"Kalman +"      + DoubleToStr(DevLevel1,1) + " STD");
      SetIndexBuffer(2,KalmanBufferNeg1);  SetIndexStyle(2,type1); SetIndexLabel(2,"Kalman -"      + DoubleToStr(DevLevel1,1) + " STD");
      SetIndexBuffer(3,KalmanBufferPlus2); SetIndexStyle(3,type2); SetIndexLabel(3,"Kalman +"      + DoubleToStr(DevLevel2,1) + " STD");
      SetIndexBuffer(4,KalmanBufferNeg2);  SetIndexStyle(4,type2); SetIndexLabel(4,"Kalman -"      + DoubleToStr(DevLevel2,1) + " STD");
      SetIndexBuffer(5,KalmanBufferPlus3); SetIndexStyle(5,type2); SetIndexLabel(5,"Kalman High +" + DoubleToStr(DevLevel2,1) + " STD");
      SetIndexBuffer(6,KalmanBufferNeg3);  SetIndexStyle(6,type2); SetIndexLabel(6,"Kalman Low -"  + DoubleToStr(DevLevel2,1) + " STD");

   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = TimeFrame=="calculateValue";   if (calculateValue) { return(0); }
         returnBars        = TimeFrame=="returnBars";       if (returnBars)     { return(0); }
         timeFrame         = stringToTimeFrame(TimeFrame);
   return(0);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
  int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
        int limit=MathMin(Bars-counted_bars,Bars-1);
        if (returnBars) { KalmanBuffer[0] = MathMin(limit+1,Bars-1); return(0); }

   if (calculateValue || timeFrame == Period()) { compute(limit); return(0); }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (int i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         KalmanBuffer[i]      = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,0,y);
         KalmanBufferPlus1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,1,y);
         KalmanBufferNeg1[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,2,y);
         KalmanBufferPlus2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,3,y);
         KalmanBufferNeg2[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,4,y);
         KalmanBufferPlus3[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,5,y);
         KalmanBufferNeg3[i]  = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",Samples,DevLevel1,DevLevel2,Suppression_dB,AutoGainOn,6,y);

         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

            datetime time = iTime(NULL,timeFrame,y);
               for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
               for(int k = 1; k < n; k++)
               {
                  KalmanBuffer[i+k] = KalmanBuffer[i] + (KalmanBuffer[i+n] - KalmanBuffer[i])*k/n;
                  if (KalmanBufferPlus1[i]!= EMPTY_VALUE)
                  {
                     KalmanBufferPlus1[i+k] = KalmanBufferPlus1[i] + (KalmanBufferPlus1[i+n] - KalmanBufferPlus1[i])*k/n;
                     KalmanBufferNeg1[i+k]  = KalmanBufferNeg1[i]  + (KalmanBufferNeg1[i+n]  - KalmanBufferNeg1[i] )*k/n;
                  }
                  if (KalmanBufferPlus2[i]!= EMPTY_VALUE)
                  {
                     KalmanBufferPlus2[i+k] = KalmanBufferPlus2[i] + (KalmanBufferPlus2[i+n] - KalmanBufferPlus2[i])*k/n;
                     KalmanBufferNeg2[i+k]  = KalmanBufferNeg2[i]  + (KalmanBufferNeg2[i+n]  - KalmanBufferNeg2[i] )*k/n;
                     KalmanBufferPlus3[i+k] = KalmanBufferPlus3[i] + (KalmanBufferPlus3[i+n] - KalmanBufferPlus3[i])*k/n;
                     KalmanBufferNeg3[i+k]  = KalmanBufferNeg3[i]  + (KalmanBufferNeg3[i+n]  - KalmanBufferNeg3[i] )*k/n;
                  }
               }                  
   }
   return(0);
}

//
//
//
//
//

#define c0_above 0
#define c0_below 1
#define c1_above 2
#define c1_below 3
#define Again    4
#define save1    5
#define save2    7

//
//
//
//
//

int compute(int limit)
{
   static bool initiated=false;

   //
   //
   //
   //
   //
      
   int i,r;
   static double acc_sigma2;
   double diff; 
   static double dev_level1,dev_level2; 
   double temp11a[1][1],temp21a[2][1];
   double temp22a[2][2]; 
        if (ArrayRange(tBuffer,0) != Bars) ArrayResize(tBuffer,Bars);
   
   //
   //
   //
   //
   //
   
   if(!initiated)
   {
      initiated = true;
      dev_level1 = DevLevel1*MathSqrt(2);
      dev_level2 = DevLevel2*MathSqrt(2);
            KalmanBuffer[Bars-1] = High[Bars-1];
         
      xkk1[0][0] = get_avg(Bars-1);
      xkk1[1][0] = 0;
            MatrixSave(xkk1,0,save1);
            
      //
      //
      //
      //
      //
        
         Fk[0][0] = 1.00; Fk[0][1] = 1.00;
         Fk[1][0] = 0.00; Fk[1][1] = 1.00;  MatrixTranspose(Fk,Fk_t);
         Hk[0][0] = 1.00; Hk[0][1] = 0.00;  MatrixTranspose(Hk,Hk_t);
         
         GGT[0][0] = 0.25;
         GGT[1][0] = 0.50;
         GGT[0][1] = 0.50;
         GGT[1][1] = 1.00;
      
         Rk[0][0] = 1.00;
         
      MatrixEye(Eye);
      MatrixEye(pkk1);
 
      acc_sigma2 = Point*MathPow(10,-Suppression_dB/20.);//*MathSqrt(0.0001/Point);
         MatrixScalarMul(acc_sigma2,pkk1);
         MatrixSave(pkk1,0,save2);
      acc_sigma2 *= acc_sigma2;
         MatrixScalarMul(acc_sigma2,Pkk);
      tBuffer[0][Again]=1.0;
   }
 
   //
   //
   //
   //
   //
 
   for(i=limit, r=Bars-i; i>0; i--,r++)
   {
      KalmanBufferPlus1[i-1] = EMPTY_VALUE;
      KalmanBufferPlus2[i-1] = EMPTY_VALUE;
      KalmanBufferPlus3[i-1] = EMPTY_VALUE;
      KalmanBufferNeg1[i-1]  = EMPTY_VALUE;
      KalmanBufferNeg2[i-1]  = EMPTY_VALUE;
      KalmanBufferNeg3[i-1]  = EMPTY_VALUE;
      zk[0][0] = get_avg(i);
      zk[1][0] = zk[0][0]-get_avg(i+1);
      
      //
      //
      //
      //
      //
      
      diff = (zk[0][0]*Point-KalmanBuffer[i]);
      if(diff>=0)
      {
         diff = diff*diff;
            tBuffer[r][c0_above] = (tBuffer[r-1][c0_above]*(Samples-1)+MathPow(get_avg(i)*Point-KalmanBuffer[i],2))/Samples;
            tBuffer[r][c0_below] =  tBuffer[r-1][c0_below]*(Samples-1)/Samples;
            tBuffer[r][c1_above] = (tBuffer[r-1][c1_above]*(Samples-1)+MathPow(High[i]-KalmanBuffer[i],2))/Samples;
            tBuffer[r][c1_below] =  tBuffer[r-1][c1_below]*(Samples-1)/Samples;
      }
      else
      {
         diff = diff*diff;
            tBuffer[r][c0_below] = (tBuffer[r-1][c0_below]*(Samples-1)+MathPow(get_avg(i)*Point-KalmanBuffer[i],2))/Samples;
            tBuffer[r][c0_above] =  tBuffer[r-1][c0_above]*(Samples-1)/Samples;
            tBuffer[r][c1_below] = (tBuffer[r-1][c1_below]*(Samples-1)+MathPow(Low[i]-KalmanBuffer[i],2))/Samples;
            tBuffer[r][c1_above] =  tBuffer[r-1][c1_above]*(Samples-1)/Samples;
      }
 
      //
      //
      //
      //
      //
           
      if(MathAbs(DevLevel1)>0)
      {
         KalmanBufferPlus1[i-1] = KalmanBuffer[i]+dev_level1*MathSqrt(tBuffer[r][c0_above]);
         KalmanBufferNeg1[i-1]  = KalmanBuffer[i]-dev_level1*MathSqrt(tBuffer[r][c0_below]);
      }
      if(MathAbs(DevLevel2)>0)
      {   
         KalmanBufferPlus2[i-1] = KalmanBuffer[i]+dev_level2*MathSqrt(tBuffer[r][c0_above]);
         KalmanBufferNeg2[i-1]  = KalmanBuffer[i]-dev_level2*MathSqrt(tBuffer[r][c0_below]);
         KalmanBufferPlus3[i-1] = KalmanBuffer[i]+dev_level2*MathSqrt(tBuffer[r][c1_above]);
         KalmanBufferNeg3[i-1]  = KalmanBuffer[i]-dev_level2*MathSqrt(tBuffer[r][c1_below]);
      } 
     
      //
      //
      //
      //
      //
     
      if(AutoGainOn && MathSqrt((tBuffer[r][c0_above]+tBuffer[r][c0_below])/2)> Point)
      {   
         if(tBuffer[r][c0_below] >0 || tBuffer[r][c0_above]>0)
               double tgain = MathAbs((tBuffer[r][c0_below])/(tBuffer[r][c0_below]+tBuffer[r][c0_above]));
         else         tgain = 0.5;
         
         //
         //
         //
         //
         //
         
         tBuffer[r][Again] = tBuffer[r-1][Again];
            if(tgain< 0.2 || tgain > 0.8) tBuffer[r][Again] = tBuffer[r-1][Again]*MathPow(10, 0.005);
            if(tgain> 0.4 && tgain < 0.6) tBuffer[r][Again] = tBuffer[r-1][Again]*MathPow(10,-0.005);
      }
      else  tBuffer[r][Again] = 1.00;

      //
      //
      //
      //
      //
            
      tgain = tBuffer[r][Again]*acc_sigma2;

         ArrayCopy(Qkk,GGT);
         MatrixRestore(xkk1,r-1,save1);
         MatrixRestore(pkk1,r-1,save2);

            MatrixScalarMul(tgain,Qkk);
            MatrixMul(Hk,xkk1,temp11);
               MatrixZero(yk);
            MatrixAdd(zk,temp11,yk, -1); 
            MatrixMul(Hk,pkk1,temp12);
            MatrixMul(temp12,Hk_t,temp11);
            MatrixAdd(temp11,Rk,Sk,1);
            MatrixInvert(Sk,Sk_inv);
            MatrixMul(pkk1,Hk_t,temp21);
            MatrixMul(temp21,Sk_inv,Kk);
            MatrixMul(Kk,yk,temp21);
            MatrixAdd(temp21,xkk1,xkk,1);
      
            MatrixMul(Kk,Hk,temp22);
            MatrixAdd(Eye,temp22,temp22a,-1);
            MatrixMul(temp22a,pkk1,Pkk);
      
         ArrayCopy(Pk1k1,Pkk);
         ArrayCopy(xk1k1,xkk);

            MatrixMul(Fk,xk1k1,xkk1);
            MatrixMul(Fk,Pk1k1,temp22);
            MatrixMul(temp22,Fk_t,Pk1k1);
            MatrixAdd(Pk1k1,Qkk,pkk1,1);

      //
      //
      //
      //
      //
      
      KalmanBuffer[i-1] = (xkk1[0][0]*Point);

      MatrixSave(xkk1,r,save1);
      MatrixSave(pkk1,r,save2);
   }
   return(0);   
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double get_avg(int k){ return(MathPow((High[k]*Low[k]*Close[k]*Close[k]),0.25)/Point); }        
double determinant_fixed(double& a[][], int k){
   double z;
    switch(k){
      case 1: return(a[0][0]);                           break;
      case 2: return( a[0][0]*a[1][1]-a[1][0]*a[0][1]);  break;
      case 3:
         z = a[0][0]*a[1][1]*a[2][2] + a[0][1]*a[1][2]*a[2][0] + a[0][2]*a[1][0]*a[2][1] -
            (a[2][0]*a[1][1]*a[0][2] + a[1][0]*a[0][1]*a[2][2] + a[0][0]*a[2][1]*a[1][2]);
         return(z);
         break;
      default:      
          Print("array_range too large for determinant calculation");
         return(0);
   }  
}
double determinant(double& a[][]){
   double z;
    switch(ArrayRange(a,0))
    {
      case 1:  return(a[0][0]);                         break;
      case 2:  return(a[0][0]*a[1][1]-a[1][0]*a[0][1]); break;
      case 3:
         z = a[0][0]*a[1][1]*a[2][2] + a[0][1]*a[1][2]*a[2][0] + a[0][2]*a[1][0]*a[2][1] -
            (a[2][0]*a[1][1]*a[0][2] + a[1][0]*a[0][1]*a[2][2] + a[0][0]*a[2][1]*a[1][2]);
               return(z);
               break;
      default:      
          Print("array_range too large for determinant calculation");
         return(0);
   }  
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

  
int MatrixInvert(double& a[][],double & b[][]){
   double d;
   double temp1[4][4],temp2[4][4];
   int i,j,j1,k;
   
   d = determinant(a);
   if(MathAbs(d)<0.000001) d = 1; //  Print("unstable matrix");
   
   k = ArrayRange(a,0);
      if(k==0)
      {
         b[0][0]=1./a[0][0];
         return(0);
      }
   
//   d = determinant(a);

   for(i=0;i<k;i++){
   for(j=0;j<k;j++){
      temp1[i][j] = a[i][j];
   }
   }   
      
   for(i=0;i<k;i++){
   for(j=0;j<k;j++){
      ArrayCopy(temp2,temp1);
      for(j1=0;j1<k;j1++)
         if(j1==j) temp2[i][j1] = 1;
         else      temp2[i][j1] = 0;
      b[i][j]=determinant_fixed(temp2,k)/d;
   }
   }
   return(0);
}   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void MatrixSave(double& a[][],int index,int k)
{
   int i,j;
   for(i=0; i<ArrayRange(a,0); i++){
   for(j=0; j<ArrayRange(a,1); j++,k++){
         tBuffer[index][k] = a[i][j];
   }
   }
   
}
void MatrixRestore(double& a[][],int index,int k)
{
   int i,j;
   for(i=0; i<ArrayRange(a,0); i++){
   for(j=0; j<ArrayRange(a,1); j++,k++){
          a[i][j] = tBuffer[index][k];
   }
   }
   
}
void MatrixMul(double& a[][], double& b[][],double & c[][]){
   int i,j,k;
   if(ArrayRange(a,1) != ArrayRange(b,0)){
      Print("array Range Mismatch in Matrix Mul");
      return;
   }
   for(i=0;          i<ArrayRange(a,0);i++){
   for(j=0;          j<ArrayRange(b,1);j++){
   for(k=0,c[i][j]=0;k<ArrayRange(a,1);k++){
           c[i][j] += (a[i][k]*b[k][j]);
   }  
   }
   }
}
void MatrixAdd(double& a[][], double& b[][],double & c[][],double w=1)
{
   int i,j;
   for(i=0;i<ArrayRange(c,0);i++){
   for(j=0;j<ArrayRange(c,1);j++){
         c[i][j] = a[i][j]+w*b[i][j];
   }
   }
}
void MatrixScalarMul(double b,double & a[][])
{
   int i,j;
   for(i=0; i<ArrayRange(a,0); i++){
   for(j=0; j<ArrayRange(a,1); j++){
         a[i][j] *= b;
   }
   }
}         
void MatrixTranspose(double & a[][],double & b[][])
{
   int i,j;
   for(i=0; i<ArrayRange(a,0); i++){
   for(j=0; j<ArrayRange(a,1); j++){
         b[j][i] = a[i][j];
   }
   }
 }
void MatrixZero(double & a[][])
{
   int i,j; 
   for(i=0; i<ArrayRange(a,0); i++){
   for(j=0; j<ArrayRange(a,1); j++){
         a[i][j]=0;
   }
   }
}
void MatrixEye(double & a[][])
{
   int i,j; 
   for(i=0; i<ArrayRange(a,0); i++){
   for(j=0; j<ArrayRange(a,1); j++){
         a[i][j]=0;
         if(i==j) a[i][j]=1;
   }
   }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}