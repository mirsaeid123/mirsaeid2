function [ OCT ] = SUB_OCTRank( i,k,t_no,vm_no,LISTOCT,Data,BandW_avg,TPT )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%OCT=zeros(t_no,p_no);
if i==t_no
    OCT=0;
else
    L1=SUCC(i,t_no,Data);
    L2=zeros(1,vm_no);
    Lmins=zeros(1,length(L1));
    for j=1:length(L1)
      for p=1:vm_no
      if p==k
       %L2(j,p)=SUB_OCTRank(L1(j),p,t_no,p_no,TrT,PT_t)+PT_t(i,p);
       L2(1,p)=LISTOCT(L1(j),p)+TPT(i,p);
      else
       %L2(j,p)=SUB_OCTRank(L1(j),p,t_no,p_no,TrT,PT_t)+PT_t(i,p)+TrT(i,L1(j)); 
       L2(1,p)=LISTOCT(L1(j),p)+TPT(i,p)+Data(i,L1(j))/BandW_avg;
      end
      
      end
      Lmins(j)=min(L2);
    end
    OCT=max(Lmins);
end

end

