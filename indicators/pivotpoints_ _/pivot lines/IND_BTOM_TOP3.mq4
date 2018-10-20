//+------------------------------------------------------------------+
//|                                                 IND_BTOM_TOP.mq4 |
//|                                                 kaposuke         |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "kaposuke"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Pink
//---- input parameters
extern int       ExtParam1=20;

extern int       period1=1000;
int TYOUSEI;
//---- buffers
double ExtMapBuffer1[];

double top1[2][300];
double bom1[2][300];
double kinsa1[100];
double kinsa2[100];
double hanpatu[100];
double geraku[100];
double rakusa[100];
double jousyou[100];
double topsa[100];
double bomsa[100];
double tb[3][100];
double ayumi[100];
int top1_sort[300];
int bom1_sort[300];
int tb_kankaku[100];
double ne[300];
double ka[300];
double hi1=0,low1=9999;
int top_period[100];
int bom_period[100];
int top_period_max;
int top_period_min;
int top_period_mid;
int bom_period_max;
int bom_period_min; 
int bom_period_mid; 
datetime vari1,vari2;
int b1=0,b2=0;
// ÉfÅ[É^éÊèoóp
int baio;

   int hanten=1;
   int kaesi1=0,kaesi2=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int deinit(){
 ObjectsDeleteAll(0,OBJ_LABEL);
ObjectsDeleteAll(0,OBJ_HLINE);
ObjectsDeleteAll(0,OBJ_CYCLES);
    return(0);
  } 
int init()
  {
  int x;
//---- indicators
   IndicatorBuffers(1);                   // ÉoÉbÉtÉ@Å[å¬êîíËã`
   SetIndexStyle(0,1,1,2);                    //Å@ê¸ÇÃï`Ç≠éÌóﬁ,ê¸éÌ
   SetIndexBuffer(0,ExtMapBuffer1);

   SetIndexEmptyValue(0,0.0);             // 0.0ÇîÒï\é¶
 
 x=Period();
 //ob_hyouji(999999,"Period"   ,Period(),500 ,520,Blue);
 
 //Å@Å@ï\é¶ë´Ç…Ç†ÇÌÇπÇÈÅ@ÉgÉbÉvÅïÉ{ÉgÉÄÇÃêÆóùóp
switch(x){
   case 1:   
            baio=15;  break;             
   case 5:   
            baio=20;  break;
   case 15:  
            baio=30;  break;
   case 30:  
            baio=30;  break;
   case 60:  
            baio=30; break;
   case 240:  
            baio=40; break;
   case 1440: 
            baio=50; break;
              
   } 
 
TYOUSEI=baio;

   return(0);
   
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  double pip1,mid,hihi,lowlow;
  int i;
  bool pp;
  int to1=0;
  int bo1=0;

  ArrayInitialize(ExtMapBuffer1,0.0); 
  ArrayInitialize(top1,0.0);
  ArrayInitialize(bom1,0.0); 
 
   hi1=High[1];
   low1=Low[1]; 
           
    lowlow=Low [iLowest (NULL, 0, MODE_LOW, ExtParam1,1)];
    hihi=  High[iHighest(NULL, 0, MODE_HIGH,ExtParam1,1)];
    mid=(lowlow+hihi)/2; 
    
      if(Close[1]>lowlow){hanten=-1;}
      if(Close[1]<=hihi  ){hanten=1; }
      
  for(i=1; i<period1; i++) {
    lowlow=Low [iLowest (NULL, 0, MODE_LOW, ExtParam1,i+1)];
    hihi=  High[iHighest(NULL, 0, MODE_HIGH,ExtParam1,i+1)];
    mid=(lowlow+hihi)/2;
     
         if (hanten==-1){
                 if (hi1<=High[i+1]){
                     hi1=High[i+1];
                     kaesi1=iHighest(NULL, 0, MODE_HIGH,1, i+1);
                  }  
                      else if (Low[iLowest(NULL, 0, MODE_LOW,ExtParam1,i+1)]>Low[i] &&
                              Close[i]<mid){
                              low1=Low[i];
                              kaesi2=iLowest(NULL, 0, MODE_LOW,1, i);
                              hanten=1;
                              top1[0][to1]=hi1;
                              top1[1][to1]=kaesi1;
                              ExtMapBuffer1[kaesi1] =hi1;  
                              hi1=0;  
                              to1+=1;
                        }
         }    
         if(hanten==1){
         
                  if (low1>=Low[i+1]){
                        low1=Low[i+1];
                        kaesi2=iLowest(NULL, 0, MODE_LOW,1, i+1);
                     }    
         
                  else if (High[iHighest(NULL, 0, MODE_HIGH,ExtParam1, i+1)]<High[i] &&
                          Close[i]>mid){
                            hi1=High[i];
                            kaesi1=iHighest(NULL, 0, MODE_HIGH,1, i);               
                                 hanten=-1;
                                 bom1[0][bo1]=low1;
                                 bom1[1][bo1]=kaesi2;                                                                 
                                 ExtMapBuffer1[kaesi2] =low1;  
                                  low1=999999;                             
                                 bo1+=1;
                        }
                          
         }

 }
 if(top1[1][0]>top1[1][1]){top1[1][0]=0;}

   //kankaku(to1,bo1);
    hibo(to1,bo1);
   moji(to1,bo1);
  ob_zukei(tb); 
  // jikai_teiko(); 
  // ci1();           
   return(0);
  }
