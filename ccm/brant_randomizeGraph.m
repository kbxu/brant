function G = brant_randomizeGraph(G, kc)
% kc: keep connectivity
% adapted from randomizeGraph_kc was used to randomizing graph's connected matrix,and
% works for symmetric binary network
% Ref. R.Milo 2004, On the uniform generation of random graphs with prescribed degree sequences
% Ref. Sergei Maslov 2002, Specificity and Stability in Topology of Protein Networks
% Written by: XU Kaibin, Dec,2015

N = size(G, 1);     %number of nodes
G(1:(N+1):end) = 0; %clear self-edges
[I, J] = find(triu(G, 1));
M = length(I);        %number of edges
T = M;

for i = 1:T
    % Randomly choice edge1 & edge2
    edges = unidrnd(M, 2, 1);
    while(edges(1) == edges(2)),   edges = unidrnd(M, 2, 1);    end
    
    x1 = I(edges(1));
    x2 = I(edges(2));
    y1 = J(edges(1));
    y2 = J(edges(2));
    
    if(~isempty(intersect([x1, y1], [x2, y2]))),   continue;     end
    
    if kc == 1
    % Back-up record
        bu_G = G;
    end
    
    if(rand(1) > 0.5)
        if((G(x1, y2) == 0) && (G(x2, y1) == 0))
            G(x1, y2) = 1;
            G(y2, x1) = 1;
            G(x2, y1) = 1;
            G(y1, x2) = 1;
            
            G(x1, y1) = 0;
            G(x2, y2) = 0;
            G(y1, x1) = 0;
            G(y2, x2) = 0;
            
            node_x_new = [x1; x2];
            node_y_new = [y2; y1];
        else
            continue
        end
    else
        if((G(x1, x2) == 0) && (G(y1, y2) == 0))
            G(x1, x2) = 1;
            G(x2, x1) = 1;
            G(y1, y2) = 1;
            G(y2, y1) = 1;
            
            G(x1, y1) = 0;
            G(x2, y2) = 0;
            G(y1, x1) = 0;
            G(y2, x2) = 0;
            
            node_x_new = [x1; y1];
            node_y_new = [x2; y2];
        else
            continue
        end
    end
    
    if ((kc == 1) && (~brant_isconnected(G)))
        G = bu_G;
    else
        I(edges) = node_x_new;
        J(edges) = node_y_new;
    end
end   
