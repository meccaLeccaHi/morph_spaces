% plot_morph_space.m
%
% plot face (MODALITY = 'f') or voice (MODALITY = 'v') morph trajectories
%
% last modified 03-09-17
% apj


MODALITY                                = 'v';

% paths
MAIN_DIR                               = fullfile(filesep,'home',getUserName,'Cloud2','movies','human');

% figure properties
AXES_LINE_COLOR                         = [.6 .6 .6];
AXES_LINE_WEIGHT                        = 2.5;
        
EXEMPLARS_ONLY                          = 0; % plot only full identities
AVERAGE_ONLY                            = 0; % plot only average identity

% in case we want to plot particular individuals
STEP_SWITCH                             = [1 1 1 1];

% set figure properties
switch(MODALITY)
    case 'f'
        AP_SIZE                                 = 0.12; % ave plot size
        MP_SIZE                                 = 0.11; % morph plot size
        X_ADJ                                   = .445;
        Y_ADJ                                   = .452;
        XTickLab                                = [];
        YTickLab                                = [];
        TIT_POS                                 = [1 -6.5 1]; % title bar position
        
        % define which frames we include in movie (if any)
        FRAME_LIST                              = 202+[1:15 15:-1:1]; 
   
        if EXEMPLARS_ONLY
            FRAME_LIST                          = FRAME_LIST(1);
            EX_SAVE_STR                         = '_exemplarsL';
        elseif AVERAGE_ONLY
            FRAME_LIST                          = FRAME_LIST(1);
            EX_SAVE_STR                         = '_norm';
        else
            EX_SAVE_STR                         = [];
            MOVIE_NAME                          = fullfile(MAIN_DIR,'morph_spaces',...
                ['morph_space_mov_' upper(MODALITY) '.avi']);
            
            % create movie object
            VIDEO_OBJ                           = vision.VideoFileWriter(MOVIE_NAME);
            % VIDEO_OBJ.FrameRate                 = 30;
        end
        
    case 'v'
        AP_SIZE                                 = 0.11;
        MP_SIZE                                 = 0.08;
        X_ADJ                                   = .465;
        Y_ADJ                                   = .46;
        XTickLab                                = 0:.25:.5;
        YTickLab                                = fliplr(0:5);
        TIT_POS                                 = [1 -2 1];
        
        FRAME_LIST                              = 202;
        EX_SAVE_STR                             = [];
end

% create figure
figure(2020)
set(2020,'Position',[680 501 1120 840],'Color',[0 0 0])

