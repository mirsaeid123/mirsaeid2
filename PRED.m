function [ L ] = PRED( i,n,W )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
L=[];
for j=1:n
    if W(j,i)~=0
        L=[L,j];
    end
end

end

