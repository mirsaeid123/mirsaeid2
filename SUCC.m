function [ y ] = SUCC( i,n,W )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
 L=[];
 for j=1:n
     if W(i,j)~=0
         L=[L,j];
     end
 end
 y=L;
end

