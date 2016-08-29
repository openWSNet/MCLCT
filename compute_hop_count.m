% ???D?X?bsink node??id = 0 set ?????|?X???D

function outcome=compute_hop_count(node, sink_x, sink_y ,comm_range)
%  sink ?? hop=0;
    outcome=node;
    for i =1:length(outcome)-1 % sink ?s?? ?????@?h
        if dist(sink_x,sink_y,outcome(i).x,outcome(i).y) <=comm_range && outcome(i).hop>0
            outcome(i).hop=1;   
            outcome(i).parents=[length(node)];
            outcome(i).pars_dist=[dist(sink_x,sink_y,outcome(i).x,outcome(i).y)];
        end
    end
    hop_count=0;
    stop=1;
    while stop==1
        hop_count=hop_count+1; 
        stop=0;        
        for j=1:length(outcome)-1
            if outcome(j).hop==hop_count && outcome(j).sensing==0  % ?Y?Osensing node ???|?Q???{?i?hrelay ??
                for k=1:length(outcome)-1
                    tmp=dist(outcome(k).x,outcome(k).y,outcome(j).x,outcome(j).y);
                    if tmp<=comm_range && outcome(k).hop>hop_count   
                        outcome(k).hop=hop_count+1;
                        outcome(k).parents=[outcome(k).parents j];
                        outcome(k).pars_dist=[outcome(k).pars_dist tmp];
                        stop=1;
                    end
                end
            end
        end    
    end
%     for n=1:length(outcome)-1 % ?????G?h????sensing node  ??parents
%         if outcome(n).sensing ==1 && outcome(n).hop>=2
%             for m=1:length(outcome)-1
%                 if outcome(m).hop==outcome(n).hop-1 && outcome(m).sensing==0 && dist(outcome(m).x,outcome(m).y,outcome(n).x,outcome(n).y)<=comm_range
%                     outcome(n).parents=[outcome(n).parents m];
%                     outcome(n).pars_dist=[outcome(n).pars_dist dist(outcome(n).x, outcome(n).y, outcome(m).x, outcome(m).y)];
%                 end
%             end
%         end
%     end
     for n=1:length(outcome)-1 % ?P?_?O?_???`?I???????I?u??<=?@?? ?Y?O ?h???\?P?h?s??
         if length(outcome(n).parents)<=1 && outcome(n).hop~=1 % not in tier 1
             for m=1:length(outcome)-1
                 if outcome(m).hop==outcome(n).hop && outcome(m).sensing==0 && dist(outcome(m).x,outcome(m).y,outcome(n).x,outcome(n).y)<=comm_range
                     outcome(n).parents=[outcome(n).parents m];
                     outcome(n).pars_dist=[outcome(n).pars_dist dist(outcome(m).x,outcome(m).y,outcome(n).x,outcome(n).y)];
                 end
             end
         end
     end
end