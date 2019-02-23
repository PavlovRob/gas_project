uses crt;
const
  numiterations=132000;sz1=40;sz2=150;maxner=140;lymda=266;k1=0.05;k2=0.0006;k3=0.5;k4=0.9995;Agemax=75;
var
  fout:text;
  fff,mmm,fl2,k,ii,ff,NewNer,et2,i,j,x,y,in1,in2,N,t,MaxLocErrIn1, MaxLocErrIn2,NumNer,fl,r:integer;
  x1,x2,y1,y2,x3,x4,y3,y4:integer;
  x11,x22,y11,y22,x33,x44,y33,y44:integer;
  x111,x222,y111,y222,x333,x444,y333,y444:integer;
  x1111,x2222,y1111,y2222,x3333,x4444,y3333,y4444:integer;
  x11111,x22222,y11111,y22222,x33333,x44444,y33333,y44444:integer;
  x111111,x222222,y111111,y222222,x333333,x444444,y333333,y444444:integer;
  x1111111,x2222222,y1111111,y2222222,x3333333,x4444444,y3333333,y4444444:integer;
  min1,min2,et1,MaxLocErr1, MaxLocErr2,m:real;
  FirstNerInCluster:integer;
  xx,yy,xxx,yyy,totaldist,dist,distmin,minx,miny,maxx,maxy:real;
  P:array [1..sz1,1..sz2] of char;  
  Ner:array [1..maxner,1..4] of real;// Ner[i,1] Ner[i,2] are X and Y koordinates of neuron i. Ner[i,3] "Local error" neuron i in terms of algoritm. IMPOTANT: Ner[i,3]=-2 if neuron i died.
  Nodes:array [1..maxner,1..maxner] of integer; // Nodes[i,j]=-1 if no node between i and j neurons, otherwise Node[i,j]=Age of node between i and j neurons.
  NumClusters:integer; // Total Number of Clusters.   
  NumNerInCluster:array[1..maxner] of integer; // How much neurons in cluster with index i.
  Clusters: array[1..maxner,1..maxner] of integer; // Numbers of neurons in cluster with index i.
  MinXAndMinYInCluster:array[1..maxner,1..4] of real; // 1 and 2 Koordinates X and Y of left upper coner in cluster with index i. 3 and 4 Koordinates X and Y of rigth down coner in cluster with index i.
  NumClusterType:integer; // How much type of clusters.
  ClusterDistance:array[1..maxner,1..maxner] of real; // Distances after norming between clusters i and j.
  NumClustInType:array[1..maxner] of integer; // How much clusters in type with index i.
  NumClustOnType:array[1..maxner,1..maxner] of integer; // Numbers of clusters in cluster type with index i.
procedure SetInputSignals;
begin
     x1:=2;x2:=30;    x11:=50;x22:=88;              x111:=110;x222:=143;
     y1:=3;y2:=3;     y11:=4;y22:=4;                y111:=2;y222:=2;    
     x3:=3;x4:=31;    x33:=51;x44:=89;              x333:=111;x444:=144;
     y3:=9;y4:=9;   y33:=17;y44:=17;                y333:=8;y444:=8;

  x1111:=2;x2222:=30;    x11111:=47;x22222:=74;  x111111:=110;x222222:=142;
  y1111:=9;y2222:=9;   y11111:=25;y22222:=25;    y111111:=8;y222222:=8;    
  x3333:=3;x4444:=31;    x33333:=48;x44444:=75;  x333333:=111;x444444:=143;
  y3333:=15;y4444:=15;   y33333:=38;y44444:=38;  y333333:=14;y444444:=14;

  x1111111:=90;x2222222:=120;
  y1111111:=25;y2222222:=25;    
  x3333333:=91;x4444444:=121;
  y3333333:=39;y4444444:=39;

end;

procedure PutNeuronsAndInputSignalsToArrayForOutputToScreen;
var
  i,j:integer;
