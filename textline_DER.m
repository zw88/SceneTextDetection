function [bbox_text,idx_all_selected]=textline_DER(img,bbox,th_conf,th_conf_tl,isshow)
% th_PCV threshold of pair confidence values
% GPs are equal to symbol: CCs, representing detected component candidates
% weights are equal to the confidence values
if ~exist('isshow','var')
    isshow = true;
end
conf=bbox(:,5);
conf_RF = bbox(:,6);
th_RF = 0.48;%0.42
th_cnn_chain =1;

% idx_bbox=bbox_check(bbox);
% bbox=bbox(idx_bbox,:);
[im_height,im_width,ch]=size(img);

% th_numletter=1;
% Pairing
[pairsMap,idx_val]=leterPairs_DER(bbox,th_conf);

% pairs aggregation into textline chains
[Chains1D,Chains2D,all_chains2D]=TL_chains_DER(pairsMap);
idx_all_selected=unique(all_chains2D(:));
%idx_single1=find(bbox(:,5)>0.95);
idx_single1=find(bbox(:,6)>0.99 & bbox(:,5)>0.85 & bbox(:,4)>bbox(:,3));
idx_single2=find(bbox(:,3).*bbox(:,4)>0.0005*im_height*im_width);
idx_single=intersect(idx_single1,idx_single2);

Chains_single=setdiff(idx_single,intersect(idx_all_selected,idx_single));


Chains_single=[];

% textlineInfo=[];
% numText=1;
bbox_text=[];

if length(Chains_single)>0  
        bbox_text=bbox(Chains_single,1:6);
end

 numText=1+length(Chains_single);       
  % fig=imshow(uint8(img)), hold on;
if isshow
   figure,imshow(img);
   hold on
end
for i=1:length(Chains2D)
    cur_chain=Chains2D{i};    
    cur_chain=unique(cur_chain(:));
    idx_cur_chain=idx_val(cur_chain);
    numReg=length(idx_cur_chain);
    
    % if a single chain only includes one pairs, we keep this pairs when
    % its pair condifence value is larger than 40, otherwise discarding
    % single pair textline
%     if numReg==1
%         if conf(idx_cur_chain)<0.95
%             numReg=0;
%         end
%     end
            
    
    if numReg==2
        if mean(conf(idx_cur_chain))<0.9 && max(conf(idx_cur_chain))<1 || mean(conf_RF(idx_cur_chain))<0.9 && max(conf_RF(idx_cur_chain))<1
            numReg=0;
            continue;
        end
        
        box1 = bbox(idx_cur_chain(1),:);
        box1_width = box1(3);
        box1_height = box1(4);
        box2 = bbox(idx_cur_chain(2),:);
        box2_width = box2(3);
        box2_height = box2(4);
%         figure,imshow(img)
%         hold on
%         box2 = bbox(idx_cur_chain,1:4);
%         for kk = 1:2
%             xmin = box2(kk,1);
%             ymin = box2(kk,2);
%             width = box2(kk,3);
%             height = box2(kk,4);
%             xmax = xmin + width;
%             ymax = ymin + height;
%             plot([xmin xmax xmax xmin xmin], [ymin ymin ymax ymax ymin],'r');
%         end
        
        center1_x = box1(1) + box1_width/2;
        center2_x = box2(1) + box2_width/2;
        gap = abs(center1_x - center2_x);
        mean_height = (box1_height + box2_height)/2;
        if gap > 2*mean_height
            numReg = 0;
            if box1(6)>th_RF & 1.1*box1(3)<box1(4)
                bbox_text(numText,:) = box1;
                numText = numText + 1;
            end
            if box2(6)>th_RF & 1.1*box2(3)<box2(4)
                bbox_text(numText,:) = box2;
                numText = numText + 1;
            end
            
            if isshow
                plot([box1(1) box1(1)+box1(3) box1(1)+box1(3) box1(1) box1(1)], [box1(2) box1(2) box1(2)+box1(4) box1(2)+box1(4) box1(2)],'y');
                plot([box2(1) box2(1)+box2(3) box2(1)+box2(3) box2(1) box2(1)], [box2(2) box2(2) box2(2)+box2(4) box2(2)+box2(4) box2(2)],'y');
            end
            
            
        end
            


    end            

    if numReg>0
        
 


numReg=length(idx_cur_chain);

%  for jj=1:numReg
%       cur_bbox=bbox(idx_cur_chain(jj),:);
%  
%          xx_min=min(cur_bbox(:,1));
%          xx_max=max(cur_bbox(:,1)+cur_bbox(:,3)-1);
%          yy_min=min(cur_bbox(:,2));
%          yy_max=max(cur_bbox(:,2)+cur_bbox(:,4)-1);
%      if cur_bbox(6)==0
%         plot([xx_min xx_min xx_max xx_max xx_min],[yy_min yy_max yy_max yy_min yy_min],'b','LineWidth',1);    
%      else
%        plot([xx_min xx_min xx_max xx_max xx_min],[yy_min yy_max yy_max yy_min yy_min],'y','LineWidth',1);      
%      end
%  end
          
          

%   cur_chainW=textTowords_deepERs(idx_cur_chain,bbox);