% loop through frames of movie
for FRAME_NUM = FRAME_LIST
    
        % read-in image matrix
        switch(MODALITY)
            case 'f'
                IMAGE_MAT                               = face_morph_images(FRAME_NUM);
            case 'v'
                load([MAIN_DIR '/voices/voice_overs/syllable/voice_morph_space.mat']);
        end
                
        % declare number of steps on each trajectory
        IDENT_NUM                               = length(IMAGE_MAT.ORDER);
        STEP_NUM                                = length(IMAGE_MAT.RAD);
        STEPS                                   = 1/STEP_NUM:1/STEP_NUM:1;
        
        % clear the figure (re-used in loop)
        clf(2020)
        
        % create main figure axis
        axis([-1 1 -1 1])
        set(gca,'Position',get(gca,'Position').*[.65 .7 1.125 1.075])
        hold on
        
        % set angles for each line on polar plot axes
        RADIUS                                  = .95;   % radius
        NUM_CIRC                                = length(STEPS)+1;   % num circ.lines
        NUM_LINE                                = IDENT_NUM;   % num ang.lines
        RADII                                   = linspace((RADIUS/NUM_CIRC)+.05,RADIUS,NUM_CIRC);
        CIRC_RADII                              = linspace((RADIUS/NUM_CIRC)+.09,RADIUS,NUM_CIRC-1);
        W                                       = 0:.01:2*pi;
        
        % define radial trajectory angles
        OFFSET_ANGLE_RAD                        = [2*pi/NUM_LINE:2*pi/NUM_LINE:2*pi]';
        OFFSET_ANGLE_RAD                        = [OFFSET_ANGLE_RAD(1); OFFSET_ANGLE_RAD(end:-1:2)];
        
        % plot axes circles
        for n = 1:length(CIRC_RADII)
            plot(real(CIRC_RADII(n)*exp(1i*W))-.05,...
            imag(CIRC_RADII(n)*exp(1i*W))-.05,'--',...
                'Color',AXES_LINE_COLOR,...
                'LineWidth',AXES_LINE_WEIGHT)
        end
        
        % plot axes lines
        [POL_X,POL_Y]                           = pol2cart(OFFSET_ANGLE_RAD,RADIUS);
        for I = 1:IDENT_NUM
            line([0 POL_X(I)]-.05,[0 POL_Y(I)]-.05,...
                'LineWidth',AXES_LINE_WEIGHT,...
                'Color',AXES_LINE_COLOR)
        end
        axis off
        
        %% plot average identity
 
        % set figure position
        AX_POS                                  = [(1-AP_SIZE)/2,(1-AP_SIZE)/2,AP_SIZE,AP_SIZE];

        if MODALITY=='f'
            % zoom in on face average image
            cut                                 = 20; % pixel border to remove
            subImage                            = IMAGE_MAT.AVE(2*cut:length(IMAGE_MAT.AVE(:,1,1))-cut,...
                                        cut:length(IMAGE_MAT.AVE(1,:,1))-2*cut,:);
            AVE_IMG                             = imresize(subImage,size(IMAGE_MAT.AVE(:,:,1)));
        else
            AVE_IMG                             = IMAGE_MAT.AVE;
        end

        IMG_COL                                 = AVE_IMG(:,:,1:3); % color channels
        ALPHA                                   = double(AVE_IMG(:,:,4)); % alpha channel

        % create new axes, fill with empty image
        axes('Position',AX_POS)
        image(zeros(size(ALPHA)))

        % beautify plot
        if MODALITY=='v'
            xlabel('sec.','Color','w')
            ylabel('kHz','Color','w')
        else
            set(gca,'Ticklength',[0 0])
        end
        newXTick                                = min(xlim):diff(xlim)/2:max(xlim);
        newYTick                                = [min(ylim):25:max(ylim) max(ylim)];
        set(gca,'Color',[0 0 0],...
            'XTick',newXTick,...
            'XTickLabel',XTickLab,...
            'YLim',[0 100],...
            'YTick',newYTick,...
            'YTickLabel',YTickLab,...
            'LineWidth',AXES_LINE_WEIGHT,...
            'Fontsize',9)
        
        set(gca,'XColor',AXES_LINE_COLOR,...
            'YColor',AXES_LINE_COLOR)

        % create new axes, fill blank with image, drop border
        axes('Position',AX_POS,'Box','off')
        IMG_HAN                                 = imshow(IMG_COL);
        set(IMG_HAN,'AlphaData',ALPHA);
        colormap(hot)
        set(gca,'XTick',[],...
            'YTick',[],...
            'Layer','Bottom')

        % plot title
        TIT_HAN                                 = title('0% (Ave.)',...
                                    'Fontsize',12,...
                                    'Color',AXES_LINE_COLOR,...
                                    'Fontweight','Bold');        
        
        % step through identities
        if ~AVERAGE_ONLY
            for I = 1:IDENT_NUM
                
                % set up angles along tangential trajectory
                OFFSET_ANGLE_TAN            = linspace(OFFSET_ANGLE_RAD(I),...
                                    OFFSET_ANGLE_RAD(I)-(pi/2),...
                                    NUM_CIRC);

                % step through morph levels along each trajectory
                for II = 1:length(STEPS)
                    if (~(EXEMPLARS_ONLY||AVERAGE_ONLY)||...
                            II==length(STEPS))&&STEP_SWITCH(II)

                        % plot radial face/voice in space
                        [RAD_X,RAD_Y]       = pol2cart(OFFSET_ANGLE_RAD(I),RADII(II));
                        AX_POS              = [RAD_X/1.9+X_ADJ,RAD_Y/1.9+Y_ADJ,MP_SIZE,MP_SIZE];
                        axes('Position',AX_POS)
                  
                        IM_HAN              = imshow(IMAGE_MAT.RAD{I,II}(:,:,1:3));
                        set(IM_HAN,'AlphaData',double(IMAGE_MAT.RAD{I,II}(:,:,4)));
                        set(gca(),'XTick',[],...
                                'YTick',[],...
                                'Layer','Bottom')
                        
                        % plot title
                        if I==1
                            T_HAN           = title(sprintf('%d%% ',round(STEPS(II)*100)),...
                                            'Color',AXES_LINE_COLOR,...
                                            'Fontweight','Bold',...
                                            'Fontsize',9);
                            set(T_HAN,'Position',get(T_HAN,'Position').*TIT_POS)
                        end

                        % plot tan face in space
                        if II<4

                            [TAN_X,TAN_Y]   = pol2cart(OFFSET_ANGLE_TAN(II+1),RADII(length(STEPS)));
                            axes('Position',[TAN_X/1.9+X_ADJ,TAN_Y/1.9+Y_ADJ,MP_SIZE,MP_SIZE])

                            IM_HAN          = imshow(IMAGE_MAT.TAN{I,II}(:,:,1:3));
                            set(IM_HAN,'AlphaData',double(IMAGE_MAT.TAN{I,II}(:,:,4)));
                            set(gca(),'XTick',[],...
                                    'YTick',[],...
                                    'Layer','Bottom')
                            % plot title
                            if I==1
                                T_HAN       = title(sprintf('%d%% ',round(STEPS(II)*100)),...
                                            'Color',AXES_LINE_COLOR,...
                                            'Fontweight','Bold',...
                                            'Fontsize',9); 
                                set(T_HAN,'Position',get(T_HAN,'Position').*TIT_POS)
                            end
                        end
                    end
                end
            end
        end
        
        %% save figure
        PLOT_NAME                                   = fullfile(MAIN_DIR,'morph_spaces',...
            ['face_morph_space' sprintf('%03d',FRAME_NUM) EX_SAVE_STR '.png']);
        export_fig(2020,PLOT_NAME,['-r' num2str(250)],'-nocrop')
        disp(['Saved: ' PLOT_NAME])
        
        % output figure to movie
        if exist('VIDEO_OBJ','var')
            VIDEO_IM                                = getframe(2020);
            step(VIDEO_OBJ,VIDEO_IM.cdata)
        end
            
end

close(2020)

if exist('VIDEO_OBJ','var')
    release(VIDEO_OBJ)
end