//+------------------------------------  ï∂éöÉIÉuÉWÉFÉNÉgçÏê¨    -------- ---------------+
void  ob_hyouji(double ss,string com1,string com2,int x,int y,int ss2){
        string mm;
        mm=StringConcatenate("Obj",DoubleToStr(ss,0));
        ObjectDelete(mm);  
        ObjectCreate (mm, OBJ_LABEL,0, 0, 0);
        ObjectSetText(mm,com1 +"  " + com2 ,13, "ÇlÇr ñæí©",ss2);    
        ObjectSet(mm, OBJPROP_CORNER, 0);
        ObjectSet(mm, OBJPROP_XDISTANCE, x);
        ObjectSet(mm, OBJPROP_YDISTANCE, y); 
   }  
//+------------------------------------- â°ê¸Å@íÔçRê¸åR *-----------------------------------
void ob_zukei(double sen[][]){
int iro,haba;
   for(int i=0;i<ArraySize(sen);i++){
        ObjectCreate("MyTa"+ExtParam1+i, OBJ_HLINE, 0, 0, 0, 0, 0);    
        ObjectSet("MyTa"+ExtParam1+i, OBJPROP_PRICE1, sen[0][i]);
        if(ka[i]<=2){iro=Pink;haba=1;}
        if(ka[i]>=3){iro=Magenta;haba=2;}
        if(ka[i]>=5){iro=Red;haba=4;}
        if(sen[1][i]>9){haba=9;}
        else{haba=sen[1][i];}             
        ObjectSet("MyTa"+ExtParam1+i, OBJPROP_COLOR, iro); 
        ObjectSet("MyTa"+ExtParam1+i, OBJPROP_WIDTH, haba); 
        }
}
//Å---------------------------------------éüâÒíÔçRë—ÉuÉbÉçÉNê}Å@Å@Å@Å@â¸ó«óvÇ∑
void jikai_teiko(){
int i,iro,haba,tate;
int mai2=top1[1][0];
int mai1=bom1[1][0];
                              //Å@è„ílíÔçRë—
if((mai2-top_period_min)>0){
        ObjectCreate("MyTop", OBJ_RECTANGLE, 0, 0, 0, 0, 0);    
        ObjectSet("MyTop", OBJPROP_TIME1, Time[mai2-top_period_min]);
        ObjectSet("MyTop", OBJPROP_PRICE1,top1[0][0]-(5*Point));     
        ObjectSet("MyTop", OBJPROP_TIME2, Time[0]);
        ObjectSet("MyTop", OBJPROP_PRICE2,top1[0][0]+(5*Point));           
        ObjectSet("MyTop", OBJPROP_COLOR, Pink); 
        ObjectSet("MyTop", OBJPROP_BACK, true); 
   }
   
if((mai2-top_period_min)<0){ObjectDelete("MyTop");}// è¡ãé
                              //  â∫ílíÔçRëÃ
if((mai1-bom_period_min)>0){ 
        ObjectCreate("Mybop", OBJ_RECTANGLE, 0, 0, 0, 0, 0);    
        ObjectSet("Mybop", OBJPROP_TIME1, Time[mai1-bom_period_min]);
        ObjectSet("Mybop", OBJPROP_PRICE1,bom1[0][0]-(5*Point));     
        ObjectSet("Mybop", OBJPROP_TIME2, Time[0]);
        ObjectSet("Mybop", OBJPROP_PRICE2,bom1[0][0]+(5*Point));           
        ObjectSet("Mybop", OBJPROP_COLOR, Blue); 
        ObjectSet("Mybop", OBJPROP_BACK, true);
        ob_hyouji(1000,"mai1-bom_period_min"   ,mai1-bom_period_min,400 ,500,Aqua);
   } 
if((mai1-bom_period_min)<0){ObjectDelete("Mybop");}    
   
}
//+++++++++++++++++++++++++++++   ª≤∏Ÿ◊≤›Å@+++++++++++++++++++++++++++++++++++
void ci1(){

  int mai1=bom1[1][1];
  bool hh;
        hh=ObjectCreate("Myc1", OBJ_CYCLES, 0, 0, 0, 0, 0);    
        ObjectSet("Myc1", OBJPROP_TIME1, Time[mai1]);   
        ObjectSet("Myc1", OBJPROP_TIME2, Time[mai1-13]);        
        ObjectSet("Myc1", OBJPROP_COLOR, Blue); 
ob_hyouji(99999,"h"   ,hh,500 ,500,Blue);
}
//+------------------------------------------------------------------+

