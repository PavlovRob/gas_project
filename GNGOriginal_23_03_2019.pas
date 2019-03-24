// Version 23 03 2019
// Original algoritm Fritzke no additions
// Working and ready for optimization
// Made neurons net and use neurons as new data with function of probability of earch neuron to create finish neurons net
// Working with input files with spesial names 0_03_..... 
// Create two output files 
// ....A - file for next analiz with koordinats x y z, nodes between neurons, information about how usefull earch neuron  
// ....A_P - file for next analiz with polar koordinats, nodes between neurons, information about how usefull earch neuron
const
  // Main parameters of algoritm
  MaxNumIterations=500000;MaxNumNer=600;Lymbda=100;k1=0.2;k2=0.006;k3=0.5;k4=0.995;AgeMax=15;
type
  TypeInputSignal=array[1..3] of double;
var
  OutputFileForAnalizPolar,OutputFileForAnaliz,InputFile:text;
  TempStr:string;
  b:boolean;
  NumIteratVar:longint;
  FileCounter,NumberOfFiles:longint;
  InputFileName,OutputFileNameForDrawTogether,OutputFileNameForAnalizPolar,OutputFileNameForAnaliz:string;
  MaxNer,ccc,jj,DistDistDist,Flag2,ii,NewNer,i,j,MaxLocErrorIndex1, MaxLocErrorIndex2,Flag,k:longint;
  DistToNearest,DistToSecondNearest,MaxLocErr1,MaxLocErr2,Dist:double;
  IndexNearestNeuron,IndexSecondNearestNeuron,CountIterations,FirstNerInCluster:longint;
  minx,miny,minz,Pointx,Pointy,Pointz,maxx,maxy,maxz,Rx,Ry,Rz,RRx,RRy,RRz:double;
  a1,a2,a3,a5:double;
  a4:int64;
  InputSignal : TypeInputSignal;
  // Main impotant variables
  DataNum1,DataNum:longint;
  Data1,Data:array[1..500000,1..3] of double;
  NumNer:longint;
  // Number neurons during calculating 
  Ner:array [1..MaxNumNer,1..5] of double;
  // Ner[i,1] Ner[i,2] Ner[i,3] are X and Y and Z koordinates of neuron i.
  // Ner[i,4] "Local error" neuron i in terms of algoritm. IMPOTANT: Ner[i,4]=-2 if neuron i died.
  // Ner[i,5] count how much neuron i became nearest. 
  ND,Nodes:array [1..MaxNumNer,1..MaxNumNer] of integer; 
  // Nodes[i,j]=-1 if no node between i and j neurons, otherwise Node[i,j]=Age of node between i and j neurons.
  NumClusters:integer; 
  // Total Number of Clusters.
  NumNerInCluster:array[1..MaxNumNer] of integer; 
  // How much neurons in cluster with index i.
  Clusters: array[1..MaxNumNer,1..MaxNumNer] of integer; 
  // Clusters[i,j] Number of j neuron in cluster with index i.
procedure OutputNeurons;
var
  ii,i,j,nn:integer;
begin
  Writeln(OutputFileForAnaliz,NumNer);
  for i:=1 to MaxNer do 
    if Ner[i,4]>-2 then begin
      Write(OutputFileForAnaliz,i:4,ner[i,5]:7,' ',Ner[i,1],' ',Ner[i,2],' ',Ner[i,3]);
      nn:=0;
      for j:=1 to MaxNer do
        if Nodes[i,j]>-1 then inc(nn);
      Write(OutputFileForAnaliz,' ',nn);  
      for j:=1 to MaxNer do
        if Nodes[i,j]>-1 then Write(OutputFileForAnaliz,' ',j:4);
      Writeln(OutputFileForAnaliz);
    end; 
end;
procedure OutputNeuronsPolar;
var
  ii,i,j,nn:integer;
  tempvar,x,y,z,a1,a2,a3:double;
