function z=energy_analysis(x_range,y_range,node,poi_x,poi_y)
    x=zeros(y_range,x_range);
    y=zeros(y_range,x_range);
    z=zeros(y_range,x_range,length(node)-1);
    z_sum=zeros(y_range,x_range);
    for p=1:y_range
        for q=1:x_range
           x(p,q)=q;
           y(p,q)=p;
        end
    end
    
    temp=[];
    for i=1:length(node)-1
        if node(i).trans==1
            temp= [temp node(i).hop]; % §ä¥X¼h¼Æ
        end
    end
    max_tier=max(temp); 

    for k=1:length(node)-1
        for i=1:1:y_range
            for j=1:x_range
                if node(k).sensing ==0 && node(k).trans ==1 && node(k).hop==1
                    z(i,j,k)=(node(k).e/(node(k).load+1)).*exp(-0.03.*((j-node(k).x).^2+(i-node(k).y).^2));
                end
            end
        end
    end
    
%     for g=1:20
%         margin_top_node(g).x=g*5-5;
%         margin_top_node(g).y=150;
%         margin_top_node(g).e=node(380+g).e;
%         margin_right_node(g).x=150;
%         margin_right_node(g).y=g*5-5;
%         margin_right_node(g).e=node(g*20).e;
%     end
%     for g=1:20
%         for i=1:1:y_range
%             for j=1:x_range
%                 z_margin_top(i,j,g)=margin_top_node(g).e*exp(-0.03.*((j-margin_top_node(g).x).^2+(i-margin_top_node(g).y).^2));
%                 z_margin_right(i,j,g)=margin_right_node(g).e.*exp(-0.03.*((j-margin_right_node(g).x).^2+(i-margin_right_node(g).y).^2));
%             end
%         end     
%     end
    
    for m=1:length(node)-1
        z_sum=z_sum+z(:,:,m);
    end
    
%     for g=1:20
%         z_sum=z_sum+z_margin_top(:,:,g)+z_margin_right(:,:,g);
%     end
    
    clf;
    hold on;
%     axis equal;
    surf(x,y,z_sum);
    caxis([0 5])
    colorbar;
%     for i=1:length(node)-1 
%         if node(i).trans==1 && node(i).sensing ~=1
%             plot3(node(i).x,node(i).y,100,'wo');
%         elseif node(i).trans==1 && node(i).sensing ==1
%             plot3(node(i).x,node(i).y,100,'ys');
%         end    
%          text(node(i).x+1,node(i).y,100, num2str(node(i).hop), 'Color','yellow');
%          text(node(i).x,node(i).y+2,100,num2str(i),'Color','white');
%     end
%     plot3(poi_x,poi_y,100.*ones(1,length(poi_x)),'g*');      
    shading interp;
%     view(0,90);
%     colormap('Jet');
end