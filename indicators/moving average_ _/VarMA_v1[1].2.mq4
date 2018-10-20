//+------------------------------------------------------------------+
//|                                                   VarMA_v1.2.mq4 |
//|                               Copyright © 2007-09, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007-09, Forex-TSD.com "
#property link      "http://www.forex-tsd.com/"

#property indicator_chart_window
#property indicator_buffers   1
#property indicator_color1    LightBlue
#property indicator_width1    2 

//---- input parameters
extern int       MA_Length    =  1; // Period of MA 
extern int       VarMA_Length =  4; // Period of VarMA 
extern int       ADX_Length   =  8; // Period of ADX
extern int       ADX_Type     =  0; // ADX Type: 0-ADX,1-ADXR
extern int       MA_Mode      =  1; // MA's Mode: 0-SMA,1-EMA,2-SMMA,3-LWMA
extern int       Shift        =  0; //Shift in bars
//---- buffers
double MA[];
double VarMA[];
double VMA[];
double ADX[];
double ADXR[];
double sPDI[];
double sMDI[];
double STR[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA);
   SetIndexBuffer(1,VarMA);
   SetIndexBuffer(2,VMA);
   SetIndexBuffer(3,ADX);
   SetIndexBuffer(4,ADXR);
   SetIndexBuffer(5,sPDI);
   SetIndexBuffer(6,sMDI);
   SetIndexBuffer(7,STR);
   
   //---- name for DataWindow and indicator subwindow label
   string short_name="VarMA("+VarMA_Length+","+ADX_Length+","+ADX_Type+","+MA_Mode+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"VarMA");

//----
   SetIndexDrawBegin(0,2*(MA_Length+ADX_Length+MA_Length));
   SetIndexShift(0,Shift); 
     IndicatorDigits(Digits+1);
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int      shift, limit, counted_bars=IndicatorCounted();
   
   double alfa = 1.0/ADX_Length;
//---- 
     
   if ( counted_bars < 0 ) return(-1);
   if ( counted_bars ==0 ) limit=Bars-1;//limit=Bars-MA_Length-VarMA_Length-ADX_Length-1;
   if ( counted_bars < 1 ) 
   
   for(int i=1;i<2*(MA_Length+VarMA_Length+ADX_Length);i++) 
   {
   VMA[Bars-i]=Close[Bars-i];    
   VarMA[Bars-i]=Close[Bars-i];  
   MA[Bars-i]=Close[Bars-i];    
   STR[Bars-i] = High[Bars-i]-Low[Bars-i]; 
   sPDI[Bars-i] = 0;
   sMDI[Bars-i] = 0;
   ADX[Bars-i]=0;
   ADXR[Bars-i]=0;
   }
     
   if(counted_bars>0) limit=Bars-counted_bars;
   limit--;
   
   for( shift=limit; shift>=0; shift--)
   {
   double Hi  = High[shift];
   double Hi1 = High[shift+1];
   double Lo  = Low[shift];
   double Lo1 = Low[shift+1];
   double Close1= Close[shift+1];
   
   double Bulls = 0.5*(MathAbs(Hi-Hi1)+(Hi-Hi1));
   double Bears = 0.5*(MathAbs(Lo1-Lo)+(Lo1-Lo));
   
   if (Bulls > Bears) Bears = 0;
   else 
   if (Bulls < Bears) Bulls = 0;
   else
   if (Bulls == Bears) {Bulls = 0;Bears = 0;}
  
   sPDI[shift] = sPDI[shift+1] + alfa * (Bulls - sPDI[shift+1]);
   sMDI[shift] = sMDI[shift+1] + alfa * (Bears - sMDI[shift+1]);
   
   double   TR = MathMax(Hi-Lo,Hi-Close1); 
   STR[shift]  = STR[shift+1] + alfa * (TR - STR[shift+1]); 
    
      if(STR[shift]>0 )
      {
      double PDI = 100*sPDI[shift]/STR[shift];
      double MDI = 100*sMDI[shift]/STR[shift];
      }
            
   if((PDI + MDI) > 0) 
   double DX = 100*MathAbs(PDI - MDI)/(PDI + MDI); 
   else DX = 0;
   
   ADX[shift] = ADX[shift+1] + alfa * (DX - ADX[shift+1]); 
   
   ADXR[shift] = 0.5*(ADX[shift] + ADX[shift+ADX_Length]);
     
   if (ADX_Type == 0) double vADX = ADX[shift]; else vADX = ADXR[shift];
     
   if(VarMA_Length > 0) double MaInd = 2.0/(1.0+VarMA_Length); else MaInd = 0.2; 
   
      double ADXmin = 1000000;
      for (i=0; i<=ADX_Length-1;i++) 
      {
      if (ADX_Type == 0) ADXmin = MathMin(ADXmin,ADX[shift+i]);
      else ADXmin = MathMin(ADXmin,ADXR[shift+i]);
      }
      
      double ADXmax = -1;
      for (i=0; i<=ADX_Length-1;i++) 
      {
      if (ADX_Type == 0) ADXmax = MathMax(ADXmax,ADX[shift+i]);
      else ADXmax = MathMax(ADXmax,ADXR[shift+i]);
      }
   
   double Diff = ADXmax - ADXmin;
   if(Diff > 0) double Const = (vADX- ADXmin)/Diff; else Const = MaInd;
   if(Const>MaInd) Const = MaInd; else Const = Const;  
   
   VMA[shift] = (1 - Const) * VMA[shift+1] + Const *Close[shift];
   VarMA[shift] = (VMA[shift] + VMA[shift+1])/2;
   }
   
   for( shift=limit; shift>=0; shift--)
   MA[shift] = iMAOnArray(VarMA,0,MA_Length,0,MA_Mode,shift);
//----
   return(0);
  }
//+------------------------------------------------------------------+