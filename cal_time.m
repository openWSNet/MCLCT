time_sum=[];
contributed_t=[];
for i=1:50
    clear time contributed_time;
    load(['data' num2str(i) '.mat'],'time','contributed_time');
    time_sum(i)=sum(time);
    contributed_t(i)=sum(contributed_time);
end

save('result.mat','time_sum','contributed_t');
