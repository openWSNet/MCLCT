function [parents_checked, weight, dist_checked]=compute_relay_node_weight(parents, dist, node)
   weight=[];
   parents_load=[]; % ???Xparents?`?I??load
   parents_checked=[];
   parents_e=[];
   dist_checked=[];
   factor=[];
   
   if isempty(parents)==0
       for k=1:length(parents)
           if node(parents(k)).trans==1 && node(parents(k)).e>0
                parents_checked=[parents_checked parents(k)];
                parents_e=[parents_e node(parents(k)).e];
                dist_checked=[dist_checked dist(k)];
           end
       end
       for i=1:length(parents_checked)
           parents_load(i)=node(parents_checked(i)).load;
       end
       if std(parents_load)~=0 && length(parents_checked)>1
           factor=(parents_e.^2)./(parents_load+1).^0.5;
           p1=factor-mean(factor);
           p2=p1-min(p1)*2;
           weight=p2./sum(p2);
       else
           weight=1/length(parents_checked)*ones(1, length(parents_checked)); %?n?A?? ?????q????
       end
   end

end


% function [parents_checked, weight, dist_checked]=compute_relay_node_weight(parents, dist, node)
%    weight=[];
%    parents_load=[]; % ???Xparents?`?I??load
%    parents_checked=[];
%    dist_checked=[];
%    if isempty(parents)==0
%        for k=1:length(parents)
%            if node(parents(k)).trans==1 && node(parents(k)).e>0
%                 parents_checked=[parents_checked parents(k)];
%                 dist_checked=[dist_checked dist(k)];
%            end
%        end
%        for i=1:length(parents_checked)
%            parents_load(i)=node(parents_checked(i)).load;
%        end
%        if std(parents_load)~=0 && length(parents_checked)>1
%            p1=mean(parents_load)-parents_load;
%            p2=p1-min(p1);
%            weight=p2./sum(p2);
%        else
%            weight=1/length(parents)*ones(1, length(parents_checked));
%        end
%    end
% end