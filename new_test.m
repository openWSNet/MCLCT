clc;clear;
node_number=300;
poi_number=5;
sens_range=10;
comm_range=50;
sink_x=1;
sink_y=75;

% target_covered_for_each_node=rand(node_number,poi_number)>0.5;

lost_coverage_vector=ones(1,poi_number);

recover_coverage_vector_best_solution{1}=[];
node_e=ones(1,node_number);

file_count=0;
for test_time=1:50       % ????????
    fprintf('test_time=%d\n',test_time);
    count=0;
    DSC={};
    node=[];
    poi=[];
    % generate coordinat of node and POI
    for i=1:poi_number
        poi_x(i)=randi([10 140],1,1);  %fix(10+rand*1000*0.13);   % 10~140
        poi_y(i)=randi([10 140],1,1); 
%         poi_x(i)=randi([10 290],1,1);  %fix(10+rand*1000*0.13);   % 10~140
%         poi_y(i)=randi([10 290],1,1); 
    end    
    while 1
        for i=1:node_number
%             if i<=node_number/2
                node_x(i)=randi([min(poi_x) max(poi_x)],1,1); 
                node_y(i)=randi([min(poi_y) max(poi_y)],1,1); 
%             else
%                 node_x(i)=randi([1 150],1,1);   %fix(rand*1000*0.15);    1000m x 15% = 150m, 150mx150m=22500 m^2 = 22.5 acres
%                 node_y(i)=randi([1 150],1,1);
%             end
            node(i).x=node_x(i);
            node(i).y=node_y(i);
            node(i).hop=10000;
            node(i).load=0;
            node(i).sensing=0;  %?P??
            node(i).trans=0; %?????? (sensing node ?M relay node ???n?O1)
            node(i).parents=[];
            node(i).pars_dist=[];
            node(i).e=20;   % @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   ?O?o????20
    %         file_name_1=[num2str(test_time) '_node.txt'];
    %         file1=fopen(file_name_1,'a');
    %         fprintf(file1,'%d %d %d\n',i,node_x(i),node_y(i));
    %         fclose(file1);
        end
        node(node_number+1).x=sink_x;  %?????@???O  sink
        node(node_number+1).y=sink_y;
        node(node_number+1).load=0;
        node(node_number+1).hop=0;
        node(node_number+1).sensing=0;
        node(node_number+1).trans=1;   % sink?]?O???b?B?@???`?I???@


        covermap=[];
         for j=1:node_number
            count=0;
            for k=1:poi_number
                if dist(node_x(j),node_y(j),poi_x(k),poi_y(k))<=sens_range
                    covermap(j,k)=1;
                    count=count+1;
                else
                    covermap(j,k)=0;
                end
            end
            node(j).load=count;
        end

        lost_coverage_vector=sum(covermap,1)~=0;
        if sum(lost_coverage_vector)==poi_number 
            break;
        end
    end    
    fprintf('POI used: %d/%d\n',sum(lost_coverage_vector),poi_number);
    temp=sum(covermap,1);
    while 1
        if min(temp)==0
            [c,d]=min(temp);
            temp(d)=[];
        else
            fprintf('min # that a POI is covered: %d\n\n',min(temp));
            break;
        end
    end
    best_cand{1}=[];
    total_remaining_node_set=[1:node_number];
    count=0;
    while 1  % enter searching for DSC
        for cand_node=1:node_number
            [best_cand{cand_node+1},recover_target_num,recover_coverage_vector_best_solution{cand_node+1}]=search_best_cand_by_dp(covermap,lost_coverage_vector,total_remaining_node_set...
            ,best_cand{cand_node},recover_coverage_vector_best_solution{cand_node},node_e); 
        end
        if isempty(best_cand) || (sum(recover_coverage_vector_best_solution{node_number+1})~=sum(lost_coverage_vector))  % if not any DSC could be found
            DSC_rec(2,1)=length(DSC); % ???X??DSC???q
            DSC_rec(1,1)=min(temp);   %  ?z????????
            DSC_content=DSC;         
            clear DSC;
            break;
        else
            count=count+1;
            DSC{count}=best_cand{node_number+1};
            if isempty(best_cand{node_number+1})
               disp('*');
            end
            total_remaining_node_set_new=[];
            for i=1:length(total_remaining_node_set)
               if(isempty(find(best_cand{node_number+1}==total_remaining_node_set(i))))
                   total_remaining_node_set_new=[total_remaining_node_set_new total_remaining_node_set(i)];
               end
            end
            total_remaining_node_set=total_remaining_node_set_new;
%             clear best_cand recover_coverage_vector_best_solution;
            best_cand{1}=[];
            recover_coverage_vector_best_solution{1}=[];
         end
    end
    if isempty(DSC_content)==0
        for a1=1:length(DSC_content)
            tmp=DSC_content{1,a1};
            for a2=1:length(tmp)
                node(tmp(a2)).sensing=1;
            end
        end
    end
    node=compute_hop_count(node, sink_x, sink_y ,comm_range);
    file_name=[num2str(test_time) '.mat'];
%     if mod(test_time,2)==1
%         file_count=file_count+1;
%         mkdir([num2str(file_count)]);
%     end
%     save(['./' num2str(file_count) '/' file_name], 'node' , 'poi_x', 'poi_y', 'covermap', 'DSC_rec', 'DSC_content');
    save([file_name], 'node' , 'poi_x', 'poi_y', 'covermap', 'DSC_rec', 'DSC_content');
end 