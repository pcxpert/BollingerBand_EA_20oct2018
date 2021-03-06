//+-------------------------------------------------------------------------------|
//|                                                      BB_Squeeze_Advanced_v2M3 |
//|      Copyright © 2005,MetaQuotes Software Corp. author:  Scriptor or Collector|
//|  2008ForexTSD  mladen  ki                          http://www.metaquotes.net/ |
//|  Cleaned up, options, additions (the usual bla,bla:)  Mladen; mtf WEN formula |
//+-------------------------------------------------------------------------------|
//   BB_Squeeze_Advanced_v2M3BC  // macd/osma histo switch ; cci turbo
//

#property  copyright "Copyright © MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/ www.ForexTSD.com 2007 Mladen"

//
//
//
//
//

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 ForestGreen
#property indicator_color2 Red
#property indicator_color3 DarkGreen
#property indicator_color4 FireBrick
#property indicator_color5 DodgerBlue
#property indicator_color6 SlateGray
#property indicator_color7 Yellow
#property indicator_color8 Lime
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width7 1
#property indicator_levelcolor DarkSlateBlue
#property indicator_levelstyle 4

//
//
//
//
//

extern int TimeFrame = 0;
//
extern string    graph     = "type:";
extern int       graphType = 1;
extern string    types     = "parameters:";
   extern int    type1_linearRegresion_Period =20;
   extern int    type2_stoch_KPeriod          =14;
   extern int    type2_stoch_DPeriod          = 3;
   extern int    type2_stoch_Slowing          = 3;
   extern int    type3_cci_Period1            =50;
   extern int    type3_cci_Period2            =14;
   extern int    type3_cci_Period3            =6;
   extern int    type4_rsi_Period             =14;
   extern int    type5_macd_fastEMA           =12;
   extern int    type5_macd_slowEMA           =26;
   extern int    type5_macd_macdEMA           = 9;
   extern bool   type5_macd_OsMA_Histo        = true; // true=OsMA Histo false=MACD Histo
   extern int    type6_momentum_Period        =14;
   extern int    type6_momentum_Smoozing      =5;
   extern int    type7_williamsPR_Period      =14;
   extern int    type8_demarker_Period        =10;
   extern int    type9_adx_Period             =14;

//
//
//
//
//

extern string    squeeze = "parameters:";
extern int       Bollinger_Period     =  20;
extern double    Bollinger_Deviation  =  2.0;
extern int       Keltner_Period       =  20;
extern double    Keltner_Factor       =  1.5;
extern double    squeezeSigLevel      =  0.0001;

extern string    other   = "parameters:";
extern int       BarsToCount          =900;
extern bool      ShowLevels           =true;
//
extern string note_TimeFrames = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";
//extern string  note__MaMode_Price = "Price(C O1 H2 3L 4M 5T W6) ModeMa(SMA0,EMA1,SmmMA2,LWMA3)";

string IndicatorFileName;

//------------------------
//
//
//
//

double upB[];
double loB[];
double upB2[];
double loB2[];
double histoLine[];
double upK[];
//double loK[];
double mm[];
double mm1[];

//------------------------------
//
//
//    regression slope variables
//
//

double SumSqrBars;
double SumBars;
double Num2;


//---------------------------------------------------------------------------------|
//                                                                                 |
//---------------------------------------------------------------------------------|

