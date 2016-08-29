%% axis equal 要執行程式之前要先運作這兩個程式
%% axis image
%hold on;%讓plot可以重複畫在一張圖上面
clear;
clf;
clc;
close all;

global generation_size pop_size sense_node sense_range sensor_selected  node_x node_y   target_coveraged remaining_node_array target_covered_for_each_node active_node_array



packet_bit=2000;
generation_size=20;
pop_size=50;

sink_x=250;
sink_y=250; %sink_y=200

%grid_range用來決定field的大小  rand_rang用來決定target的個數大小
       

sense_node_case=[60 80 100 120 140 160];
grid_num_cand=[10 20 30 40 50];
sense_range_cand=[100 140 180 220 260 300];

for glo_node_case=6:6 % 可以改length(grid_num_grid) length(sense_node_case) length(sense_range_cand)
%    for glo_grid_case=1:length(grid_num_cand)  
for glo_grid_case=3:3
%        for glo_sense_case=1:length(sense_range_cand)
     for glo_sense_case=3:3
                              for test_time=1:30            % 實驗次數
                                 node_x=[];
                                 node_y=[];
                                 remaining_node_array=[];
                                  load ([num2str(glo_node_case) '_' num2str(glo_grid_case) '_' num2str(glo_sense_case) '_'  num2str(test_time) '.mat']); 
                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   重要參數要改到
                                 sense_node=sense_node_case(glo_node_case); %恢復node數
                                 grid_num=grid_num_cand(glo_grid_case);
                                 sense_range=sense_range_cand(glo_sense_case);
                                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
                                 target_covered_for_each_node=covermap;
                                 init_coveraged_target_count(test_time,glo_node_case,glo_grid_case,glo_sense_case)=cal_init_discrete_cov(target_covered_for_each_node);
                                 fprintf('\ninitial coverage=%d\n',init_coveraged_target_count(test_time,glo_node_case,glo_grid_case,glo_sense_case));
                                 glo_time=0;
                                 glo_result={};
                                 glo_coverage=[]; 
                                 tic;
                            %      while(sense_node~=0)
                            %     while(1) 
                                   while(1) %    while(sense_node~=0) 跑到所有節點都用光
                                            glo_time=glo_time+1;
                                             fprintf('%d-%d-%d-%d-%d\n',test_time, glo_node_case,glo_grid_case,glo_sense_case,glo_time);
                                            sensor_selected=zeros(pop_size,sense_node,generation_size+1);
                                            target_coveraged=zeros(pop_size,size(target_covered_for_each_node,2),generation_size+1); %(個體數,覆蓋target array,代數)
                                            [avg_fit,bst_fit,act_node,final_coverage,final_generation,best_fit,best_idx]=algorithm();
                                            if bst_fit==0
                                                break;
                                            end
                                            glo_coverage(glo_time)=final_coverage/size(target_covered_for_each_node,2);
                                            glo_remaining_node{glo_time}=remaining_node_array;
                                            glo_result{glo_time}=active_node_array;
                                            [covered_number_all,covered_map_all]=fit_foreach(ones(1,sense_node));
                                            covered_number_all
                                            if covered_number_all~=grid_num
                                                break;
                                            end        
                                    end
                                     time_period=toc;
                                     time_consuming(test_time,glo_node_case,glo_grid_case,glo_sense_case)=time_period;
                                     num_coverage_100per(test_time,glo_node_case,glo_grid_case,glo_sense_case)=length(find(glo_coverage==1));
                                     coverage_all{test_time,glo_node_case,glo_grid_case,glo_sense_case}=glo_coverage;
                                     node_active_result{test_time,glo_node_case,glo_grid_case,glo_sense_case}=glo_result;
%                                      filename=[num2str(glo_node_case) '_' num2str(glo_grid_case) '_' num2str(glo_sense_case) 'dscp1.mat'];
                              end
       end
   end
end
% save sim_data.mat init_coveraged_target_count time_consuming num_coverage_100per coverage_all node_active_result field_num 
% save sim_data.mat target_covered_for_each_node init_coveraged_target_count time_consuming num_coverage_100per coverage_all node_active_result node_x node_y grid_range_x grid_range_y span sink_x sink_y packet_bit sense_range grid_num

% 與leach結合 評估效能

% [coverage_rec,avg_packets_to_bs,avg_packets_to_ch,dead,S,last_round,CLUSTERHS,avg_ch]=LEACH(sense_node,9000,0.2,...
% sensor_selected(best_idx,:,generation_size+1),node_x,node_y,sink_x,sink_y,packet_bit,1);
% avg_ch
% avg_packets_to_bs
% avg_packets_to_ch

% pause;
% end