begin
  Writeln(OutputFileForAnalizPolar,NumNer);
  for i:=1 to MaxNer do 
    if Ner[i,4]>-2 then begin
      x:=Ner[i,1]/1;
      y:=Ner[i,2]/1;
      z:=Ner[i,3]/1;
      a3:=sqrt(sqr(x)+sqr(y)+sqr(z));
      a1:=0;
      a2:=0;
      if a3>0 then begin
        a2:=180/pi*arcsin(z/a3);
        tempvar:=arcsin(y/sqrt(sqr(x)+sqr(y)));
        if (x>0) and (y>=0) then
          a1:=180/pi*tempvar
        else if (x>0) and (y<0) then
          a1:=180/pi*(2*pi+tempvar)
        else a1:=180/pi*(pi-tempvar);
      end;
      Write(OutputFileForAnalizPolar,i:4,' ',ner[i,5]:7,' ',a1,' ',a2,' ',a3);
      nn:=0;
      for j:=1 to MaxNer do
        if Nodes[i,j]>-1 then inc(nn);
      Write(OutputFileForAnalizPolar,' ',nn);  
      for j:=1 to MaxNer do
        if Nodes[i,j]>-1 then Write(OutputFileForAnalizPolar,' ',j:4);
      Writeln(OutputFileForAnalizPolar);
    end; 
end;
procedure OutputNeuronsNew;
var
  i:integer;
  x,y,z,a1,a2,a3,tempvar:double;
begin
  for i:=1 to MaxNer do 
    if Ner[i,4]>-2 then begin
      x:=Ner[i,1]/1;
      y:=Ner[i,2]/1;
      z:=Ner[i,3]/1;
      a3:=sqrt(sqr(x)+sqr(y)+sqr(z));
      a1:=0;
      a2:=0;
      if a3>0 then begin
        a2:=180/pi*arcsin(z/a3);
        tempvar:=arcsin(y/sqrt(sqr(x)+sqr(y)));
        if (x>0) and (y>=0) then
          a1:=180/pi*tempvar
        else if (x>0) and (y<0) then
          a1:=180/pi*(2*pi+tempvar)
        else a1:=180/pi*(pi-tempvar);
      end;
      writeln(OutputFileForAnalizPolar,a1,chr(9),a2,chr(9),a3,chr(9),i,chr(9),random(16.9,18.4));
      //writeln(OutputFileForDrawTogether,a1,chr(9),a2,chr(9),a3,chr(9),i,chr(9),21);
    end; 
end;
procedure OutputData;
var
  i:integer;
  x,y,z,a1,a2,a3,tempvar:double;
begin
  for i:=1 to DataNum do begin 
      x:=Data[i,1]/1;
      y:=Data[i,2]/1;
      z:=Data[i,3]/1;
      a3:=sqrt(sqr(x)+sqr(y)+sqr(z));
      a1:=0;
      a2:=0;
      if a3>0 then begin
        a2:=180/pi*arcsin(z/a3);
        tempvar:=arcsin(y/sqrt(sqr(x)+sqr(y)));
        if (x>0) and (y>=0) then
          a1:=180/pi*tempvar
        else if (x>0) and (y<0) then
          a1:=180/pi*(2*pi+tempvar)
        else a1:=180/pi*(pi-tempvar);
      end;
      //writeln(OutputFileForDrawTogether,a1,chr(9),a2,chr(9),a3,chr(9),i,chr(9),21);
  end; 
end;
procedure GetInputSignal(t:longint;var InputSignal:TypeInputSignal);
var
  i,j:longint;
begin
  i:=1+random(DataNum);
  for j:=1 to 3 do
    InputSignal[j]:=Data[i,j];
end;
procedure OutputClusteringResult;
var
  i,j,ii,jj:integer;
  f:text;