void moji(int top,int bom){
int i;
int uu;

uu=top+bom;
ob_hyouji(9000 ,"uu" ,uu                 ,11 ,10,Yellow);
         for(i=0;i<uu;i++){
             
     // ob_hyouji(10+i  ,"TOP"+i    ,DoubleToStr(top1[0][i],Digits),10   ,50+(20*i),Red);
     // ob_hyouji(100+i ,"BOM"+i    ,DoubleToStr(bom1[0][i],Digits),150  ,50+(20*i),Red);
      //ob_hyouji(200+i ,"TOP_No."  ,DoubleToStr(top1[1][i],0)     ,300  ,50+(20*i),Aqua);  
      //ob_hyouji(300+i ,"BOM_No."  ,DoubleToStr(bom1[1][i],0)     ,450  ,50+(20*i),Aqua); 
      //ob_hyouji(400+i ,"TOP_ä‘äu" ,top_period[i]                 ,600  ,50+(20*i),White); 
      //ob_hyouji(2000+i,"BOM_ä‘äu" ,bom_period[i]                 ,750  ,50+(20*i),White);
      //ob_hyouji(500+i ,"Zigzag"   ,tb_kankaku[i]                 ,870  ,50+(20*i),White);
      //ob_hyouji(3000+i,"ílìÆ"     ,DoubleToStr(kinsa1[i],Digits) ,1000 ,50+(20*i),White);
      //ob_hyouji(5000+i,"ï‡"       ,ayumi[i]                      ,1100 ,50+(20*i),White);
      //ob_hyouji(900+i ,"TOP_sort" ,top1_sort [i]                 ,1250 ,50+(20*i),Yellow); 
       
      //ob_hyouji(3000+i,"TOP-BOM"     ,DoubleToStr(rakusa[i],Digits)  ,300 ,50+(20*i),White); 
      //ob_hyouji(4000+i,"BOM-TOP"     ,DoubleToStr(jousyou[i],Digits)  ,450 ,50+(20*i),White);
     // ob_hyouji(5000+i,"îΩî≠%"     ,DoubleToStr(hanpatu[i],Digits)  ,600 ,50+(20*i),White);
      //ob_hyouji(6000+i,"â∫óé%"     ,DoubleToStr(geraku[i],Digits)   ,750 ,50+(20*i),White); 
     // ob_hyouji(7000+i,"B-B"     ,DoubleToStr(bomsa[i],Digits)   ,900 ,50+(20*i),White);
                     
        } 
     // ob_hyouji(1000,"TOP_PERIOD_MAX"   ,top_period_max,10 ,700,Aqua);
    //  ob_hyouji(1001,"TOP_PERIOD_MIN"   ,top_period_min,10 ,720,Aqua);
    //  ob_hyouji(1002,"TOP_PERIOD_MID"   ,bom_period_mid,10 ,740,Aqua); 
    //  ob_hyouji(1003,"BTM_PERIOD_MAX"   ,bom_period_max,10 ,760,Aqua);
    //  ob_hyouji(1004,"BTM_PERIOD_MIN"   ,bom_period_min,10 ,780,Aqua);
    //  ob_hyouji(1005,"BTM_PERIOD_MID"   ,bom_period_mid,10 ,800,Aqua); 
                      
} 
  
