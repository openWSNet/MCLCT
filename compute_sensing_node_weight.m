function [parents_checked,weight, dist_checked]=compute_sensing_node_weight(parents, dist, node)
   weight=[];
   parents_checked=[];
   parents_e=[];
   dist_checked=[];
   for i=1:length(parents)
       if node(parents(i)).trans==1 && node(parents(i)).e>0  %???T?{???`?I?O?_?b?????W????
           parents_checked=[parents_checked parents(i)];
           parents_e=[parents_e node(parents(i)).e];
           dist_checked=[dist_checked dist(i)];
       end
   end
   parents_e=parents_e.^2;
   s=sum(1./(dist_checked.*dist_checked).*parents_e);
   for i=1:length(parents_checked)
       weight(i)=(1/dist_checked(i)^2*parents_e(i))/s;
   end

end



% function [parents_checked,weight, dist_checked]=compute_sensing_node_weight(parents, dist, node)
%    weight=[];
%    parents_checked=[];
%    dist_checked=[];
%    for i=1:length(parents)
%        if node(parents(i)).trans==1 && node(parents(i)).e>0  %???T?{???`?I?O?_?b?????W????
%            parents_checked=[parents_checked parents(i)];
%            dist_checked=[dist_checked dist(i)];
%        end
%    end
%    s=sum(1./(dist_checked.*dist_checked));
%    for i=1:length(parents_checked)
%        weight(i)=(1/dist_checked(i)^2)/s;
%    end
% end

