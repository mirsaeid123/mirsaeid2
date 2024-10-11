clc
clear all

%%%%%%%%%%%%%%%%%%  << START DATA ENTRY >> %%%%%%%%%%%%%%

t_no=28; % number of Tasks
vm_no=10; % number of virtual machins(vm)

Tins=zeros(t_no);  % number of instruction(milion) in each task
Tins(1)=3; Tins(2)=7; Tins(3)=2; Tins(4)=6; Tins(5)=4; Tins(6)=6;
Tins(7)=5; Tins(8)=3; Tins(9)=4; Tins(10)=7; Tins(11)=2; Tins(12)=8;
Tins(13)=5;Tins(14)=4; Tins(15)=6; Tins(16)=5; Tins(17)=7; Tins(18)=3;
Tins(19)=5; Tins(20)=3; Tins(21)=4; Tins(22)=9; Tins(23)=2; Tins(24)=5;
Tins(25)=7; Tins(26)=5; Tins(27)=2; Tins(28)=4;

Data=zeros(t_no,t_no); %Data transfer from ti to tj(MegaByte)
Data(1,2)=7; Data(1,3)=5; Data(1,4)=8; Data(2,5)=6;
Data(2,6)=5; Data(3,7)=3; Data(3,8)=4; Data(3,9)=2; 
Data(4,10)=5; Data(5,11)=4; Data(5,12)=2;
Data(6,13)=5; Data(6,14)=8; Data(7,14)=7; 
Data(8,14)=9; Data(9,15)=3; Data(9,16)=7; 
Data(10,16)=5; Data(10,17)=6; Data(10,18)=8;
Data(11,18)=8; Data(12,20)=5; Data(13,20)=3;
Data(14,21)=7; Data(15,22)=2; Data(16,22)=5;
Data(17,23)=8; Data(17,24)=10; Data(18,24)=7;
Data(19,25)=6; Data(20,25)=4; Data(21,25)=5;
Data(21,26)=2; Data(22,28)=3; Data(23,27)=6;
Data(24,27)=5; Data(25,28)=8; Data(26,28)=10;
Data(27,28)=7;

BandW=zeros(vm_no,vm_no); %Band Width Bitween vmi to vmj(Megabit per second)
BandW=[2000 2000 200 200 200 200 200 200 200 200 ; %BandW(vmi,vmj)
       2000 2000 200 200 200 200 200 200 200 200 ;
       200 200 2000 2000 2000 200 200 200 200 200 ;
       200 200 2000 2000 2000 200 200 200 200 200 ;
       200 200 2000 2000 2000 200 200 200 200 200 ;
       200 200 200 200 200 2000 2000 200 200 200 ;
       200 200 200 200 200 2000 2000 200 200 200 ;
       200 200 200 200 200 200 200 2000 2000 2000 ;
       200 200 200 200 200 200 200 2000 2000 2000 ;
       200 200 200 200 200 200 200 2000 2000 2000 ];
   
Landa_c=zeros(vm_no,vm_no);%Fault Rate for each connection Bitween vmi to vmj
Landa_c=[0.0002 0.0002 0.002 0.002 0.002 0.002 0.002 0.002 0.002 0.002;%Landa_c(vmi,vmj)
         0.0002 0.0002 0.002 0.002 0.002 0.002 0.002 0.002 0.002 0.002;
         0.002 0.002 0.0002 0.0002 0.0002 0.002 0.002 0.002 0.002 0.002;
         0.002 0.002 0.0002 0.0002 0.0002 0.002 0.002 0.002 0.002 0.002;
         0.002 0.002 0.0002 0.0002 0.0002 0.002 0.002 0.002 0.002 0.002;
         0.002 0.002 0.002 0.002 0.002 0.0002 0.0002 0.002 0.002 0.002;
         0.002 0.002 0.002 0.002 0.002 0.0002 0.0002 0.002 0.002 0.002;
         0.002 0.002 0.002 0.002 0.002 0.002 0.002 0.0002 0.0002 0.0002;
         0.002 0.002 0.002 0.002 0.002 0.002 0.002 0.0002 0.0002 0.0002;
         0.002 0.002 0.002 0.002 0.002 0.002 0.002 0.0002 0.0002 0.0002;];

