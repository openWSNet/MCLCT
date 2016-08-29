function [chosen_parent,chosen_parent_dist]=find_parent(current_node,node)
    rand('state',sum(100*clock)*rand(1));
    ran=rand; % 0~1
    sump=0;
    chosen_parent=[];
    chosen_parent_dist=[];
    if isempty(node(current_node).weight)==0
        for i=1:length(node(current_node).weight)
            sump=sump+node(current_node).weight(i);
            if ran<=sump
                chosen_parent=node(current_node).cur_pars(i);
                chosen_parent_dist=node(current_node).cur_pars_dist(i);
                break;
            end
        end
    end
end