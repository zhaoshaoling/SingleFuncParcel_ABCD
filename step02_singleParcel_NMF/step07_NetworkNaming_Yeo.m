%% correspondence to Yeo 17 systems with our atlas to name them

clear;
SingleParcellation_Folder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/singleParcel4abcd';
ParcPath = [SingleParcellation_Folder '/SingleAtlas_Analysis/Group_AtlasLabel.mat'];
ParcMat = load(ParcPath);

ParcLabels = [ParcMat.sbj_AtlasLabel_lh; ParcMat.sbj_AtlasLabel_rh];
ParcLegend = unique(ParcLabels);
ParcLegend = ParcLegend(2:end);
YeoAtlasFolder = '/ibmgpfs/cuizaixu_lab/zhaoshaoling/NMF_NeuronCui/Yeo_atlas';
YeoAtlas=cifti_read([YeoAtlasFolder '/Yeo2011_17Networks_N1000.dlabel.nii']);

YeoLabels=YeoAtlas.cdata;
NetworkName = {'fs medial wall','Visual', 'Visual', 'Motor', 'Motor', 'DA', 'DA', 'VA', 'VA', ...
               'Limbic', 'Limbic', 'FP', 'FP', 'FP', 'DM', 'DM', 'DM', 'DM'};
% NetworkName = {'fs medial wall' 'Visual1', 'Visual2', 'Motor1', 'Motor2', 'DA1', 'DA2', 'VA1', 'VA2', ...
%                'Limbic1', 'Limbic2', 'FP1', 'FP2', 'FP3', 'DM1', 'DM2', 'DM3', 'DM4'};
LookUpTable = [0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17];

YeoLegend = unique(YeoLabels);   
size = zeros(1,length(YeoLegend));
for i = 1:length(YeoLegend)
    size(i)=length(find(YeoLabels == YeoLegend(i)));
end

%%
Parc2YeoNo = zeros(1, 17);
for i = 1:length(ParcLegend)
    Indices = find(ParcLabels == ParcLegend(i));
    size=length(Indices);
    Yeo4Parc_i = YeoLabels(Indices);
    Yeo4Parc_i_Legend = unique(Yeo4Parc_i);
    clear frequency;
    frequency = zeros(length(Yeo4Parc_i_Legend),3);
    frequency(:,2)=Yeo4Parc_i_Legend';
    for j = 1:length(Yeo4Parc_i_Legend)
        frequency(j,1) = length(find(Yeo4Parc_i == Yeo4Parc_i_Legend(j)));
        frequency(j,3) = round(frequency(j,1)/size*100);
    end
    frequency=sortrows(frequency,'descend');
    outstr=[num2str(i) ':'];
    for j = 1:length(Yeo4Parc_i_Legend)
        if(frequency(j,3)<20)
            break;
        end
        netNum=find(LookUpTable==frequency(j,2));
        outstr = [outstr ' ' NetworkName{netNum} '/' num2str(frequency(j,3)) '%.'];
    end
    %[~, mostFrequent] = max(frequency);
    %Parc2YeoNo(i) = find(LookUpTable==Yeo4Parc_i_Legend(mostFrequent));
    % display the network name
    %disp([num2str(i) ': ' num2str(NetworkName{Parc2YeoNo(i)})]);
    disp(outstr);
end