void kankaku(int top,int bom){
   int i,ii=0;
   int x,xx;
   ArrayResize(top_period,top-1);
   ArrayResize(bom_period,bom-1);
   ArrayInitialize(top_period,0.0);
   ArrayInitialize(bom_period,0.0);
   ArrayResize(top1_sort,top-1);
   ArrayResize(bom1_sort,bom-1);
   ArrayInitialize(top1_sort,0.0);
   ArrayInitialize(bom1_sort,0.0);
   ArrayInitialize(kinsa1,0.0);
   ArrayInitialize(kinsa2,0.0); 
   ArrayInitialize(tb_kankaku,0.0);
   ArrayInitialize(ayumi,0.0);

     
   top_period_max=0;
   top_period_min=0;
   bom_period_max=0;
   bom_period_min=0;   

   //Å@ÇsÇnÇoÅ`ÇsÇnÇoä˙ä‘ïù
   for(i=0;i<top;i++){
                        tb_kankaku[i]=bom1[1][i]-top1[1][i];                        
                        top_period[i]=top1[1][i+1]-top1[1][i];                        
                        topsa [i]=top1[0][i+1]-top1[0][i];
                        rakusa[i]=top1[0][i]  -bom1[0][i];                     
                      }
   ArrayCopy(top1_sort,top_period); //É\Å[ÉgópÇ…å≥ÉfÅ[É^ÇÉRÉsÅ[
   
   //Å@TOPÅ`TOPä˙ä‘É\Å[ÉgÅ@
   ArraySort(top1_sort,WHOLE_ARRAY,0,MODE_ASCEND);
   x=ArrayMaximum(top1_sort);                         //TOP-MAX îzóÒî‘çÜ
   xx=ArrayMinimum(top1_sort);                        //TOP-MIN îzóÒî‘çÜ
   top_period_max=top1_sort[x];                       //ÇsÇnÇoîzóÒÇlÇ`Çw
   top_period_min=top1_sort[xx];                      //ÇsÇnÇoîzóÒÇlÇhÇm
   top_period_mid=(top_period_min+top_period_max)/2;  //ÇsÇnÇoîzóÒÇlÇhÇc
   
   //ÇaÇnÇsÇnÇlÅ`ÇaÇnÇsÇnÇlä˙ä‘ïù
   
   for(i=0;i<bom;i++){
                        bom_period[i]=bom1[1][i+1]-bom1[1][i];
                        bomsa [i]=bom1[0][i]-bom1[0][i+1];
                        jousyou[i]=top1[0][i+1]-bom1[0][i];
                       
                        hanpatu[i]=(bomsa[i]/rakusa[i+1])*100;
                      //  geraku [i]=kinsa1[i+1]/rakusa[i];
                        
                        }
   ArrayCopy(bom1_sort,bom_period);
   //ÇaÇnÇsÇnÇlÅ`ÇaÇnÇsÇnÇlä˙ä‘É\Å[Ég
   ArraySort(bom1_sort,WHOLE_ARRAY,0,MODE_ASCEND);   
   x=ArrayMaximum(bom1_sort,top,0);
   xx=ArrayMinimum(bom1_sort,top,0);
   bom_period_max=bom1_sort[x];                       //BOTOM-MAX
   bom_period_min=bom1_sort[xx];                      //BOTOM-MIN
   bom_period_mid=(bom_period_max+bom_period_min)/2;  //BOTOM-MID
  

   
}
  //********************************************************* ÉqÉ{ÉiÉbÉ`ÉfÅ[É^ópÅïÉ_ÉEóùò_óp
void hibo(int top,int bom){  
int i,ii;
double ne[1000],zan,zan2,zan10,kari,tyo;
tyo=TYOUSEI*Point;
zan=0;
   ArrayResize(tb,top+bom);
   ArrayResize(ne,top+bom); 
   ArrayInitialize(tb,0.0);
   ArrayInitialize(ne,0.0);
   // TOP-BOTOM ÉfÅ[É^åãçá
   for(i=0;i<top;i++){ne[i]=top1[0][i];}                       //çÇílÉRÉsÅ[
   for(i=top,ii=0;i<=top+bom+2;i++,ii++){ne[i]=bom1[0][ii];}   //à¿ílí«â¡ÉRÉsÅ[
  
   ArraySort(ne,WHOLE_ARRAY,0,MODE_ASCEND);                    //åãçáÉfÅ[É^ÇÃÉ\Å[Ég
   
   //Å@ÉfÅ[É^èdï°í≤êÆ
   ii=0;
   int ss=0;
   for (i=0;i<ArraySize(ne);i++){
   if(kari+tyo<ne[i]){kari=ne[i];tb[0][ii]=ne[i];ii++;ss=ii;}
   if(ss==ii){tb[1][ii]++;}
   }
/*   //Å@ämîFóp ï\é¶  
for (i=0;i<ArraySize(tb);i++){
 ob_hyouji(8000+i,"BT"+i     ,DoubleToStr(tb[i],Digits)   ,100 ,20+(20*i),White);
 ob_hyouji(9000+i,"NE"+i     ,DoubleToStr(ne[i],Digits)   ,200 ,20+(20*i),White);
}
*/
}