begin
    Writeln('Number of Clusters= ',NumClusters);
    Writeln(OutputFileForAnaliz,'Number of Clusters= ',NumClusters);
    for j:=1 to NumClusters do begin
      Writeln('Number neurons in cluster ',j,'  ',NumNerInCluster[j]);
      Writeln(OutputFileForAnaliz,'Number neurons in cluster ',j,'  ',NumNerInCluster[j]);
      for ii:=1 to NumNerInCluster[j] do begin
        i:=Clusters[j,ii];
        Write(OutputFileForAnaliz,i:4,' Usefull',ner[i,5]:7,' Koord ',Ner[i,1],' ',Ner[i,2],' ',Ner[i,3]);
        Write(OutputFileForAnaliz,'     Connect with ');
        for jj:=1 to MaxNer do
          if Nodes[i,jj]>-1 then Write(OutputFileForAnaliz,jj:4,' ',Nodes[i,jj],' ');
        Writeln(OutputFileForAnaliz);
      end;
      Writeln;
      Writeln(OutputFileForAnaliz);
    end;
end;
procedure OutputClusteringResultNew;
var
  i,j,ii,jj,nn:integer;
  f:text;
begin
    Writeln('Number of Clusters= ',NumClusters);
    Writeln(OutputFileForAnaliz,NumClusters);
    for j:=1 to NumClusters do begin
      Writeln('Number neurons in cluster ',j,'  ',NumNerInCluster[j]);
      Writeln(OutputFileForAnaliz,j,'  ',NumNerInCluster[j]);
      for ii:=1 to NumNerInCluster[j] do begin
        i:=Clusters[j,ii];
        Write(OutputFileForAnaliz,i:4,' ',ner[i,5]:7,' ',Ner[i,1],' ',Ner[i,2],' ',Ner[i,3]);
        Write(OutputFileForAnaliz,' ');
        nn:=0;
        for jj:=1 to MaxNer do
          if Nodes[i,jj]>-1 then inc(nn);
        Write(OutputFileForAnaliz,nn,' ');
        for jj:=1 to MaxNer do
          if Nodes[i,jj]>-1 then Write(OutputFileForAnaliz,jj:4,' ');
        Writeln(OutputFileForAnaliz);
      end;
      Writeln;
      Writeln(OutputFileForAnaliz);
    end;
end;
procedure OutputClusteringResultNewPolar;
var
  i,j,ii,jj,nn:integer;
  x,y,z,a1,a2,a3,tempvar:double;
begin
    Writeln(OutputFileForAnalizPolar,NumClusters);
    for j:=1 to NumClusters do begin
      Writeln(OutputFileForAnalizPolar,j,'  ',NumNerInCluster[j]);
      for ii:=1 to NumNerInCluster[j] do begin
        i:=Clusters[j,ii];
        x:=Ner[i,1]/1;
        y:=Ner[i,2]/1;
        z:=Ner[i,3]/1;
        a3:=sqrt(sqr(x)+sqr(y)+sqr(z));
        a1:=0;
        a2:=0;
        if a3>0 then begin
          a2:=180/pi*arcsin(z/a3);
          tempvar:=arcsin(y/sqrt(sqr(x)+sqr(y)));
          if (x>0) and (y>=0) then
            a1:=180/pi*tempvar
          else if (x>0) and (y<0) then
            a1:=180/pi*(2*pi+tempvar)
          else a1:=180/pi*(pi-tempvar);
        end;
        Write(OutputFileForAnalizPolar,i:4,' ',ner[i,5]:7,' ',a1,' ',a2,' ',a3,' ');
        nn:=0;
        for jj:=1 to MaxNer do
          if Nodes[i,jj]>-1 then inc(nn);
        Write(OutputFileForAnalizPolar,nn,' ');
        for jj:=1 to MaxNer do
          if Nodes[i,jj]>-1 then Write(OutputFileForAnalizPolar,jj:4,' ');
        Writeln(OutputFileForAnalizPolar);
      end;
    end;
