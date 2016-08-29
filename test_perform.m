
function y=test_perform(case_start,case_end, data_case)
clc

node_rec={};
for casenum=case_start:case_end
    clear DSC_content DSC_rec covermap node poi_x poi_y all_node_in_dsc relay_node node res
      load([num2str(data_case) '.mat']);
%     if mod(casenum,2)==1
%         fold=['./' num2str(fix(casenum/2)+1) '/'];
%     else
%         fold=['./' num2str(casenum/2) '/'];
%     end
%     load(['./' fold num2str(casenum) '.mat']);
%     load([num2str(casenum) '.mat']);
%     fid=fopen(['record_' num2str(case_start) '_' num2str(case_end) '.txt'],'a');
%     fprintf(fid,'\ncase %d\n', casenum);
    fprintf('\ncase %d\n', casenum);
    node_num=length(node)-1;
    res=node;
    time=[];
    contributed_time=[];
    for set_num=1:length(DSC_content)
        if set_num==1    
            all_node_in_dsc=[];
            for i=1:length(DSC_content)
                all_node_in_dsc=[all_node_in_dsc DSC_content{i}];
            end
            relay_node=setxor([1:node_num], all_node_in_dsc);
        else
            all_node_in_dsc=[];
            for i=1:length(DSC_content)
                all_node_in_dsc=[all_node_in_dsc DSC_content{i}];
            end
            relay_node=setxor([1:node_num], all_node_in_dsc);
            for j=1:set_num-1
                relay_node=[relay_node DSC_content{j}];
            end
        end
     
        [contributed_time(set_num), res, time(set_num)]=routing_and_sensing(res, DSC_content{set_num}, relay_node, covermap, length(poi_x),poi_x,poi_y,case_start,case_end);      
    end
    save(['data' num2str(casenum) '.mat'], 'contributed_time', 'res', 'time');
end

end

