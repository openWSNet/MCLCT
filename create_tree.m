function [y,relay_node]=create_tree(node_in, relay, sensing_node,poi_x,poi_y)
% node.parenst ???????s?u?????`?I(?w????sensing node?????`?I?????p)
% node.dist ?????P???s?u???`?I???Z??
% node.cur_pars ???????e?B?????????`?I
% node.weight ???????e?B???????`?I?? weight (for node.cur_pars)
% node.load  ???????e?B??????laod
% node.trans ???e?O?_?????e??????node(???i???Osensing node ?? relay node) ?]?i?H?????O???e???n?Q??????node
% node.cur_pars_dist ???e???`?I???Z??

node=node_in;
relay_node=relay;
for a=1:length(node)-1
    node(a).sensing=0;
    node(a).trans=0;
    node(a).cur_pars=[];
    node(a).cur_pars_dist=[];
    node(a).weight=[];
%     node(a).track1=[];
%     node(a).track2=[];
    for b=1:length(sensing_node)
        if a==sensing_node(b) && node(a).e>0
            node(a).sensing=1;  %?Y?O?????n??????set????node ?hsensing=1
            node(a).trans=1; 
        end
    end
    for c=1:length(relay_node)
        if a==relay_node(c) && node(a).e>0
            node(a).trans=1;   % ?Y?O?????n?????????`?I (sensing node & relay node???O)
            node(a).load=0;
        end
    end
end


for i=1:length(node)-1   % ???M?wsensing ?A?M?wrelay???@
    if node(i).sensing==1 && node(i).trans==1  % ?????Osensing node
         if node(i).hop==1  % ?Y?O???@?h??sensing node
             node(i).cur_pars=[length(node)];
             node(i).weight=[1];
             node(i).cur_pars_dist=node(i).pars_dist;
         else   % ?Y???O???@?hsensing node
             [node(i).cur_pars,node(i).weight,node(i).cur_pars_dist]=compute_sensing_node_weight(node(i).parents, node(i).pars_dist,node); %???^?C??parents???v??  %?L?o???S???q??
             for k=1:length(node(i).cur_pars)
                 node(node(i).cur_pars(k)).load=node(node(i).cur_pars(k)).load+node(i).load*node(i).weight(k);
%                  node(node(i).cur_pars(k)).track1=[node(node(i).cur_pars(k)).track1 i]; %??????????
%                  node(node(i).cur_pars(k)).track2=[node(node(i).cur_pars(k)).track2 node(i).load*node(i).weight(k)];%??????????
             end
         end
    end  
end

temp=[];
for i=1:length(node)-1
    if node(i).trans==1
        temp= [temp node(i).hop]; % ???X?h??
    end
end

for t1=1:length(node)-1  % ???????`?I?O?_ ?Q????
   if node(t1).sensing==0 && node(t1).trans==1   % ?u?B?z ***?Dsensing node
       for t2=1:length(node(t1).parents)  % parents?? ???|??sensing node
           if node(node(t1).parents(t2)).trans==1 
               node(t1).cur_pars=[node(t1).cur_pars node(t1).parents(t2)];
               node(t1).cur_pars_dist=[node(t1).cur_pars_dist node(t1).pars_dist(t2)];
           end
       end
   end
end

for tier=max(temp):-1:1 % ?q???j?h???^
    if tier==1 % ???@?h
        for m=1:length(node)-1
            if node(m).hop==tier && node(m).trans==1 && node(m).sensing==0
%                 node(m).cur_pars=[length(node)];
                node(m).weight=[1];
%                 node(m).cur_pars_dist=node(m).pars_dist;
            end
        end
    else
        node_in_tier=[];
        parent_in_tier=[];
        for m=1:length(node)-1 % ???X?b?C?@?h???? ?C??node??node id ?M ?? parent??????
            if node(m).hop==tier && node(m).trans==1 && node(m).sensing==0  && node(m).e>0 % ???B????sensing node??weight?M?w
                node_in_tier=[node_in_tier m];
                parent_in_tier=[parent_in_tier length(node(m).cur_pars)];
            end
        end
        if ~isempty(node_in_tier) && ~isempty(parent_in_tier)
                node_tier_info=[];   % combine 
                node_tier_info(:,1)=node_in_tier;
                node_tier_info(:,2)=parent_in_tier;
                node_tier_info=sortrows(node_tier_info,2); % ???? ?D?n?????O???onode????  ?P?@?h??node?W?h?????p?????j
                for n=1:length(node_tier_info(:,1))   % from highest to 1
                   [node(node_tier_info(n,1)).cur_pars , node(node_tier_info(n,1)).weight, node(node_tier_info(n,1)).cur_pars_dist]=compute_relay_node_weight(node(node_tier_info(n,1)).cur_pars, node(node_tier_info(n,1)).cur_pars_dist , node); %?L?o???S???q??
                   if isempty(node(node_tier_info(n,1)).cur_pars) %% ?????e?@?????{???????? ?i?P?_?Y?O???`?I?????`?I???S?q?F
                       relay_node=setxor(relay_node,node_tier_info(n,1)); %  ?h?qrelay node ?W??????
                       node(node_tier_info(n,1)).trans=0;
                       node(node_tier_info(n,1)).sensing=0;
                       for s1=1:length(node)-1    % ?q?U?h???I ???X???`?I?? ?o??node ?M?????? ?A?q?s???? weight
                           if node(s1).hop== node(node_tier_info(n,1)).hop+1 
                             t=find(node(s1).cur_pars==node_tier_info(n,1), 1); 
                             if ~isempty(t)
                                node(node(s1).cur_pars(t)).load=10000;
                                node(s1).cur_pars_dist(t)=100000;
                                if node(s1).sensing==1
                                    [node(s1).cur_pars,node(s1).weight,node(s1).cur_pars_dist]=compute_sensing_node_weight(node(s1).cur_pars, node(s1).cur_pars_dist,node);
                                else
                                    [node(s1).cur_pars , node(s1).weight, node(s1).cur_pars_dist]=compute_relay_node_weight(node(s1).cur_pars, node(s1).cur_pars_dist , node); 
                                end
                                for p1=1:length(node(s1).cur_pars)
                                    node(node(s1).cur_pars(p1)).load=node(node(s1).cur_pars(p1)).load+node(s1).load*node(s1).weight(p1);
                                end
                             end
                           end
                       end
                   else                     
                       for p=1:length(node(node_tier_info(n,1)).cur_pars)
                           node(node(node_tier_info(n,1)).cur_pars(p)).load=node(node(node_tier_info(n,1)).cur_pars(p)).load+node(node_tier_info(n,1)).load*node(node_tier_info(n,1)).weight(p); % weight pars_dist parents ???m?O??????
                       end
                   end
                end
        end
    end
end

y=node;
end




