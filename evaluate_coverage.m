function covered_poi=evaluate_coverage(covermap, sensing_node, node)
    tmp=zeros(1,size(covermap,2));
    for i=1:length(sensing_node)
        if node(sensing_node(i)).e > 0
            tmp=or(tmp,covermap(sensing_node(i),:));
        end
    end
    covered_poi=tmp;
end