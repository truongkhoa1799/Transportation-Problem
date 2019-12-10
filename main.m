clear;

SIZE_CUS = 10;
SIZE_WH = 8;
INTERVAL_LOW = 5;
INTERVAL_HIGH = 6;
 
% initial data
demand = randi([40 60] , 1, SIZE_CUS);
cost_operating = random('uniform' , INTERVAL_LOW, INTERVAL_HIGH , [1, SIZE_WH]);
cost_transport = random('uniform' , INTERVAL_LOW, INTERVAL_HIGH , [SIZE_WH , SIZE_CUS]);
%---------------------------------log file--------------------------------
fid = fopen('data2.txt','w');
if fid == -1
    error(' Cannot open log file.');
end
fprintf(fid , "Demand of each customers:\n");
for a = 1:SIZE_CUS
    fprintf(fid,"[%d]:%d \t" , a , demand(a));
end

fprintf(fid,"\n\nCost operating for each warehouse:\n");
for a = 1:SIZE_WH
    fprintf(fid,"[%d]:%.2f \t" , a , cost_operating(a));
end

fprintf(fid,"\n\nCost per unit transported by warehouse i to customers j:\n\t\t");
for a = 1:SIZE_CUS
    fprintf(fid,"Cus[%d]\t" , a);
end
fprintf(fid,"\n");
for a = 1:SIZE_WH
    fprintf(fid,"Warehouse[%d]:\t",a);
    for b = 1:SIZE_CUS
        fprintf(fid," %.2f\t",cost_transport(a,b));
    end
    fprintf(fid,"\n");
end
fclose(fid);
%-------------------------------------------------------------------------
%inital variables
x = intvar(SIZE_WH , SIZE_CUS);
wh_status = binvar(1 , SIZE_WH); 
%------------------------------------find optimal solutions---------------------
constraint = [  sum(x , 1) == demand , 
    
                transpose(sum(x , 2)) <= wh_status.*sum(demand), 
                
                x>=0
              ];
        
objective = sum(sum(x.*cost_transport , 1) , 2) + sum(wh_status.*cost_operating);

ops = sdpsettings('solver','mosek','verbose',1,'debug',1);
optimize(constraint , objective , ops);
%----------------------------------- log file ---------------------------
fid = fopen('output2.txt','w');
fprintf(fid,"Path transport:\n\t\t");
for a = 1:SIZE_CUS
    fprintf(fid,"Cus[%d]\t" , a);
end
fprintf(fid,"\n");
for a = 1:SIZE_WH
    fprintf(fid,"Warehouse[%d]:\t",a);
    for b = 1:SIZE_CUS
        fprintf(fid,"  %.2d\t",value(x(a,b)));
    end
    fprintf(fid,"\n");
end
fprintf(fid,"\nwarehouse status:\n");
for a = 1:SIZE_WH
    fprintf(fid,"WH[%d]\t" , a);
end
fprintf(fid,"\n");
for a = 1:SIZE_WH
    fprintf(fid,"  %.2d\t" ,value(wh_status(a)) );
end
fprintf(fid,"\n\nTotal amount: %.5f\n" , value(sum(objective)));
fclose(fid);