%     numWords=length(wordsInfo);
  
    cur_chainW{1}=idx_cur_chain;
    numWords=length(cur_chainW);
    for k=1:numWords
        if k==(numWords+1)
            idx_curword=idx_cur_chain
        else
            
           idx_curword=cur_chainW{k};
        end
        
        cur_bbox=bbox(idx_curword,1:4);
        cur_conf=bbox(idx_curword,5);
   
        if isshow
        for nn = 1:size(cur_bbox,1)
            xmin = cur_bbox(nn,1);
            ymin = cur_bbox(nn,2);
            xmax = xmin+cur_bbox(nn,3);
            ymax = ymin+cur_bbox(nn,4);
            plot([xmin xmin xmax xmax xmin], [ymin ymax ymax ymin ymin],'c');
            
        end
        end

%        cur_bbox2 = bbox(idx_curword,:);
%        cur_bbox2 = checkChains(img,cur_bbox2);
%        cur_bbox = cur_bbox2(:,1:4);
%        cur_conf = cur_bbox2(:,5);
        
        
%        cnn_conf = bbox(idx_curword,6);
        
%         cur_bbox_coordinate=cur_bbox;
%         cur_bbox_coordinate(:,3)=cur_bbox(:,1)+cur_bbox(:,3)-1;
%         cur_bbox_coordinate(:,4)=cur_bbox(:,2)+cur_bbox(:,4)-1;
        
%         word1D=[]
%         word2D=[];
%         idxReg=cur_chainW{k};
%         word_conf=conf(idxReg);
%         for tt=1:length(idxReg)
%             word1D=[word1D; mserTree.reg1D{idxReg(tt)}];
%             word2D=[word2D; mserTree.reg2D{idxReg(tt)}];
%         end
        
        
%         GPs1DL=wordsInfo{k}.GPs1DL;
%         GPs2DL=wordsInfo{k}.GPs2DL;
%         locationGPs=wordsInfo{k}.locationGPs;
%         mWeight=mean(CCV_new(idxGPs));% mean confident values of the word
%         word_ccv=CCV_new(idxGPs); % confidence values of components in the word



       cur_conf_rf = bbox(idx_curword, 6);
       
      
        if mean(cur_conf_rf) < th_RF%0.5
            continue;
        end





       if mean(cur_conf)>th_conf_tl
          xx_min=min(cur_bbox(:,1));
          xx_max=max(cur_bbox(:,1)+cur_bbox(:,3)-1);
          yy_min=min(cur_bbox(:,2));
          yy_max=max(cur_bbox(:,2)+cur_bbox(:,4)-1);
%       if k==(numWords+1)
%           plot([xx_min xx_min xx_max xx_max xx_min],[yy_min yy_max yy_max yy_min yy_min],'y','LineWidth',1);
%       else
%           
%           plot([xx_min xx_min xx_max xx_max xx_min],[yy_min yy_max yy_max yy_min yy_min],'r','LineWidth',2);
%       end
         box_width=xx_max-xx_min;
         box_height=yy_max-yy_min;
     
%       rebox_height=0.015;
%       rebox_width=0.0075;
%       textBox=[round(xx_min-rebox_width*box_width) round(yy_min-rebox_height*box_height) round(box_width*(1+2*rebox_width)) round(box_height*(1+2*rebox_height))];
        bbox_text(numText,:)=[xx_min yy_min box_width box_height mean(cur_conf) mean(cur_conf_rf)];
%       textlineInfo{numText}.textline1D=word1D;
%       textlineInfo{numText}.textline2D=word2D;
%       textlineInfo{numText}.idxReg=idxReg;
%       textlineInfo{numText}.conf=word_conf;
%       textlineInfo{numText}.textBox=textBox;
%       textlineInfo{numText}.meanWeight=mWeight;
%       textlineInfo{numText}.weight=word_ccv;
%       
%       textlineInfo{numText}.location=textBox;
%       textlineInfo{numText}.locationGPs=locationGPs;
      
% 
% 
%         for nn = 1:size(cur_bbox,1)
%             xmin = cur_bbox(nn,1);
%             ymin = cur_bbox(nn,2);
%             xmax = xmin+cur_bbox(nn,3);
%             ymax = ymin+cur_bbox(nn,4);
%             plot([xmin xmin xmax xmax xmin], [ymin ymax ymax ymin ymin],'c');
%         end
% 
%         plot([xx_min xx_min xx_max xx_max xx_min],[yy_min yy_max yy_max yy_min yy_min],'r','LineWidth',2);
%         
        numText=numText+1;
       end
       
%        if mean(cnn_conf) > th_cnn_chain
%           xx_min=min(cur_bbox(:,1));
%           xx_max=max(cur_bbox(:,1)+cur_bbox(:,3)-1);
%           yy_min=min(cur_bbox(:,2));
%           yy_max=max(cur_bbox(:,2)+cur_bbox(:,4)-1);
%        
%           box_width=xx_max-xx_min;
%           box_height=yy_max-yy_min;
%           bbox_text(numText,:)=[xx_min yy_min box_width box_height mean(cur_conf)];
%        end
       
    end
    end
end


% if no a word in a image, re-check confidence values of components, keep
% the component of the hightest confidence value as a valid word.

%  hold off
%     
% sstr= sprintf('ICDAR2011_textline/deepERs_icdar2011_%d.jpg',idx_img);
% 
% saveas(fig,sstr,'jpg');