begin
  for i:=1 to sz1 do  
    for j:=1 to sz2 do 
      P[i,j]:=' ';


  for i:=y1 to y2 do
    for j:=x1 to x2 do
      p[i,j]:='0';
  for i:=y3 to y4 do
    for j:=x3 to x4 do
      p[i,j]:='0';
  for i:=y1 to y3 do
    for j:=x1 to x3 do
      p[i,j]:='0';
  for i:=y2 to y4 do
    for j:=x2 to x4 do
      p[i,j]:='0';

  for i:=y11 to y22 do
    for j:=x11 to x22 do
      p[i,j]:='0';
  for i:=y33 to y44 do
    for j:=x33 to x44 do
      p[i,j]:='0';
  for i:=y11 to y33 do
    for j:=x11 to x33 do
      p[i,j]:='0';
  for i:=y22 to y44 do
    for j:=x22 to x44 do
      p[i,j]:='0';

  for i:=y111 to y222 do
    for j:=x111 to x222 do
      p[i,j]:='0';
  for i:=y333 to y444 do
    for j:=x333 to x444 do
      p[i,j]:='0';
  for i:=y111 to y333 do
    for j:=x111 to x333 do
      p[i,j]:='0';
  for i:=y222 to y444 do
    for j:=x222 to x444 do
      p[i,j]:='0';

  for i:=y1111 to y2222 do
    for j:=x1111 to x2222 do
      p[i,j]:='0';
  for i:=y3333 to y4444 do
    for j:=x3333 to x4444 do
      p[i,j]:='0';
  for i:=y1111 to y3333 do
    for j:=x1111 to x3333 do
      p[i,j]:='0';
  for i:=y2222 to y4444 do
    for j:=x2222 to x4444 do
      p[i,j]:='0';

  for i:=y11111 to y22222 do
    for j:=x11111 to x22222 do
      p[i,j]:='0';
  for i:=y33333 to y44444 do
    for j:=x33333 to x44444 do
      p[i,j]:='0';
  for i:=y11111 to y33333 do
    for j:=x11111 to x33333 do
      p[i,j]:='0';
  for i:=y22222 to y44444 do
    for j:=x22222 to x44444 do
      p[i,j]:='0';

  for i:=y111111 to y222222 do
    for j:=x111111 to x222222 do
      p[i,j]:='0';
  for i:=y333333 to y444444 do
    for j:=x333333 to x444444 do
      p[i,j]:='0';
  for i:=y111111 to y333333 do
    for j:=x111111 to x333333 do
      p[i,j]:='0';
  for i:=y222222 to y444444 do
    for j:=x222222 to x444444 do
      p[i,j]:='0';

  for i:=y1111111 to y2222222 do
    for j:=x1111111 to x2222222 do
      p[i,j]:='0';
  for i:=y3333333 to y4444444 do
    for j:=x3333333 to x4444444 do
      p[i,j]:='0';
  for i:=y1111111 to y3333333 do
    for j:=x1111111 to x3333333 do
      p[i,j]:='0';
  for i:=y2222222 to y4444444 do
    for j:=x2222222 to x4444444 do
      p[i,j]:='0';

  for i:=1 to maxner do
   if (Ner[i,3]>-2) then P[round(Ner[i,2]),round(Ner[i,1])]:='*';

end;
procedure OutputNeuronsAndInputSignals;
var
  i,j:integer;
begin
  clrscr;
  for i:=1 to sz1 do begin
    for j:=1 to sz2 do begin
      write(fout,P[i,j]);
      write(P[i,j]);
    end;
    writeln(fout);
    writeln;
  end; 
  for i:=1 to maxner do begin
    write(i,' ',Ner[i,3]:6:2,' ',Ner[i,4],' ');
    write(fout,i,' ',Ner[i,3]:6:2,' ',Ner[i,4],' ');
    if i mod 10 =0 then begin
      writeln;
      writeln(fout);
    end;
  end;
  readln();
end;
procedure OutputClusteringResult;
var
  i,j:integer;
