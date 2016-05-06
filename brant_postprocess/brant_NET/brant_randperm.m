function [RandA] = brant_randperm(A)
[M N] = size(A);
%  A = triu(A);
I = randperm(M);
RandA = A(I,I);
%  RandA = B+B';
% % [I J] = find(A);
% % temp = sum(A);
% % % (length(I));
% % 
% % temp_I = randperm(length(I)); 
% % count = 0;
% % while count == 0
% %     temp_J = randperm(length(I)); 
% %     I = I(temp_I);
% %     J = J(temp_J);
% %     if sum(I==J)>0
% %     else
% %         count = 1;
% %     end
% % 
% % end
% % 
% % 
% % B = zeros(N); 
% % for i = 1:length(I)
% %     B(I(i),J(i)) = 1;    
% % end
% % RandA = B+B';
% % Degree = sum(A);
% % B = zeros(N);
% % Visist = zeros(1,N);
% % for i= 1:N-1
% %     i
% %     if i ==1
% %         Temp = randperm (N-i);
% %         temp = Temp(1:Degree(i));
% %         B(i,i+temp) = 1;
% %         C = B + B';
% %     else
% %         Temp = randperm (N-i);
% %         D = Degree(i)-sum(C(i,:))
% %         if D>0
% %             temp = Temp(1:D);
% %             if length(temp)>0
% %                 B(i,i+temp) = 1;
% %                 C = B + B';
% %             end
% %         end
% %     end
% % 
% % end
% % RandA = C;