end;
function CreateFileName(Num:longint):string;
begin
  CreateFileName:='c:\AnalizGal\0_03_1';
end;
begin
  NumIteratVar:=MaxNumIterations;
  MaxNer:=MaxNumNer;
  NumberOfFiles:=1;
  for FileCounter:=1 to NumberOfFiles do begin 
    InputFileName:=CreateFileName(FileCounter);
    writeln(InputFileName);
    if FileExists(InputFileName+'.txt') then begin
      OutputFileNameForAnalizPolar:=InputFileName+'A_P';
      OutputFileNameForAnaliz:=InputFileName+'A';
      Assign(InputFile,InputFileName+'.txt');
      Reset(InputFile);
      Assign(OutputFileForAnalizPolar,OutputFileNameForAnalizPolar+'.txt');
      ReWrite(OutputFileForAnalizPolar);
      Assign(OutputFileForAnaliz,OutputFileNameForAnaliz+'.txt');
      ReWrite(OutputFileForAnaliz);
      DataNum:=0;
      while not(Eof(InputFile)) do begin
        Readln(InputFile,a1,a2,a3,a4,a5);
        if a3>0 then begin
          inc(DataNum);
          Data[DataNum,1]:=1*a3*cos(a2/180*pi)*cos(a1/180*pi);
          Data[DataNum,2]:=1*a3*cos(a2/180*pi)*sin(a1/180*pi);
          Data[DataNum,3]:=1*a3*sin(a2/180*pi);
        end;
      end;
      Close(InputFile);
      Writeln(OutputFileForAnaliz,' How much Data  ',DataNum);
      Writeln(OutputFileForAnalizPolar,' How much Data  ',DataNum);
      MaxNer:=60;
      if MaxNer>MaxNumNer then
        MaxNer:=MaxNumNer;
      NumIteratVar:=DataNum*80;
      ccc:=0;
      while ccc<1 do begin
        Randomize;
        for i:=1 to MaxNer do
          for j:=1 to MaxNer do begin
            Nodes[i,j]:=-1;
            Ner[i,4]:=-2;
            Ner[i,5]:=0;
          end;  
        NumNer:=2;
        for i:=1  to NumNer do begin
          for j:=1 to 3 do
            Ner[i,j]:=Data[i,j];
          Ner[i,4]:=0;
        end;
        Nodes[1,2]:=0;
        Nodes[2,1]:=0;
        for CountIterations:=1 to NumIteratVar do begin
          GetInputSignal(CountIterations,InputSignal);
          // First nearest neuron
          for i:=1 to MaxNer do
            if Ner[i,4]>-2 then 
              IndexNearestNeuron:=i;
          DistToNearest:=0;
          for j:=1 to 3 do
            DistToNearest:= DistToNearest+Sqr(Ner[IndexNearestNeuron,j]-InputSignal[j]);
          for i:=1 to MaxNer do begin
            if (Ner[i,4]>-2)then begin
              Dist:=0;
              for j:=1 to 3 do
                Dist:=Dist+Sqr(Ner[i,j]-InputSignal[j]);
              if (Dist<DistToNearest) then begin
                DistToNearest:=Dist;
                IndexNearestNeuron:=i;
              end;
            end;  
          end; 
          // Second nearest neuron
          for i:=1 to MaxNer do
            if (Ner[i,4]>-2) and (i<>IndexNearestNeuron) then 
              IndexSecondNearestNeuron:=i;
          DistToSecondNearest:=0;
          for j:=1 to 3 do
            DistToSecondNearest:=DistToSecondNearest+Sqr(Ner[IndexSecondNearestNeuron,j]-InputSignal[j]);
          for i:=1 to MaxNer do begin
            if (Ner[i,4]>-2) and (i<>IndexNearestNeuron) then begin 
              Dist:=0;
              for j:=1 to 3 do
                Dist:=Dist+Sqr(Ner[i,j]-InputSignal[j]);
              if (Dist<DistToSecondNearest) then begin 
                DistToSecondNearest:=Dist;
                IndexSecondNearestNeuron:=i;
              end;
            end;  
          end;
          // Increase local error nearest neuron
          Ner[IndexNearestNeuron,4]:=Ner[IndexNearestNeuron,4]+DistToNearest;
          // Increase counter of usefull nearest neuron
          Ner[IndexNearestNeuron,5]:=Ner[IndexNearestNeuron,5]+1;
          // Set age connection between nearest and second nearest to zero
          Nodes[IndexNearestNeuron,IndexSecondNearestNeuron]:=0;
          Nodes[IndexSecondNearestNeuron,IndexNearestNeuron]:=0;
          // Increase all connections ages emanating from nearest neuron
          for i:=1 to MaxNer do 
            if (Ner[i,4]>-2) and (Nodes[IndexNearestNeuron,i]>-1) then begin
              Inc(Nodes[IndexNearestNeuron,i]);
              Nodes[i,IndexNearestNeuron]:=Nodes[IndexNearestNeuron,i];
            end;  
          // Improve position of nearest neuron
          for j:=1 to 3 do
            Ner[IndexNearestNeuron,j]:=Ner[IndexNearestNeuron,j]-(k1*(Ner[IndexNearestNeuron,j]-InputSignal[j]));
          // Improve positions of all neurons emanating from nearest neuron
          for i:=1 to MaxNer do
            if (Ner[i,4]>-2) and (Nodes[IndexNearestNeuron,i]>-1) then 
              for j:=1 to 3 do
                Ner[i,j]:=Ner[i,j]-(k2*(Ner[i,j]-InputSignal[j]));
          // Deleting connections with age lager than AgeMax  
          for i:=1 to MaxNer do 
            for j:=1 to MaxNer do 
              if (Nodes[i,j]>=AgeMax) then begin
                Nodes[i,j]:=-1;
                Nodes[j,i]:=-1;
              end;
          // Deleting neurons has no connections
          for i:=1 to MaxNer do begin
            Flag:=0;
            for j:=1 to MaxNer do
              if (Nodes[i,j]<>-1) then 
                Flag:=1;
            if (Flag=0) and (Ner[i,4]<>-2) then begin
              Ner[i,4]:=-2;
              Ner[i,5]:=0;
              Dec(NumNer);
            end;
          end;
          // Deleting neurons not usefull enougth
          if (CountIterations mod (Lymbda*20) = 0) and (CountIterations > NumIteratVar div 2) then
            for i:=1 to MaxNer do
              if (Ner[i,5]<=2) and (Ner[i,4]>-2) then begin
                Ner[i,4]:=-2;
                Ner[i,5]:=0;
                for j:=1 to MaxNer do begin
                  Nodes[i,j]:=-1;
                  Nodes[j,i]:=-1;
                end;
                Dec(NumNer);
              end;
          // Insert new neuron
          if (CountIterations mod Lymbda=0) and (NumNer < MaxNer) then begin
            // Find parents neurons
            // Find neuron with max local error
            MaxLocErr1:=-2;
            for i:=1 to MaxNer do 
              if (Ner[i,4]> MaxLocErr1) then  begin 
                MaxLocErr1:=Ner[i,4];
                MaxLocErrorIndex1:=i;
              end;
            // Find neuron with max local error from neurons emanating from neuron with max local error
            MaxLocErr2:=-2;
            for i:=1 to MaxNer do 
              if (Nodes[i,MaxLocErrorIndex1]>-1) then 
                if (Ner[i,4]> MaxLocErr2) then begin 
                  MaxLocErr2:=Ner[i,4];
                  MaxLocErrorIndex2:=i;
                end;  
            // Put new neuron in the middle between parents neurons
            for i:=MaxNer downto 1 do
              if Ner[i,4]=-2 then 
                NewNer:=i;
            for j:=1 to 3 do
              Ner[NewNer,j]:=(Ner[ MaxLocErrorIndex2,j]+ Ner[ MaxLocErrorIndex1,j])/2;
            // Erase connection between parents neurons 
            Nodes[MaxLocErrorIndex2,MaxLocErrorIndex1]:=-1;
            Nodes[MaxLocErrorIndex1,MaxLocErrorIndex2]:=-1;
            // Set connection between new neuron and his parents 
            Nodes[MaxLocErrorIndex2,NewNer]:=0;
            Nodes[NewNer,MaxLocErrorIndex2]:=0;
            Nodes[MaxLocErrorIndex1,NewNer]:=0;
            Nodes[NewNer,MaxLocErrorIndex1]:=0;
            // Decrease local error of parents neurons  
            Ner[MaxLocErrorIndex1,4]:= (Ner[MaxLocErrorIndex1,4]*k3);
            Ner[MaxLocErrorIndex2,4]:= (Ner[MaxLocErrorIndex2,4]*k3);
            // Set local error of new neuron
            Ner[NewNer,4]:=Ner[MaxLocErrorIndex1,4];
            // Increase number of neurons
            Inc(NumNer);
          end;
          // Decrease local error of all neurons
          for i:=1 to MaxNer do
            if (Ner[i,4]>-2) then 
              Ner[i,4]:=(Ner[i,4]*k4);
          // Deleting neurons has no connections
          for i:=1 to MaxNer do begin
            Flag:=0;
            for j:=1 to MaxNer do
              if (Nodes[i,j]<>-1) then 
                Flag:=1;
            if (Flag=0) and (Ner[i,4]<>-2) then begin
              Ner[i,4]:=-2;
              Ner[i,5]:=0;
              Dec(NumNer);
            end;
          end;
        end;
        OutputNeurons;
        OutputNeuronsPolar;
        // Clustering
        // Save Nodes to temporary var ND
        for i:=1 to MaxNer do
          for j:=1 to MaxNer do
            ND[i,j]:=Nodes[i,j];
        NumClusters:=0;
        Flag2:=0;
        FirstNerInCluster:=1;
        while Flag2=0 do begin
          inc(NumClusters);
          Clusters[NumClusters,1]:=FirstNerInCluster;
          NumNerInCluster[NumClusters]:=1;
          i:=1;
          while i <= NumNerInCluster[NumClusters] do begin
            k:=Clusters[NumClusters,i];
            for j:=1 to MaxNer do
              if ND[k,j]<>-1 then begin
                ND[k,j]:=-1;
                ND[j,k]:=-1;
                Flag:=0;
                for ii:=1 to NumNerInCluster[NumClusters] do
                  if j=Clusters[NumClusters,ii] then 
                    Flag:=1;
                if Flag=0 then begin  
                  inc(NumNerInCluster[NumClusters]);
                  Clusters[NumClusters,NumNerInCluster[NumClusters]]:=j;
                end;
              end;
            i:=i+1;
          end;
          Flag2:=1;
          for k:=MaxNer downto 1 do
            for  j:=1 to MaxNer do
              if ND[k,j]<>-1 then begin 
                Flag2:=0;
                FirstNerInCluster:=k; 
              end;
        end;
        // End clustering
        // Order neurons in clusters according its usefull
        for i:=1 to NumClusters do 
          for j:=1 to NumNerInCluster[i] do 
            for ii:=1 to NumNerInCluster[i]-1 do 
              if Ner[Clusters[i,ii],5]<Ner[Clusters[i,ii+1],5] then begin
                jj:=Clusters[i,ii];
                Clusters[i,ii]:=Clusters[i,ii+1];
                Clusters[i,ii+1]:=jj;
              end;  
        OutputClusteringResultNew;
        OutputClusteringResultNewPolar;
        inc(ccc);
      end;
      Close(OutputFileForAnalizPolar);
      Close(OutputFileForAnaliz);
    end;
  end;
end.  
