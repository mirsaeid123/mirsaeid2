function [Schedule ] = Schedule_Chart(Schedule,t_no, vm_no)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

hold on;
RangeX=max(Schedule(:,2));
RangeY=vm_no;

rectangle('Position',[0,1,RangeX,RangeY])

for i=1 : t_no
    dis=Schedule(i,2)-Schedule(i,1);
    p=Schedule(i,3);
    rectangle('Position',[Schedule(i,1), p, dis, 1]);
     text(Schedule(i,1),p+0.5,num2str(i))
end

