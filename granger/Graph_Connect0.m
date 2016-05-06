function Graph_Connect(x,y)
%输入: x为一个int向量,例如n=5,x=[1,2,3,4,5]
%      y为三维int向量,例如y=[2,3,1]或者y=[5,2,1]
%  输出:画图，其中
%（1）每个x中的整数用一个小圆圈圈起来,然后均匀分布在一个虚拟的圆圈上（圆圈不需要出现） 
%（2）根据y中的值用一个带箭头的线将整数所在的圈连接起来，即y中前两个数对应x中的点，第三个数若为1，则按照y中前两个数的顺序添加带箭头的连线，第三个数若为零，则将已经有的连线去掉。
%          如y=[2,3,1]，则2-----〉3,  添加一个从2到3的箭头连线
%          如y=[5,2,1]，则5-----〉2   添加一个从5到2的箭头连线
%          如y=[2,5,1]，则5<-----〉2 添加一个从2到5的箭头连线 
%          如y=[5,2,0]，则5<----- 2   删除一个从5到2的箭头连线

%检查x是否为是一个行向量
figure(1);hold on;
if (size(x,1)>size(x,2))
    x=x';
end
n=size(x,2);%n:表示x这个自然数向量的长度

%让x中的每个整数均匀的分布在一个虚拟的圆圈上
vir_r=10;%虚拟圆圈的半径
r=0.5;%圈上数字的小圆圈的半径

dita=linspace(0,2*pi,n+1);

sita=0:pi/20:2*pi;
% figure(1);
extend=1;% 将绘图区域扩大一点
axis([-vir_r-extend,vir_r+extend,-vir_r-extend,vir_r+extend]);
hold on;

for i=1:n 
    str=int2str(x(i));
    %vir_r*cos(dita(i))-------------小圆圈圆心的横坐标
    %vir_r*sin(dita(i)--------------小圆--------纵坐标
    text(vir_r*cos(dita(i)),vir_r*sin(dita(i)),str);%在小圆圈中写数字
    %在小圆圈的圆心处绘制一个半径为r的圆
    plot(vir_r*cos(dita(i))+r*cos(sita),vir_r*sin(dita(i))+r*sin(sita)); 
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%根据y值绘制箭头
%检查y是否为一个行向量,不是则返回
if(size(y,1)>size(y,2))
    return;
end

lable=y(3);

%划线程序主要思路: 划线程序根据y值,连接从起点到终点的小圆圆心,并且绘制箭头
%
%
arrowlength=r;%箭头所在等边三角形的高的长度
if(lable==1)%划线程序
    startpoint_x=vir_r*cos(dita(y(1)));
    startpoint_y=vir_r*sin(dita(y(1))); 
    
    %因为箭头需要退到圆圈外面,此时为临时终点
    tempendpoint_x=vir_r*cos(dita(y(2)));
    tempendpoint_y=vir_r*sin(dita(y(2)));
    
    
    k=(tempendpoint_y-startpoint_y)/(tempendpoint_x-startpoint_x);%斜率
    
    if(startpoint_x<tempendpoint_x)%从左往右绘线
        
        if(k==0)
            endpoint_x=tempendpoint_x-r;
            endpoint_y=tempendpoint_y;
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y]); 
            
            plot([endpoint_x endpoint_x-arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5]);
            plot([endpoint_x endpoint_x-arrowlength*0.866],[endpoint_y endpoint_y-arrowlength*0.5]);
        else
             angle=atan(k);
            %不是水平情况时,终点的退后情况
            endpoint_x=tempendpoint_x-r*cos(angle);
            endpoint_y=startpoint_y+k*(endpoint_x-startpoint_x);
            
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y]); 
            
            %根据解析几何关系,绘制箭头上沿部分
            uparrow_x=endpoint_x-arrowlength*cos(angle)-arrowlength*1.732/3*sin(angle);
            uparrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)+1/k*1.732/3*arrowlength*sin(angle);            
            plot([endpoint_x uparrow_x],[endpoint_y uparrow_y]);
            %plot([endpoint_x-r endpoint_x-r-arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5]);
            
            %根据解析几何关系,绘制箭头下沿部分
            downarrow_x=endpoint_x-arrowlength*cos(angle)+arrowlength*1.732/3*sin(angle);
            downarrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)-1/k*1.732/3*arrowlength*sin(angle);
            plot([endpoint_x downarrow_x],[endpoint_y downarrow_y],'r');          
        end
    end
    
    if(startpoint_x>tempendpoint_x)%从右往左绘线
        if(k==0)
            endpoint_x=tempendpoint_x+r;
            endpoint_y=tempendpoint_y;
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y]); 
            
            plot([endpoint_x endpoint_x+arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5]);
            plot([endpoint_x endpoint_x+arrowlength*0.866],[endpoint_y endpoint_y-arrowlength*0.5]);
        else
             angle=atan(k)+pi;%反正切函数返回值在[-0.5*pi,0.5*pi]之间,+pi恢复到原来的角度
            %不是水平情况时,终点的前移情况
            endpoint_x=tempendpoint_x-r*cos(angle);
            endpoint_y=startpoint_y+k*(endpoint_x-startpoint_x);
            
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y]); 
            
            %根据解析几何关系,绘制箭头上沿部分
            uparrow_x=endpoint_x-arrowlength*cos(angle)-arrowlength*1.732/3*sin(angle);
            uparrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)+1/k*1.732/3*arrowlength*sin(angle);            
            plot([endpoint_x uparrow_x],[endpoint_y uparrow_y]);
            %plot([endpoint_x-r endpoint_x-r-arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5]);
            
            %根据解析几何关系,绘制箭头下沿部分
            downarrow_x=endpoint_x-arrowlength*cos(angle)+arrowlength*1.732/3*sin(angle);
            downarrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)-1/k*1.732/3*arrowlength*sin(angle);
            plot([endpoint_x downarrow_x],[endpoint_y downarrow_y],'r');         
        end
    end