int init()
{
      string shortName;
      IndicatorBuffers (8);
      SetIndexBuffer(0,upB);
      SetIndexBuffer(1,loB);
      SetIndexBuffer(2,upB2);
      SetIndexBuffer(3,loB2);
      SetIndexBuffer(4,mm);
      SetIndexBuffer(5,histoLine);
      SetIndexBuffer(6,upK);
      SetIndexBuffer(7,mm1);//loK
   
   //
   //
   //
   //
   //
   
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexStyle(5,DRAW_LINE);
      SetIndexStyle(6,DRAW_ARROW);
      SetIndexArrow(6,158);
      SetIndexStyle(7,DRAW_NONE);
//      SetIndexArrow(7,159);

   //
   //
   //
   //
   //

   if ((graphType < 1) || (graphType > 9)) graphType = 1;
   switch (graphType) {
         case 1:
            SetLevels(0.004,-0.004);
            shortName = "linear regression slope ("+type1_linearRegresion_Period+")";
            
               //
               //
               //    constants depending axclusivelly on linear regression period
               //
               //
               
               SumBars    = type1_linearRegresion_Period * (type1_linearRegresion_Period-1) * 0.5;
               SumSqrBars = type1_linearRegresion_Period * (type1_linearRegresion_Period-1) * (2 * type1_linearRegresion_Period - 1)/6;
               Num2       = MathPow(SumBars,2) - type1_linearRegresion_Period * SumSqrBars;
            break;
            
            //
            //
            //
            //
            //
            
         case 2:
            SetLevels(30,-30);
            shortName = StringConcatenate("Stochastic (",type2_stoch_KPeriod,",",
                                                         type2_stoch_DPeriod,",", 
                                                         type2_stoch_Slowing,")");
            SetIndexStyle(4,DRAW_LINE);
            break;
         case 3:
            SetLevels(100,-100);
//            shortName = "CCI ("+type3.cci.Period+";"+ type3.cci2.Period2+",CLOSE)";
            shortName = StringConcatenate("CCI (",type3_cci_Period1,",",
                                                  type3_cci_Period2,",", 
                                                  type3_cci_Period3,")");
 
            SetIndexStyle(4,DRAW_LINE);      
            SetIndexStyle(7,DRAW_LINE);
            break;  
         case 4:
            SetLevels(20,-20);
            shortName = "RSI ("+type4_rsi_Period+",CLOSE)";
            break;
         case 5:            
            SetLevels(0.001,-0.001);
            shortName = "MACD OsSMA (" +type5_macd_fastEMA+","
                                       +type5_macd_slowEMA+","
                                       +type5_macd_macdEMA+",CLOSE)";
            SetIndexStyle(4,DRAW_LINE);
            SetIndexStyle(7,DRAW_LINE);

            break;
         case 6:            
            SetLevels(1,-1);
            shortName = "Momentum ("+type6_momentum_Period+","
                                    +type6_momentum_Smoozing+",CLOSE)";
            SetIndexStyle(4,DRAW_LINE);
            break;
         case 7:            
            SetLevels(30,-30);
            shortName = "Williams% ("+type7_williamsPR_Period+")";
            break;
         case 8:
            SetLevels(0.20,-0.20);
            shortName = "Demarker ("+type8_demarker_Period+")";
            break;
         case 9:
            SetLevels(20,-20);
            shortName = "ADX ("+type9_adx_Period+")";
            SetIndexStyle(4,DRAW_LINE);

            break;

 
      }                     

   //
   //
   //
   //
   //
        IndicatorFileName = WindowExpertName();

   IndicatorShortName("BollingerSqueeze ["+TimeFrame+"] with "+shortName);
        if (TimeFrame < Period()) TimeFrame = Period();
  
   BarsToCount = MathMax(BarsToCount,150);
   return(0);
}

//---------------------------------------------------------------------------------|
//                                                                                 |
//---------------------------------------------------------------------------------|

int deinit()
{
   return(0);
}

//---------------------------------------------------------------------------------|
//                                                                                 |
//---------------------------------------------------------------------------------|

//void SetLevels(double level1,double level2,double level3=NULL,double level4=NULL)
  void SetLevels(double level1,double level2)

{
   if (ShowLevels) 
      {
         SetLevelValue(0,level1);
         SetLevelValue(1,level2);
//       SetLevelValue(2,level3);
//       SetLevelValue(3,level4);
      }         
   return;        
}

//
//
//
//
//

