
#property copyright "Copyright � 2010, sangmane@forexfactory.com."
#property link      "mailto:steven00@fastmail.fm"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;
//---- indicator buffers
double ZigzagBuffer[];
double HighMapBuffer[];
double LowMapBuffer[];
int level=3; // recounting's depth 
bool downloadhistory=false;
double Pip;
bool Started=False;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//---- drawing settings
   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ZigzagBuffer);
   SetIndexBuffer(1,HighMapBuffer);
   SetIndexBuffer(2,LowMapBuffer);
   SetIndexEmptyValue(0,0.0);

//---- indicator short name
   IndicatorShortName("ZigZag("+ExtDepth+","+ExtDeviation+","+ExtBackstep+")");
   if(Digits==3 || Digits==5) Pip = 10*Point;
   else Pip = Point;   
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
    DelObj();
    return(0);
  }

void DelObj()
  {
   string ObjName;
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
     ObjName = ObjectName(i);
     if(StringFind(ObjName,"ZZLabel",0)>=0)
       ObjectDelete(ObjName);
   }
   return;
  }

int start()
  {
   int i, counted_bars = IndicatorCounted();
   int limit,counterZ,whatlookfor;
   int shift,back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;

   if (counted_bars==0 && downloadhistory) // history was downloaded
     {
      ArrayInitialize(ZigzagBuffer,0.0);
      ArrayInitialize(HighMapBuffer,0.0);
      ArrayInitialize(LowMapBuffer,0.0);
     }
   if (counted_bars==0) 
     {
      limit=Bars-ExtDepth;
      downloadhistory=true;
     }
   if (counted_bars>0) 
     {
      while (counterZ<level && i<100)
        {
         res=ZigzagBuffer[i];
         if (res!=0) counterZ++;
         i++;
        }
      i--;
      limit=i;
      if (LowMapBuffer[i]!=0) 
        {
         curlow=LowMapBuffer[i];
         whatlookfor=1;
        }
      else
        {
         curhigh=HighMapBuffer[i];
         whatlookfor=-1;
        }
      for (i=limit-1;i>=0;i--)  
        {
         ZigzagBuffer[i]=0.0;  
         LowMapBuffer[i]=0.0;
         HighMapBuffer[i]=0.0;
        }
     }
      
   for(shift=limit; shift>=0; shift--)
     {
      val=Low[iLowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=LowMapBuffer[shift+back];
               if((res!=0)&&(res>val)) LowMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      if (Low[shift]==val) LowMapBuffer[shift]=val; else LowMapBuffer[shift]=0.0;
      //--- high
      val=High[iHighest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=HighMapBuffer[shift+back];
               if((res!=0)&&(res<val)) HighMapBuffer[shift+back]=0.0; 
              } 
           }
        }
      if (High[shift]==val) HighMapBuffer[shift]=val; else HighMapBuffer[shift]=0.0;
     }

   // final cutting 
   if (whatlookfor==0)
     {
      lastlow=0;
      lasthigh=0;  
     }
   else
     {
      lastlow=curlow;
      lasthigh=curhigh;
     }
   for (shift=limit;shift>=0;shift--)
     {
      res=0.0;
      bool OutOfForLoop=False;
      switch(whatlookfor)
        {
         case 0: // look for peak or lawn 
            if (lastlow==0 && lasthigh==0)
              {
               if (HighMapBuffer[shift]!=0)
                 {
                  lasthigh=High[shift];
                  lasthighpos=shift;
                  whatlookfor=-1;
                  ZigzagBuffer[shift]=lasthigh;
                  res=1;
                 }
               if (LowMapBuffer[shift]!=0)
                 {
                  lastlow=Low[shift];
                  lastlowpos=shift;
                  whatlookfor=1;
                  ZigzagBuffer[shift]=lastlow;
                  res=1;
                 }
              }
             break;  
         case 1: // look for peak
            if (LowMapBuffer[shift]!=0.0 && LowMapBuffer[shift]<lastlow && HighMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lastlowpos]=0.0;
               lastlowpos=shift;
               lastlow=LowMapBuffer[shift];
               ZigzagBuffer[shift]=lastlow;
               res=1;
              }
            if (HighMapBuffer[shift]!=0.0 && LowMapBuffer[shift]==0.0)
              {
               lasthigh=HighMapBuffer[shift];
               lasthighpos=shift;
               ZigzagBuffer[shift]=lasthigh;
               whatlookfor=-1;
               res=1;
              }   
            break;               
         case -1: // look for lawn
            if (HighMapBuffer[shift]!=0.0 && HighMapBuffer[shift]>lasthigh && LowMapBuffer[shift]==0.0)
              {
               ZigzagBuffer[lasthighpos]=0.0;
               lasthighpos=shift;
               lasthigh=HighMapBuffer[shift];
               ZigzagBuffer[shift]=lasthigh;
              }
            if (LowMapBuffer[shift]!=0.0 && HighMapBuffer[shift]==0.0)
              {
               lastlow=LowMapBuffer[shift];
               lastlowpos=shift;
               ZigzagBuffer[shift]=lastlow;
               whatlookfor=1;
              }   
            break;               
         default: OutOfForLoop=True; 
        }
        if(OutOfForLoop) break;
     }
     //////////////////
     if(counted_bars<1)
     {
       DelObj();     
       limit = Bars-1;
     }
     else limit = 0;
     for(i = limit; i>=0; i--)
     {
     int k = i;
     double zz;
     double d1=0,d2=0,d3=0;
     datetime t1=0,t2=0,t3=0;
     while(k<Bars-2)
     {
       zz = ZigzagBuffer[k];
       if(zz!=0)
       {         
         d1 = d2; d2 = d3; d3 = zz;
         t1 = t2; t2 = t3; t3 = Time[k];
       }
       if(d1>0) break;
       k++;  
     }
     if(d1==0) continue;
     double LabelPos;
     int ib = iBarShift(NULL,0,t1);
     if(d1>d2) LabelPos = NormalizeDouble(High[ib]+0.5*iATR(NULL,0,10,ib),Digits);
     else LabelPos = Low[ib];
     string ObjName = "ZZLabel_Leg1";
     if(ObjectFind(ObjName)<0)
       ObjectCreate(ObjName,OBJ_TEXT,0,t1,LabelPos);
     else
       ObjectMove(ObjName,0,t1,LabelPos);
     ObjectSetText(ObjName,DoubleToStr(MathAbs(d2-d1)/Pip,1),10,"Arial",Yellow);       
     //////////////////////
     if(i==0)
     {
     LabelPos = Close[0];
     ObjName = "ZZLabel_Bid";
     int rOffset = 5*Period()*60;
     if(ObjectFind(ObjName)<0)
       ObjectCreate(ObjName,OBJ_TEXT,0,Time[0]+rOffset,LabelPos);
     else
       ObjectMove(ObjName,0,Time[0]+rOffset,LabelPos);                   
     ObjectSetText(ObjName,DoubleToStr(MathAbs(Close[0]-d1)/Pip,1),10,"Arial",Yellow);     
     }
     //////////////////////     
     ib = iBarShift(NULL,0,t2);
     if(d2>d3) LabelPos = NormalizeDouble(High[ib]+0.5*iATR(NULL,0,10,ib),Digits);
     else LabelPos = Low[ib];
     ObjName = "ZZLabel"+t1;
     if(ObjectFind(ObjName)<0)
     {
       ObjectCreate(ObjName,OBJ_TEXT,0,t2,LabelPos);
       ObjectSetText(ObjName,DoubleToStr(MathAbs(d3-d2)/Pip,1),10,"Arial",Yellow);
     }     
     }
     //////////////////

   return(0);
  }
//+------------------------------------------------------------------+