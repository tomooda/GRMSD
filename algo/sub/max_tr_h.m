% �n���K���[�@�ɂ�銄������

function [T] = max_tr_h(X)
    rows = size(X,1);
    T = Hungarian2(X,zeros(rows,rows),rows);
    T = sparse((reshape(T,rows,rows))');
end