VMspeed=zeros(vm_no); % speed of Processor(MIPS) for each VM
VMspeed(1)=200; VMspeed(2)=250; VMspeed(3)=220;
VMspeed(4)=220; VMspeed(5)=270; VMspeed(6)=200;
VMspeed(7)=250; VMspeed(8)=250; VMspeed(9)=200;
VMspeed(10)=220;

Landa_p=zeros(vm_no); % Fault Rate of Processor for each VM
Landa_p(1)=0.0012; Landa_p(2)=0.0014; Landa_p(3)=0.0010;
Landa_p(4)=0.0012; Landa_p(5)=0.0013; Landa_p(6)=0.0013;
Landa_p(7)=0.0015; Landa_p(8)=0.0012; Landa_p(9)=0.0010;
Landa_p(10)=0.0010;

RELIABILITY=0.94; % Expected Reliability for DAG

VMPrice=zeros(vm_no);  % Processor Rent Price(per second)(cent) for each VM
VMPrice(1)=4; VMPrice(2)=7; VMPrice(3)=7; 
VMPrice(4)=6; VMPrice(5)=9; VMPrice(6)=3; 
VMPrice(7)=6; VMPrice(8)=8; VMPrice(9)=5; 
VMPrice(10)=7; 

%%%%%%%%%%%%%%%%%%  << END DATA ENTRY >> %%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%  << START ALGORITHM >> %%%%%%%%%%%%%%

TPT=zeros(t_no,vm_no);% Calculate Task Process Time on each virtual machin 
for i=1 : t_no
    for j=1 : vm_no
        TPT(i, j)= Tins(i) / VMspeed(j); 
    end
end    
%%%%%%% Calculate Average Process Time any Task
TPT_avg=zeros(t_no);
for i=1:t_no
    TPT_avg(i)=sum(TPT(i , : ))/vm_no;
end
%TPT_kol=mean(TPT_avg);
TPT_kol=sum(TPT_avg)/t_no;
TPT_kol
 BandW_vm=mean(BandW,1); %Average of Bandwidth
 BandW_avg=mean(BandW_vm);
  BandW_avg
 Data_avg=sum(Data); 
 Data_kol=sum(Data_avg);
 Data_kol
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          PEFT Task Prioritizing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%   Create OCT RANK
OCT=zeros(t_no,vm_no);
OCT_avg=zeros(1,t_no);
for i=t_no:-1:1
    sum=0;    
    for p=1:vm_no
        OCT(i,p)=SUB_OCTRank(i,p,t_no,vm_no,OCT,Data,BandW_avg,TPT);
        sum=sum+OCT(i,p);
    end
    OCT_avg(i)=sum/vm_no;    
end

%%%%%%% SORT OCT RANK
IDX=zeros(1,t_no);
SortOCT=zeros(1,t_no);
for i=1:t_no
    M1=-inf;
    for j=1:t_no
        if (OCT_avg(1,j)>M1) &&(IDX(1,j)==0)
            M1=OCT_avg(1,j);
            idx=j;
        end
    end
    SortOCT(1,i)=idx;
    IDX(1,idx)=1;
end

%%%%%%% Calculate FITNESS & MAKESPAN & allocate Virtual Machin 
VM=zeros(t_no,1);
Schedule=zeros(t_no,5);
[VM, MakeSpan,Schedule]=FITNESS(SortOCT, Data,BandW, BandW_avg,Landa_c, t_no, vm_no, TPT, Landa_p, RELIABILITY, VMPrice);

disp('   TASK       START     STOP      Virtual Machin    Cost    Reliability');
disp('==========================================');
for i=1 : t_no
    X=[i, Schedule(i,1), Schedule(i,2), Schedule(i,3), Schedule(i,4), Schedule(i,5)];
   disp(X)
end

%[Schedule]=Schedule_Chart(Schedule,t_no, vm_no);