double CallMain(int buffNo,int shift)
{
   double result = iCustom(NULL,TimeFrame,IndicatorFileName,
                                          0,"",
                                          graphType,"",
                                          type1_linearRegresion_Period,
                                          type2_stoch_KPeriod,
                                          type2_stoch_DPeriod,
                                          type2_stoch_Slowing,
                                          type3_cci_Period1,
                                          type3_cci_Period2,
                                          type3_cci_Period3,
                                          type4_rsi_Period,
                                          type5_macd_fastEMA,
                                          type5_macd_slowEMA,
                                          type5_macd_macdEMA,
                                          type5_macd_OsMA_Histo,
                                          type6_momentum_Period,
                                          type6_momentum_Smoozing,
                                          type7_williamsPR_Period,
                                          type8_demarker_Period,
                                          type9_adx_Period, "",
                                          Bollinger_Period,
                                          Bollinger_Deviation,
                                          Keltner_Period,
                                          Keltner_Factor,
                                          squeezeSigLevel,"",
                                          BarsToCount,
                                          false,
                                          buffNo,shift);
   return(result);
}

//---------------------------------------------------------------------------------|
//                                                                                 |
//---------------------------------------------------------------------------------|

int start() 

{
  
   int counted_bars1=IndicatorCounted();
   int      limit1,i1,y;
   if(counted_bars1 < 0) return(-1);
   limit1 = Bars-counted_bars1;
   if (TimeFrame != Period())
      {
         limit1 = MathMax(limit1,TimeFrame/Period());
         datetime TimeArray[];
         ArrayCopySeries(TimeArray ,MODE_TIME ,NULL,TimeFrame);
            for(i1=0 ,y=0; i1<limit1; i1++)
            {
              if(Time[i1]<TimeArray[y]) y++;
               upB     [i1]   = CallMain(0,y);
               loB     [i1]   = CallMain(1,y);
               upB2    [i1]   = CallMain(2,y);
               loB2    [i1]   = CallMain(3,y);
               mm      [i1]   = CallMain(4,y);
               histoLine [i1] = CallMain(5,y);
               upK     [i1]   = CallMain(6,y);
               mm1     [i1]   = CallMain(7,y);
             }
         return(0);         
      }

   int      limit=IndicatorCounted();
   int      i;
   double   diff,std,bbs,d;
   
   if (limit<0) return(-1);
   if (limit>0) limit--;
      limit=MathMin(Bars-limit,BarsToCount);

   //
   //
   //
   //
   //
   
   for (i=limit;i>=0;i--)
   {
      switch (graphType) 
         {
         case 1: d=LinearRegressionSlope(type1_linearRegresion_Period,i);             
                                       break; 
         case 2: d=iStochastic(NULL,0,type2_stoch_KPeriod,
                                      type2_stoch_DPeriod, 
                                      type2_stoch_Slowing,MODE_SMA,0,MODE_MAIN,i)-50; 
             mm[i]=iStochastic(NULL,0,type2_stoch_KPeriod,
                                      type2_stoch_DPeriod, 
                                      type2_stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,i)-50;
                                      break;
         case 3:  d=     iCCI(NULL,0,  type3_cci_Period1,PRICE_CLOSE,i);           
             mm [i]=     iCCI(NULL,0,  type3_cci_Period2,PRICE_CLOSE,i); 
             mm1[i]=     iCCI(NULL,0,  type3_cci_Period3,PRICE_CLOSE,i); 
                                    break;  
         case 4: d=   iRSI(NULL,0,  type4_rsi_Period,PRICE_CLOSE,i)-50;                    
                                    break;
         case 5: d=   iMACD(NULL,0, type5_macd_fastEMA,
                                    type5_macd_slowEMA,
                                    type5_macd_macdEMA,PRICE_CLOSE,MODE_MAIN,i);
                 mm[i]=iMACD(NULL,0,type5_macd_fastEMA,
                                    type5_macd_slowEMA,
                                    type5_macd_macdEMA,PRICE_CLOSE,MODE_SIGNAL,i);
                                    
                 if  (type5_macd_OsMA_Histo)             
                  {
                  d=   iOsMA(NULL,0,type5_macd_fastEMA,
                                    type5_macd_slowEMA,
                                    type5_macd_macdEMA,PRICE_CLOSE,i);                   
                mm1[i]=iMACD(NULL,0,type5_macd_fastEMA,
                                    type5_macd_slowEMA,
                                    type5_macd_macdEMA,PRICE_CLOSE,MODE_MAIN,i);
                   }                                     
                                    break;                                           
         case 6: d=iMomentum(NULL,0,type6_momentum_Period,PRICE_CLOSE,i)-100;   
                                    break;
         case 7: d=     iWPR(NULL,0,type7_williamsPR_Period,i)+50;                   
                                    break; 
         case 8: d=iDeMarker(NULL,0,type8_demarker_Period,i)-0.5;               
                                    break;
         case 9: d=     iADX(NULL,0,type9_adx_Period,PRICE_CLOSE, MODE_PLUSDI,i)
                       -iADX(NULL,0,type9_adx_Period,PRICE_CLOSE, MODE_MINUSDI,i); 
                 mm[i] =iADX(NULL,0,type9_adx_Period,PRICE_CLOSE, MODE_MAIN,i);      
                                    break;  
      
      }

      //
      //
      //
      //
      //
            
         diff = iATR(NULL,0,Keltner_Period,i)*Keltner_Factor;
         std  = iStdDev(NULL,0,Bollinger_Period,MODE_SMA,0,PRICE_CLOSE,i);
         bbs  = Bollinger_Deviation * std / diff;

      //
      //
      //
      //
      //
      
      histoLine[i]=d;
        
               upB[i]=EMPTY_VALUE;
               loB[i]=EMPTY_VALUE;
               upB2[i]=EMPTY_VALUE;
               loB2[i]=EMPTY_VALUE;
   
         if (d > 0) 
            {         
             if (histoLine[i]> histoLine[i+1])
               {
            upB[i]=d; upB2[i]=EMPTY_VALUE; 
               }
              else 
               {
            upB[i]=EMPTY_VALUE; upB2[i]=d; 
               }
             }
            
          else      
            {  
             if (histoLine[i]> histoLine[i+1])
                 { 
             loB[i]=d; loB2[i]=EMPTY_VALUE; 
                 }
              else
                 { 
             loB[i]=EMPTY_VALUE; loB2[i]=d; 
                 }
             }
             
             
                        upK [i] =EMPTY_VALUE;
        if(bbs<1)
         {
            if (d < 0)  upK[i]= squeezeSigLevel;
            else        upK[i]=-squeezeSigLevel;
          }
        else            upK [i] =EMPTY_VALUE;
            
     
     //           
     // 
     //            
   }
   if (graphType==6)
      for (i=limit;i>=0;i--)
       {
         mm[i]= iMAOnArray (histoLine,0,type6_momentum_Smoozing,0,MODE_SMA,i);
       }
   
   return(0);
}

//---------------------------------------------------------------------------------|
//                                                                                 |
//---------------------------------------------------------------------------------|

double LinearRegressionSlope(int Len,int shift)
{
   double LinearRegSlope;
   double SumY = 0;
   double Sum1 = 0;
   double Num1;
   int    i;


   //
   //
   //
   //
   //
   
   for (i=0; i<Len; i++) {
         Sum1 += i*iMA(NULL,0,1,0,MODE_SMMA,PRICE_CLOSE,i+shift);
         SumY +=   iMA(NULL,0,1,0,MODE_SMMA,PRICE_CLOSE,i+shift);
      }
      Num1 = Len * Sum1 - SumBars * SumY;

   //
   //
   //
   //
   //

   if( Num2 != 0 ) 
         	LinearRegSlope = 100*Num1/Num2;
   else     LinearRegSlope = 0; 
   return  (LinearRegSlope);
}