begin
    writeln('Number of Clusters= ',NumClusters);
    writeln(fout,'Number of Clusters= ',NumClusters);
    for j:=1 to NumClusters do begin
      writeln('Number neurons in cluster ',j,'  ',NumNerInCluster[j]);
      writeln(fout,'Number neurons in cluster ',j,'  ',NumNerInCluster[j]);
      for i:=1 to NumNerInCluster[j] do begin
        write(Clusters[j,i],' ');
        write(fout,Clusters[j,i],' ');
      end;
      writeln;
      writeln(fout);
    end;
    readln;
end;
procedure GetRandomInputSignal(var ff:integer; var x,y:integer);
begin
    if ff mod mmm =0 then begin
      ff:=ff+1;
      x:=x1+random(x2-x1);
      y:=y1+random(y2-y1);
    end
    else if ff mod mmm =1 then begin
      ff:=ff+1;
      x:=x3+random(x4-x3);
      y:=y3+random(y4-y3);
    end
    else if ff mod mmm =2 then begin
      ff:=ff+1;
      x:=x1+random(x3-x1);
      y:=y1+random(y3-y1);
    end
    else if ff mod mmm =3 then begin
      ff:=ff+1;
      x:=x2+random(x4-x2);
      y:=y2+random(y4-y2);
    end

    else if ff mod mmm =4 then begin
      ff:=ff+1;
      x:=x11+random(x22-x11);
      y:=y11+random(y22-y11);
    end
    else if ff mod mmm =5 then begin
      ff:=ff+1;
      x:=x33+random(x44-x33);
      y:=y33+random(y44-y33);
    end
    else if ff mod mmm =6 then begin
      ff:=ff+1;
      x:=x11+random(x33-x11);
      y:=y11+random(y33-y11);
    end
    else if ff mod mmm =7 then begin
      ff:=ff+1;
      x:=x22+random(x44-x22);
      y:=y22+random(y44-y22);
    end

    else if ff mod mmm =8 then begin
      ff:=ff+1;
      x:=x111+random(x222-x111);
      y:=y111+random(y222-y111);
    end
    else if ff mod mmm =9 then begin
      ff:=ff+1;
      x:=x333+random(x444-x333);
      y:=y333+random(y444-y333);
    end
    else if ff mod mmm =10 then begin
      ff:=ff+1;
      x:=x111+random(x333-x111);
      y:=y111+random(y333-y111);
    end
    else if ff mod mmm =11 then begin
      ff:=ff+1;
      x:=x222+random(x444-x222);
      y:=y222+random(y444-y222);
    end

    else if ff mod mmm =12 then begin
      ff:=ff+1;
      x:=x1111+random(x2222-x1111);
      y:=y1111+random(y2222-y1111);
    end
    else if ff mod mmm =13 then begin
      ff:=ff+1;
      x:=x3333+random(x4444-x3333);
      y:=y3333+random(y4444-y3333);
    end
    else if ff mod mmm =14 then begin
      ff:=ff+1;
      x:=x1111+random(x3333-x1111);
      y:=y1111+random(y3333-y1111);
    end
    else if ff mod mmm =15 then begin
      ff:=ff+1;
      x:=x2222+random(x4444-x2222);
      y:=y2222+random(y4444-y2222);
    end

    else if ff mod mmm =16 then begin
      ff:=ff+1;
      x:=x11111+random(x22222-x11111);
      y:=y11111+random(y22222-y11111);
    end
    else if ff mod mmm =17 then begin
      ff:=ff+1;
      x:=x33333+random(x44444-x33333);
      y:=y33333+random(y44444-y33333);
    end
    else if ff mod mmm =18 then begin
      ff:=ff+1;
      x:=x11111+random(x33333-x11111);
      y:=y11111+random(y33333-y11111);
    end
    else if ff mod mmm =19 then begin
      ff:=ff+1;
      x:=x22222+random(x44444-x22222);
      y:=y22222+random(y44444-y22222);
    end

    else if ff mod mmm =20 then begin
      ff:=ff+1;
      x:=x111111+random(x222222-x111111);
      y:=y111111+random(y222222-y111111);
    end
    else if ff mod mmm =21 then begin
      ff:=ff+1;
      x:=x333333+random(x444444-x333333);
      y:=y333333+random(y444444-y333333);
    end
    else if ff mod mmm =22 then begin
      ff:=ff+1;
      x:=x111111+random(x333333-x111111);
      y:=y111111+random(y333333-y111111);
    end
    else if ff mod mmm =23 then begin
      ff:=ff+1;
      x:=x222222+random(x444444-x222222);
      y:=y222222+random(y444444-y222222);
    end

    else if ff mod mmm =24 then begin
      ff:=ff+1;
      x:=x1111111+random(x2222222-x1111111);
      y:=y1111111+random(y2222222-y1111111);
    end
    else if ff mod mmm =25 then begin
      ff:=ff+1;
      x:=x3333333+random(x4444444-x3333333);
      y:=y3333333+random(y4444444-y3333333);
    end
    else if ff mod mmm =26 then begin
      ff:=ff+1;
      x:=x1111111+random(x3333333-x1111111);
      y:=y1111111+random(y3333333-y1111111);
    end
    else if ff mod mmm =27 then begin
      ff:=ff+1;
      x:=x2222222+random(x4444444-x2222222);
      y:=y2222222+random(y4444444-y2222222);
    end;

