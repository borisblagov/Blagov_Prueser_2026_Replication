function choice_tab = choice_extract(targetchoice,spec_vec,targetv_tab,targetv_str)

choice_vec = cell(size(spec_vec));
choice_tab = targetv_tab(:,[{targetv_str}]);
for ll = 1:size(spec_vec,2)
    choice_vec{ll} = strcat(targetchoice,'_',spec_vec{ll});
    Exist_Column  = strcmp(choice_vec{ll},targetv_tab.Properties.VariableNames);
    val = Exist_Column(Exist_Column==1) ;
    if val
        choice_tab = [choice_tab,targetv_tab(:,choice_vec{ll})];
    end
end
% choice_tab = targetv_tab(:,[{targetv_str} choice_vec]);

