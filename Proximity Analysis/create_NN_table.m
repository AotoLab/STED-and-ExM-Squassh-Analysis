function nnT = create_NN_table(Y, Y_id, X, X_id)

varnames = {'NN_Idx', 'cA_objId','cN_objId','point_D'};
Idx = zeros(size(Y_id,1),1); D = zeros(size(Y_id,1),1); cNid = zeros(size(Y_id,1),1);
for i = 1:size(Y_id,1)
    [Idx(i),D(i)] = knnsearch(X,Y(i,:)); cNid(i) = X_id(Idx(i));
end
nnT = table(Idx,Y_id,cNid,D,'VariableNames',varnames);
end