end;
begin
  assign(fout,'OutputRobPr.txt');
  rewrite(fout);
  Randomize;
  for i:=1 to maxner do
    for j:=1 to maxner do begin
      Nodes[i,j]:=-1;
      Ner[i,3]:=-2;
      Ner[i,4]:=0;
    end;  
  NumNer:=2;
  for i:=1  to NumNer do begin
    Ner[i,1]:=1+random(sz2);
    Ner[i,2]:=1+random(sz1); 
    Ner[i,3]:=0;
  end;
  Nodes[1,2]:=0;
  Nodes[2,1]:=0;
  SetInputSignals;
  PutNeuronsAndInputSignalsToArrayForOutputToScreen;
  clrscr;  
  readln;
  OutputNeuronsAndInputSignals;
  mmm:=28;
  fff:=0;
  for t:=1 to numiterations do begin
    GetRandomInputSignal(fff,x,y);
    // First nearest neuron
    for i:=1 to MaxNer do
      if Ner[i,3]>-2 then in1:=i;
    min1:= (Ner[in1,1]-x)*(Ner[in1,1]-x) + (Ner[in1,2]-y)*(Ner[in1,2]-y);
    for i:=1 to maxner do begin
       if (Ner[i,3]>-2)then begin
         m:=(Ner[i,1]-x)*(Ner[i,1]-x) + (Ner[i,2]-y)*(Ner[i,2]-y);
         if (m<min1) then begin
           min1:=m;
           in1:=i;
         end
       end;  
    end; 
    // Second nearest neuron
    for i:=1 to maxner do
      if (Ner[i,3]>-2) and (i<>in1) then in2:=i;
    min2:=(Ner[in2,1]-x)*(Ner[in2,1]-x) + (Ner[in2,2]-y)*(Ner[in2,2]-y);
    for i:=1 to maxner do begin
      if (Ner[i,3]>-2) and (i<>in1) then begin 
         m:=(Ner[i,1]-x)*(Ner[i,1]-x) + (Ner[i,2]-y)*(Ner[i,2]-y);
         if (m<min2) then begin 
           min2:=m;
           in2:=i;
         end;
      end;  
    end;
    // Increase local error nearest neuron
    Ner[in1,3]:=Ner[in1,3]+min1;
    // Increase counter of usefull nearest neuron
    Ner[in1,4]:=Ner[in1,4]+1;
    // Set age connection between nearest and second nearest to zero
    Nodes[in1,in2]:=0;
    Nodes[in2,in1]:=0;
    // Increase all connections ages emanating from nearest neuron
    for i:=1 to maxner do 
      if (Ner[i,3]>-2) and  (Nodes[in1,i]>-1) then   begin
        Nodes[in1,i]:=Nodes[in1,i]+1;
        Nodes[i,in1]:=Nodes[in1,i];
      end;  
    // Improve position of nearest neuron
    Ner[in1,1]:=Ner[in1,1]-(k1*(Ner[in1,1]-x));
    Ner[in1,2]:=Ner[in1,2]-(k1*(Ner[in1,2]-y));
    // Improve positions of all neurons emanating from nearest neuron
    for i:=1 to maxner do
      if (Ner[i,3]>-2) and (Nodes[in1,i]>-1) then begin
        Ner[i,1]:=Ner[i,1]-(k2*(Ner[i,1]-x));
        Ner[i,2]:=Ner[i,2]-(k2*(Ner[i,2]-y));
      end; 
    // Deleting connections with age lager than AgeMax  
    for i:=1 to maxner do 
      for j:=1 to maxner do 
        if (Nodes[i,j]>=Agemax) then begin
          Nodes[i,j]:=-1;
          Nodes[j,i]:=-1;
        end;
    // Deleting neurons has no connections
    for i:=1 to maxner do begin
      fl:=0;
      for j:=1 to maxner do
        if (Nodes[i,j]<>-1) then fl:=1;
      if (fl=0) and (Ner[i,3]<>-2) then begin
        Ner[i,3]:=-2;
        Ner[i,4]:=0;
        numner:=numner-1;
      end;
    end;
 
    if t mod 9000 = 0 then begin
      PutNeuronsAndInputSignalsToArrayForOutputToScreen;
      OutputNeuronsAndInputSignals;
    end;      

    if (t mod lymda=0) and (NumNer < maxner)then begin
      // Deleting neurons not usefull enougth
      for i:=1 to maxner do begin
        if (Ner[i,4]=0) and (Ner[i,3]>-2) then begin
          Ner[i,3]:=-2;
          for j:=1 to maxner do begin
            Nodes[i,j]:=-1;
            Nodes[j,i]:=-1;
          end;
          numner:=numner-1;
        end;
      end;
      // Find neuron with max local error
      MaxLocErr1:=-2;
      for i:=1 to maxner do 
        if (Ner[i,3]> MaxLocErr1) then  begin 
          MaxLocErr1:=Ner[i,3];
          MaxLocErrIn1:=i;
        end;
      // Find neuron with max local error has connection with neuron with max local error
      MaxLocErr2:=-2;
      for i:=1 to maxner do begin
        if (Nodes[i,MaxLocErrIn1]>-1) then 
          if (Ner[i,3]> MaxLocErr2) then begin 
            MaxLocErr2:=Ner[i,3];
            MaxLocErrIn2:=i;
          end;  
      end;
      // Put new neuron in the middle between parents neurons
      //newner:=0;
      for i:=maxner downto 1 do
        if Ner[i,3]=-2 then newner:=i;
      //if newner=0 then newner:=numner+1;
      Ner[NewNer,1]:=(Ner[ MaxLocErrIn2,1]+ Ner[ MaxLocErrIn1,1])/2;
      Ner[NewNer,2]:=(Ner[ MaxLocErrIn2,2]+ Ner[ MaxLocErrIn1,2])/2;
      // Erase connection between parents neurons 
      Nodes[MaxLocErrIn2,MaxLocErrIn1]:=-1;
      Nodes[MaxLocErrIn1,MaxLocErrIn2]:=-1;
      // Set connection between new neuron and his parents 
      Nodes[MaxLocErrIn2,NewNer]:=0;
      Nodes[NewNer,MaxLocErrIn2]:=0;
      Nodes[MaxLocErrIn1,NewNer]:=0;
      Nodes[NewNer,MaxLocErrIn1]:=0;
      // Decrease local error of parents neurons  
      Ner[MaxLocErrIn1,3]:= (Ner[MaxLocErrIn1,3]*k3);
      Ner[MaxLocErrIn2,3]:= (Ner[MaxLocErrIn2,3]*k3);
      // Set local error of new neuron
      Ner[NewNer,3]:=((Ner[MaxLocErrIn2,3] +  Ner[MaxLocErrIn1,3])/ 2);
      // Don't forget increase numner
      NumNer:=NumNer+1;
    end;
    // Decrease local error of all neurons
    for i:=1 to maxner do
      if (Ner[i,3]>-2) then Ner[i,3]:=(Ner[i,3]*k4);
  end;
  PutNeuronsAndInputSignalsToArrayForOutputToScreen;
  OutputNeuronsAndInputSignals;
  // Clustering 
  // Use Nodes and during calculating made Nodes clean !!! it is not good !!!
  NumClusters:=0;
  fl2:=0;
  FirstNerInCluster:=1;
  while fl2=0 do begin
    inc(NumClusters);
    Clusters[NumClusters,1]:=FirstNerInCluster;
    NumNerInCluster[NumClusters]:=1;
    i:=1;
    while i <= NumNerInCluster[NumClusters] do begin
      k:=Clusters[NumClusters,i];
      for j:=1 to maxner do
        if Nodes[k,j]<>-1 then begin
          Nodes[k,j]:=-1;
          Nodes[j,k]:=-1;
          fl:=0;
          for ii:=1 to NumNerInCluster[NumClusters] do
            if j=Clusters[NumClusters,ii] then 
              fl:=1;
          if fl=0 then begin  
            inc(NumNerInCluster[NumClusters]);
            Clusters[NumClusters,NumNerInCluster[NumClusters]]:=j;
          end;
        end;
      i:=i+1;
    end;
    fl2:=1;
    for k:=maxner downto 1 do
      for  j:=1 to maxner do
        if Nodes[k,j]<>-1 then begin 
          fl2:=0;
          FirstNerInCluster:=k; 
        end;
  end;
  // End clustering
    
  // Output clustering result
  OutputClusteringResult;
  clrscr;
  for j:=1 to NumClusters do begin
    for i:=1 to NumNerInCluster[j] do begin
      gotoxy(round(Ner[Clusters[j,i],1]),round(Ner[Clusters[j,i],2]));
      write('*');
    end;
    readln;
  end;
  // End output clustering result 
    
  // Comparing clusters 
  if NumClusters > 1 then begin
    // First step: norming neurons in earch cluster
    for i:=1 to NumClusters do begin
      minx:=Ner[Clusters[i,1],1];
      miny:=Ner[Clusters[i,1],2];
      maxx:=Ner[Clusters[i,1],1];
      maxy:=Ner[Clusters[i,1],2];
      for j:=2 to NumNerInCluster[i] do begin
        if minx>Ner[Clusters[i,j],1] then minx:=Ner[Clusters[i,j],1];
        if miny>Ner[Clusters[i,j],2] then miny:=Ner[Clusters[i,j],2];
        if maxx<Ner[Clusters[i,j],1] then maxx:=Ner[Clusters[i,j],1];
        if maxy<Ner[Clusters[i,j],2] then maxy:=Ner[Clusters[i,j],2];
      end;
      MinXAndMinYInCluster[i,1]:=minx;
      MinXAndMinYInCluster[i,2]:=miny;
      MinXAndMinYInCluster[i,3]:=maxx-minx;
      MinXAndMinYInCluster[i,4]:=maxy-miny;
    end;
    // Second step: calculating distance between clusters
    for i:=1 to NumClusters do begin
      for j:=1 to NumClusters do begin
        if (i<>j) or (i=j) then begin
          totaldist:=0;
          for k:=1 to NumNerInCluster[i] do begin
            xx:=(Ner[Clusters[i,k],1]-MinXAndMinYInCluster[i,1])/MinXAndMinYInCluster[i,3];
            yy:=(Ner[Clusters[i,k],2]-MinXAndMinYInCluster[i,2])/MinXAndMinYInCluster[i,4];
            if i<>j then begin
              xxx:=(Ner[Clusters[j,1],1]-MinXAndMinYInCluster[j,1])/MinXAndMinYInCluster[j,3];
              yyy:=(Ner[Clusters[j,1],2]-MinXAndMinYInCluster[j,2])/MinXAndMinYInCluster[j,4];
            end
            else begin
              xxx:=(Ner[Clusters[j,k mod 2 + 1],1]-MinXAndMinYInCluster[j,1])/MinXAndMinYInCluster[j,3];
              yyy:=(Ner[Clusters[j,k mod 2 + 1],2]-MinXAndMinYInCluster[j,2])/MinXAndMinYInCluster[j,4];
            end;
            distmin:=(xxx-xx)*(xxx-xx)+(yyy-yy)*(yyy-yy);
            for ii:=2 to NumNerInCluster[j] do begin
              if i<>j then begin
                xxx:=(Ner[Clusters[j,ii],1]-MinXAndMinYInCluster[j,1])/MinXAndMinYInCluster[j,3];
                yyy:=(Ner[Clusters[j,ii],2]-MinXAndMinYInCluster[j,2])/MinXAndMinYInCluster[j,4];
                dist:=(xxx-xx)*(xxx-xx)+(yyy-yy)*(yyy-yy);
              end
              else if ii<>k then begin
                xxx:=(Ner[Clusters[j,ii],1]-MinXAndMinYInCluster[j,1])/MinXAndMinYInCluster[j,3];
                yyy:=(Ner[Clusters[j,ii],2]-MinXAndMinYInCluster[j,2])/MinXAndMinYInCluster[j,4];
                dist:=(xxx-xx)*(xxx-xx)+(yyy-yy)*(yyy-yy);
              end;
              if distmin>dist then distmin:=dist;
            end;
            totaldist:=totaldist+distmin;
          end;
          ClusterDistance[i,j]:=totaldist/NumNerInCluster[i];
        end;
      end;
    end;
   
    // Third step:
    // Distance between cluster i and j is max(ClusterDistance[i,j],ClusterDistance[j,i]);
    // Distance between i and i decrease on 30%
    for i:=1 to NumClusters do
      for j:=1 to NumClusters do
        if ClusterDistance[i,j]>ClusterDistance[j,i] then 
          ClusterDistance[j,i]:=ClusterDistance[i,j]
        else
          ClusterDistance[i,j]:=ClusterDistance[j,i];
    for i:=1 to NumClusters do
      ClusterDistance[i,i]:=ClusterDistance[i,i]*2/3; 
    // Output cluster distances
    writeln('Clusters distances');
    for i:=1 to NumClusters do begin
      for j:=1 to NumClusters do
        write(ClusterDistance[i,j]:8:5,' ');
      writeln;
    end;
    readln;
    // Last step: separate clusters on types
    NumClusterType:=0;
    for i:=1 to NumClusters do begin
      fl2:=0;
      for j:=1 to NumClusterType do
        for ii:=1 to NumClustInType[j] do
          if i=NumClustOnType[j,ii] then fl2:=1;
      if fl2=0 then begin
        fl:=0;
        ii:=1;
        for j:=i+1 to NumClusters do begin
          if ClusterDistance[i,j]<ClusterDistance[i,i] then begin
            if fl=0 then begin
              fl:=1;
              inc(NumClusterType);
              NumClustOnType[NumClusterType,1]:=i;
            end;
            ii:=ii+1;
            NumClustOnType[NumClusterType,ii]:=j;
          end;
        end;
        NumClustInType[NumClusterType]:=ii;
      end;
    end;
    // Output clusters on type
    writeln(NumClusterType,' Types of clusters');
    for i:=1 to NumClusterType do begin
      write('Type ',i,': Numbers of clusters ');
      for j:=1 to NumClustInType[i] do
        write(NumClustOnType[i,j],' ');
      writeln;
    end;
    readln;
    // End comparing
  end;
  close(fout);
end.  