end

if(lable==0)%擦出上述箭头的程序,完全按照上述绘图程序,只是这一次绘制的是同背景颜色一致的带箭头直线
    startpoint_x=vir_r*cos(dita(y(1)));
    startpoint_y=vir_r*sin(dita(y(1))); 
    
    %因为箭头需要退到圆圈外面,此时为临时终点
    tempendpoint_x=vir_r*cos(dita(y(2)));
    tempendpoint_y=vir_r*sin(dita(y(2)));
    
    
    k=(tempendpoint_y-startpoint_y)/(tempendpoint_x-startpoint_x);%斜率
    
    if(startpoint_x<tempendpoint_x)%从左往右绘线
        
        if(k==0)
            endpoint_x=tempendpoint_x-r;
            endpoint_y=tempendpoint_y;
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y],'w'); 
            
            plot([endpoint_x endpoint_x-arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5],'w');
            plot([endpoint_x endpoint_x-arrowlength*0.866],[endpoint_y endpoint_y-arrowlength*0.5],'w');
        else
             angle=atan(k);
            %不是水平情况时,终点的退后情况
            endpoint_x=tempendpoint_x-r*cos(angle);
            endpoint_y=startpoint_y+k*(endpoint_x-startpoint_x);
            
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y],'w'); 
            
            %根据解析几何关系,绘制箭头上沿部分
            uparrow_x=endpoint_x-arrowlength*cos(angle)-arrowlength*1.732/3*sin(angle);
            uparrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)+1/k*1.732/3*arrowlength*sin(angle);            
            plot([endpoint_x uparrow_x],[endpoint_y uparrow_y],'w');
            %plot([endpoint_x-r endpoint_x-r-arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5]);
            
            %根据解析几何关系,绘制箭头下沿部分
            downarrow_x=endpoint_x-arrowlength*cos(angle)+arrowlength*1.732/3*sin(angle);
            downarrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)-1/k*1.732/3*arrowlength*sin(angle);
            plot([endpoint_x downarrow_x],[endpoint_y downarrow_y],'w');          
        end
    end
    
    if(startpoint_x>tempendpoint_x)%从右往左绘线
        if(k==0)
            endpoint_x=tempendpoint_x+r;
            endpoint_y=tempendpoint_y;
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y],'w'); 
            
            plot([endpoint_x endpoint_x+arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5],'w');
            plot([endpoint_x endpoint_x+arrowlength*0.866],[endpoint_y endpoint_y-arrowlength*0.5],'w');
        else
             angle=atan(k)+pi;%反正切函数返回值在[-0.5*pi,0.5*pi]之间,+pi恢复到原来的角度
            %不是水平情况时,终点的前移情况
            endpoint_x=tempendpoint_x-r*cos(angle);
            endpoint_y=startpoint_y+k*(endpoint_x-startpoint_x);
            
            plot([startpoint_x endpoint_x],[startpoint_y endpoint_y],'w'); 
            
            %根据解析几何关系,绘制箭头上沿部分
            uparrow_x=endpoint_x-arrowlength*cos(angle)-arrowlength*1.732/3*sin(angle);
            uparrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)+1/k*1.732/3*arrowlength*sin(angle);            
            plot([endpoint_x uparrow_x],[endpoint_y uparrow_y],'w');
            %plot([endpoint_x-r endpoint_x-r-arrowlength*0.866],[endpoint_y endpoint_y+arrowlength*0.5]);
            
            %根据解析几何关系,绘制箭头下沿部分
            downarrow_x=endpoint_x-arrowlength*cos(angle)+arrowlength*1.732/3*sin(angle);
            downarrow_y=startpoint_y+k*(endpoint_x-arrowlength*cos(angle)-startpoint_x)-1/k*1.732/3*arrowlength*sin(angle);
            plot([endpoint_x downarrow_x],[endpoint_y downarrow_y],'w');         
        end
    end
end
hold off;