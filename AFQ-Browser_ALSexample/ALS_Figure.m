load SaricaetalHBM2017.mat
% Script for figure 1
tracts = [3 4 9 10 11 12];
fgnames = AFQ_get(afq, 'fgnames');
als = AFQ_get(afq, 'metadata','class');
als = strcmp(als,'ALS')
nodes = 6:95;
colors = [1 0 0; 0 0 1];
sub = 21;
close all
properties = {'fa' 'rd'};
axisscale = {[minmax(nodes) .3 .85], [minmax(nodes) .3 .8]}

%% Plots
c=0; close all
for p = 1:length(properties)
    for ii = tracts
        c = c+1;
        figure(1);subplot(2,6,c); hold
        data = AFQ_get(afq, fgnames{ii}, properties{p});
        % Plot patients as light lines for CSTs
        if ii==3 || ii==4
            plot(repmat(nodes,[sum(als==1),1])',data(als==1,nodes)','-', 'color', [.65 .65 1],'linewidth',.5)
        end
        % Plot groups means and SDs
        for jj = 1:2
            d = data(als==jj-1,nodes);
            m = nanmean(d);
            sd = nanstd(d);
            n = sum(als==0);
            se = sd./sqrt(n);
            % SD
            patch([nodes fliplr(nodes)], [m+sd fliplr(m-sd)],colors(jj,:), ...
                'edgealpha', 0, 'facealpha', .3);
            % Plot
            plot(nodes, m, '-', 'color', colors(jj,:), 'linewidth',2);
            %axis([5 95 .55 .75])
            if jj==1
                
                [zs i] = max(sum((data(als,nodes)-repmat(m,[sum(als) 1]))./repmat(sd,[sum(als) 1])<-1));
                fprintf('\n%s %s %d at node %d',fgnames{ii},properties{p},zs,i)
                %fprintf('patient max %.2f min %.2f zscore prop %s tract %s', zs(1),zs(2),properties{p},fgnames{ii})
            end
        end
        
        % Format axis and save figure
        hold off
        %xlabel('Distance Along Fiber Bundle','fontsize',14)
        set(gca,'fontsize',12,'xticklabel',[])
        axis(axisscale{p})
        %print(sprintf('MSpatient-Tract%d-%s.pdf',ii,properties{p}),'-dpdf')
        %close
        
        % Plot group comparison and SEs
        figure(2);subplot(2,6,c); hold
        for jj = 1:2
            d = data(als==jj-1,nodes);
            m = nanmean(d);
            sd = nanstd(d);
            n = sum(als==0);
            se = sd./sqrt(n);
            % SD
            patch([nodes fliplr(nodes)], [m+se fliplr(m-se)],colors(jj,:), ...
                'edgealpha', 0, 'facealpha', .3);
            % Plot
            plot(nodes, m, '-', 'color', colors(jj,:), 'linewidth',2);
            %axis([5 95 .55 .75])
        end
        % Format axis and save figure
        hold off
        %xlabel('Distance Along Fiber Bundle','fontsize',14)
        set(gca,'fontsize',12,'xticklabel',[])
        axis(axisscale{p})
        %print(sprintf('GroupComp-MSpatient-Tract%d-%s.pdf',ii,properties{p}),'-dpdf')
        %close
    end
end
figure(1); set(gcf,'units','inches','position',[1 1 14 4]);
print('STD-ALSSpatient.pdf','-dpdf');
figure(2); set(gcf,'position',[350 847 1279 385]);
print('SE-ALSpatient.pdf','-dpdf');

%% Render fibers
cd ~/git/AFQ-Browser_data/AFQ-Browser_example
fg = fgRead('exampleFibers.mat');
im = niftiRead('t1_class_2DTI.nii.gz');
im.data = im.data==4;
msh = AFQ_meshCreate(im,'boxfilter',5)

lh=AFQ_RenderFibers(fg(3),'color',[1 .5 0],'numfibers',500)
AFQ_RenderFibers(fg(19),'color',[0 .5 1],'numfibers',500,'newfig',0)
AFQ_RenderFibers(fg(13),'color',[1 0 1],'numfibers',500,'newfig',0)
AFQ_RenderFibers(fg(9),'color',[.7 .7 .7],'numfibers',500,'newfig',0,'radius',.5)

fg9 = dtiResampleFiberGroup(fg(9),100,'N');
for ii = 1:length(fg9.fibers)
    fg9.fibers{ii} = fg9.fibers{ii}(:,1:40);
end
AFQ_RenderFibers(fg9,'color',[.4 0 .6],'numfibers',500,'newfig',0,'radius',1)
patch(msh.tr)
shading interp
axis image
axis off
view(-24,24)
camlight(lh,'left')

print('MS-Rendering.png','-dpng')

