function [Task, MakeSpan, Schedule]= FITNESS(RankTask, Data, BandW,BandW_avg,Landa_c, t_no, vm_no, TPT, Landa_p, Reliability, VMPrice)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
AFT=zeros(t_no,1);
Processor=zeros(1,vm_no);
Task=zeros(t_no,1);
EST=zeros(t_no,vm_no);
EFT=zeros(t_no,vm_no);
Rel=zeros(t_no,3); % Reliability for each Task on virtual machin 
R=zeros(t_no,vm_no);
Cost=zeros(t_no,vm_no);
y=zeros(1,10);
Sum_of_cost=0;
Product_of_Reliability=1;
zmax=0;

for zz=1 : t_no
    i=RankTask(zz);
    %%%%% Calculate EST and EFT ti on each virtual machin %%%%%%%%%%%%%%
    if i==1
       L=[];
    else
       L=PRED(i,t_no,Data);
       for j=1 : length(L)
           y(j)=AFT(L(j),1) + Data(L(j),i)/BandW_avg;
       end
       zmax=y(1);
       for p=2 : length(L)
           if zmax < y(p)
               zmax=y(p);
           end
       end
    end
    
    for k=1 : vm_no
        EST(i,k)= max(zmax,Processor(k));
        EFT(i,k)=TPT(i,k) + EST(i,k);
    end
    
    %%%%%%%%%%% Calculate Reliability TASK  ti on each virtual machin %%%
    L=PRED(i,t_no,Data);
    for k=1 : vm_no
      if i==1
        R(i,k)=exp(-Landa_p(k)*TPT(i,k));
      else
        prod=1;
        for j=1 : length(L)
         if Rel(L(j),2)==k  % same vm 
           prod=prod*Rel(L(j),1);
         else
           prod=prod*Rel(L(j),1)*exp(-Landa_c(Rel(L(j),2),k)*Data(L(j),i)/BandW(Rel(L(j),2),k));
         end
        end 
        prod=prod*exp(-Landa_p(k)*TPT(i,k));
        R(i,k)=prod;
      end
    end
     
    %%%%%%%%%%% Ignore UnReliable virtual machin  %%%%%%%%%%%%%%%%%%%%%%%
    for k=1 : vm_no
      if R(i,k) < Reliability
          EFT(i,k)=Inf;
      end
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%% Dominance and Pareto %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%  CREATE Matrix for calculation  %%%%%%%%%%%%%%
    M=zeros(vm_no,6);
    for k=1 : vm_no
        M(k,1)=EFT(i,k); M(k,2)=TPT(i,k)*VMPrice(k);  M(k,3)=R(i,k);
        M(k,4)=0; M(k,5)=k; M(k,6)=EST(i,k);
    end
   % M
    %%%%%%%%%%%%%%%%%%%%% X Dominate Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for k=1 : vm_no
        if M(k,4) == 0
            A1=M(k,1); A2=M(k,2);  A3=M(k,3);
            for p=1 : vm_no
                if p~=k && M(p,4)==0
                    if A1<=M(p,1) && A2<=M(p,2) && A3<=M(p,3)
                       if A1<M(p,1) || A2<M(p,2) || A3<M(p,3)
                          M(p,4)=1;
                       end
                    end
                end                    
            end
        end        
    end
    
    %%%%% End of loop: Matrix 'Pareto' is Pareto Front set %%%%%%
    Pareto=zeros(vm_no,6);
    p=0;
    for k=1 : vm_no
        if M(k,4)==0
            p=p+1;
            Pareto(p,:)=M(k,:);
        end
    end
   %Pareto
    select=0; %%  Answer
    if p==1  %%%% IF the number of Pareto Front members==1 %%%%
        select=1;
    else
        %%% when Pareto Front has more than one member  %%%%%%%
        %%%%%%%%%%%%%%%  USE Crowding Distance %%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%  SORT   %%%%%%%%%%%%%%
        z=zeros(1,6);
        for k=1 : p-1
            for s=k+1 : p
                if Pareto(k,1) > Pareto(s,1)
                    z(1,:)=Pareto(k,:);
                    Pareto(k,:)=Pareto(s,:);
                    Pareto(s,:)=z(1,:);
                end
            end
        end
        %%%%%%%%%%%%%%  NORMALIZING  %%%%%%%%%%
        f1sum=0; f2sum=0; f3sum=0;
        for k=1 : p
            f1sum=f1sum+Pareto(k,1);
            f2sum=f2sum+Pareto(k,2);
            f3sum=f3sum+Pareto(k,3);
        end
        
        normPareto=zeros(vm_no,6);
        for k=1 : p
            normPareto(k,1)=Pareto(k,1)/f1sum;
            normPareto(k,2)=Pareto(k,2)/f2sum;
            normPareto(k,3)=Pareto(k,3)/f3sum;
            normPareto(k,4)=Pareto(k,4);
            normPareto(k,5)=Pareto(k,5);
            normPareto(k,6)=Pareto(k,6);
        end
        %%%%%%%%%%%%%% MIN & MAX on bounds %%%%
        f1min=Inf; f2min=Inf; f3min=Inf;
        f1max=-Inf;  f2max=-Inf; f3max=-Inf;
        for x=1 : p
            if normPareto(x,1) < f1min
                f1min=normPareto(x,1);
            end
            if normPareto(x,2) < f2min
                f2min=normPareto(x,2);
            end
            if normPareto(x,3) < f3min
                f3min=normPareto(x,3);
            end
            if normPareto(x,1) > f1max
                f1max=normPareto(x,1);
            end
            if normPareto(x,2) > f2max
                f2max=normPareto(x,2);
            end
            if normPareto(x,3) > f3max
                f3max=normPareto(x,3);
            end
        end
        %%%%%%  Calculate crowding distance %%%
        dis=-Inf;
        for k=1 : p
            if k==1
                d1=abs(normPareto(k,1)-normPareto(k+1,1))/(f1max-f1min);
                d2=abs(normPareto(k,2)-normPareto(k+1,2))/(f2max-f2min);
                d3=abs(normPareto(k,3)-normPareto(k+1,3))/(f3max-f3min);
            else
            if k==p
                d1=abs(normPareto(k-1,1)-normPareto(k,1))/(f1max-f1min);
                d2=abs(normPareto(k-1,2)-normPareto(k,2))/(f2max-f2min);
                d3=abs(normPareto(k-1,3)-normPareto(k,3))/(f3max-f3min);
            else
                d1=abs(normPareto(k-1,1)-normPareto(k+1,1))/(f1max-f1min);
                d2=abs(normPareto(k-1,2)-normPareto(k+1,2))/(f2max-f2min);
                d3=abs(normPareto(k-1,3)-normPareto(k+1,3))/(f3max-f3min);
            end
            end
             d=d1+d2+d3;
            
            if d > dis
                dis=d;
                select=normPareto(k,5);
            end
        end
    end
    %%%%%%%%%% Pareto(select) is answer %%%%%%%%%%%%%%%%%%%%%
    Cost(i,select)=M(select,2);
    Rel(i,1)=M(select,3);
    Rel(i,2)=select;
    Sum_of_cost = Sum_of_cost + Cost(i,select);
    Product_of_Reliability= Product_of_Reliability * Rel(i,1);
  
    %%%%% Set  AFT & Processor %%%%%%%%%%%%%%%%%
    Task(i)=select; %RUN Task=i on vm=select
    AFT(i,1)=M(select,1);
    Processor(select)=M(select,1); % end of task run ti
    Schedule(i,1)=EST(i,select);
    Schedule(i,2)=AFT(i,1);
    Schedule(i,3)=select;
    Schedule(i,4)=Cost(i,select);
    Schedule(i,5)=Rel(i,1);
       
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
MakeSpan=AFT(t_no)
Sum_of_cost
Product_of_Reliability
end

