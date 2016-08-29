% function [res, time, fair_1,fair_2,fair_3, fair_4,fair_5,fair_6,fair_rec] = routing_and_sensing(node, dsc, relay, covermap, poi_num, poi_x,poi_y)
function [contributed_time, res, time] = routing_and_sensing(node, dsc, relay, covermap, poi_num, poi_x,poi_y,case_start,case_end)
    % parameters 
% parameters
    
    sensing_data_rate=1000; % bps
    packet_size=500 * 8; % bit
    a11=50E-9;  % 50nJ/bit   (Etx)
    a2=100E-12; % 100 pJ/bit/m2  (Etx)
    a12=100E-9; % 100nJ/bit  (Erx)
    a3=100E-9;  % 100 nJ / bit (sense)
   
    sensing_node=dsc;

    relay_node=relay;
    time=0;

    fair_1=[];
    fair_2=[];
    fair_3=[];
    fair_4=[];    
    fair_5=[];
    fair_6=[];
    fair_7=[];    
    fair_1_e=[];
    fair_2_e=[];
    fair_3_e=[];   
    fair_rec={};
    
%     fid=fopen(['record_' num2str(case_start) '_' num2str(case_end) '.txt'],'a');
    coverage_recovery_first_time=0;
    coverage_recovery_first_flag=0;
    contributed_time=0;
    
    while 1  % ?@???????@?? 
        % // ?n???????O?_??full coverage ?Y?S?? ?n????   (?Y?A?????]?L?k????full coverage ???O disconnected ?????X)
       node_count=0;        
       time=time+1;
       if mod(time,3600)==0
           fprintf('time=%d\n',time);
%            fprintf(fid,'time=%d\n',time);
       end
       covered_poi=evaluate_coverage(covermap, sensing_node, node);
       best_cand{1}=[];
       recover_coverage_vector_best_solution{1}=[];
       if sum(covered_poi)~=poi_num   % awake start 
           remaiing_node_from_relay_node=[];
           node_e=[];
           for k=1:length(relay_node)
               if node(relay_node(k)).e>0
                   remaiing_node_from_relay_node=[remaiing_node_from_relay_node relay_node(k)];
               end
           end           
           for k=1:length(node)
               node_e=[node_e node(k).e];
           end
           for cand_node=1:length(relay_node)
             [best_cand{cand_node+1},recover_target_num,recover_coverage_vector_best_solution{cand_node+1}]=search_best_cand_by_dp(covermap,~covered_poi, remaiing_node_from_relay_node...
             ,best_cand{cand_node},recover_coverage_vector_best_solution{cand_node},node_e);                   
           end
           if sum(recover_coverage_vector_best_solution{length(relay_node)+1})==sum(~covered_poi)
               if coverage_recovery_first_flag==0;
                coverage_recovery_first_flag=1;
                coverage_recovery_first_time=time;
               end
               fprintf('Awaking node:');
%                fprintf(fid,'awaking time=%d\n',time);
               fprintf('awaking time=%d\n',time);
%                fprintf(fid,'Awaking node:');
               disp(best_cand{cand_node+1});
%                fprintf(fid,'%s\n',mat2str(best_cand{cand_node+1}));
               sensing_node=[sensing_node best_cand{cand_node+1}];
               for u=1:length(best_cand{cand_node+1})
                   node(best_cand{cand_node+1}(u)).sensing=1;
                   node(best_cand{cand_node+1}(u)).load=sum(covermap(best_cand{cand_node+1}(u),:));
               end
           end
           relay_node=setxor(relay_node,best_cand{cand_node+1});
       end   % awake end
       covered_poi=evaluate_coverage(covermap, sensing_node, node);
       for k=1:length(covered_poi)
           if covered_poi(k)~=1
              fprintf('uncovered poi:%d (%d,%d)\n',k,poi_x(k),poi_y(k));
%               fprintf(fid,'uncovered poi:%d (%d,%d)\n',k,poi_x(k),poi_y(k));
           end
       end
       if sum(covered_poi)==poi_num
               path_rec={};
               path_dist_rec={};
               disconnect=0;
               
               [node,relay_node]=create_tree(node, relay_node, sensing_node, poi_x,poi_y);
               
               for i=1:length(sensing_node)
                    if node(sensing_node(i)).e>0
                        hop=node(sensing_node(i)).hop; 
                        current_parent=sensing_node(i); % ?_?l???Y?? sensing node
                        current_parent_dist=[];
                        path=[sensing_node(i)];
                        pre_curr=[];
                        path_dist=[];
%                         flag=0;
                        while hop>=1
                            pre_curr=current_parent;
                            [current_parent, current_parent_dist]=find_parent(current_parent,node); % ???????N?^??[]?C ?o?????????????{???q  ?]?bcreat_tree???w???{  
                            if isempty(current_parent)
                                disconnect=1;
                                break;
                            end
                            path=[path current_parent];
                            path_dist=[path_dist current_parent_dist];
                            if node(pre_curr).hop == node(current_parent).hop
                              hop=hop;  
%                               flag=1;
                            else
                              hop=hop-1;    
                            end
                                         
                        end
                        
                        if disconnect
                            fprintf('routing path of sensing node %d: \n', sensing_node(i));
%                             fprintf(fid,'routing path of sensing node %d: \n', sensing_node(i));
                            disp(path);  
%                             fprintf(fid,mat2str(path));
%                             fprintf(fid,'\ndisconnected\n');
                            disp('disconnected');
                            break;
                        else
                            node_count=node_count+1;  
                            path_rec{node_count}=path; % ??round?? ?????|????
                            path_dist_rec{node_count}=path_dist;
                        end
                    end
                end
                if ~disconnect 
                    for path_num=1:length(path_rec)
                        got_path=path_rec{path_num};
                        got_path_dist=path_dist_rec{path_num};
                        for path_node=1:length(got_path)-1 % ?????@???Osink 1000; 1*4000
                            if path_node==1 
                                sensed_data_amount=sensing_data_rate*node(got_path(path_node)).load; % bit
                                node(got_path(path_node)).e=node(got_path(path_node)).e-a3*sensed_data_amount; % sensing
                                node(got_path(path_node)).e=node(got_path(path_node)).e-(a11+a2*got_path_dist(path_node)^2)*ceil(sensed_data_amount/packet_size)*packet_size; % transmitting
                            else
                                node(got_path(path_node)).e=node(got_path(path_node)).e-a12*ceil(sensed_data_amount/packet_size)*packet_size;   % receiving 
                                node(got_path(path_node)).e=node(got_path(path_node)).e-(a11+a2*got_path_dist(path_node)^2)*ceil(sensed_data_amount/packet_size)*packet_size;
                            end
                        end
                    end
                else
                    if coverage_recovery_first_flag==1;
                        contributed_time=time-coverage_recovery_first_time;
                    end
                    break;                    
                end
       else
           disp('full coverage failed');
%            fprintf(fid,'full coverage failed');
           if coverage_recovery_first_flag==1;
            contributed_time=time-coverage_recovery_first_time;
           end
           break;
       end
    end
    res=node;
    fprintf('lifetime: %d\n', time);
%     fprintf(fid,'\nlifetime: %d\n', time);
%     fclose(fid);
end