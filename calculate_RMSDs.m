function[]=calculate_RMSDs(options)
%% path�̒ǉ�
addpath('algo');
addpath('algo\sub');

%% options�̊m�F
try
    method=options.method;
catch
    method='three_points';
end
if ~strcmp(method,'ICP') && ~strcmp(method,'three_points')
    method='three_points';
end
try
    use_label=options.use_label;
catch
    use_label=true;
end
try
    permit_mirror=options.permit_mirror;
catch
    permit_mirror=false;
end
try
    ignore_atom=options.ignore_atom;
catch
    ignore_atom=1;
end
try 
    clus_mode=options.clus_mode;
catch
    clus_mode=false;
end
try
    reduction=options.reduction;
catch
    reduction=true;
end
try
    iter_num=options.iter_num;
catch
    iter_num=4;
end
if ~reduction
    iter_num=1;
end
%% query��target�t�H���_�̒��g������
qInfo=dir('query'); %name�����Ƀt�@�C�������i�[
query_num=length(qInfo)-2; %�t�@�C���̐�
tInfo=dir('target'); %name�����Ƀt�@�C�������i�[
target_num=length(tInfo)-2; %�t�@�C���̐�

if(query_num==0 || target_num==0)
    fprintf('query�t�H���_ or target�t�H���_ �Ƀt�@�C��������܂���\n')
    return
end

%% main����
for q=1:query_num
    for t=1:target_num
        query=qInfo(q+2).name;
        target=tInfo(t+2).name;
        if ~strcmp('csv',query(length(query)-2:length(query))) || ~strcmp('csv',target(length(target)-2:length(target)))
            continue
        end
        
        
        if clus_mode
            if ~strcmp(query,target)
                continue
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % �f�[�^�̓ǂݍ���
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data1=importdata(strcat('query\',query));
        data_num_1=data1(1,1);
        mol_num_1=(size(data1,1)-1)/data_num_1;

        data2=importdata(strcat('target\',target));
        data_num_2=data2(1,1);
        mol_num_2=(size(data2,1)-1)/data_num_2;

        data_struct_1(1:mol_num_1)=struct('pos',zeros(3,data_num_1),'label',zeros(1,data_num_1));
        data_struct_2(1:mol_num_2)=struct('pos',zeros(3,data_num_2),'label',zeros(1,data_num_2));

        for i=1:mol_num_1
            data_struct_1(i).pos=data1(data_num_1*(i-1)+2:data_num_1*i+1,1:3)';
            
            final_label=true(1,data_num_1);
            data_struct_1(i).label=data1(data_num_1*(i-1)+2:data_num_1*i+1,4)';
            for ind=ignore_atom
                final_label=final_label&(data_struct_1(i).label~=ind);
            end
            data_struct_1(i).pos=data_struct_1(i).pos(:,final_label);
            data_struct_1(i).label=data_struct_1(i).label(final_label);
            if ~use_label
                data_struct_1(i).label=ones(1,data_num_1);
            end
            
        end

        for i=1:mol_num_2
            data_struct_2(i).pos=data2(data_num_2*(i-1)+2:data_num_2*i+1,1:3)';
            final_label=true(1,data_num_2);
            data_struct_2(i).label=data2(data_num_2*(i-1)+2:data_num_2*i+1,4)';
            for ind=ignore_atom
                final_label=final_label&(data_struct_2(i).label~=ind);
            end
            data_struct_2(i).pos=data_struct_2(i).pos(:,final_label);
            data_struct_2(i).label=data_struct_2(i).label(final_label);
            if ~use_label
                data_struct_2(i).label=ones(1,data_num_2);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %RMSD�v�Z�̎��s
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(strcat(query(1:length(query)-4),'//',target(1:length(target)-4),'\n'))
        result=zeros(mol_num_1,mol_num_2);
        tot=mol_num_1*mol_num_2; 
        now_num=0;
        progress=0.1; 
        for i=1:mol_num_1
            for j=1:mol_num_2
                now_num=now_num+1;
                if(now_num/tot>progress)
                    fprintf('*')
                    progress=progress+0.1;
                end
                if strcmp(method,'three_points')
                    result(i,j)=three_points(data_struct_1(i).pos,data_struct_2(j).pos,data_struct_1(i).label,data_struct_2(j).label,permit_mirror,reduction,iter_num);
                else
                    result(i,j)=three_points(data_struct_1(i).pos,data_struct_2(j).pos,data_struct_1(i).label,data_struct_2(j).label,permit_mirror);
                end
            end
        end
        fprintf('\n')
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %�v�Z���ʂ̕ۑ�
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        csvwrite(strcat(query(1:length(query)-4),'_',target(1:length(target)-4),'_result.csv'),result)
    end
end