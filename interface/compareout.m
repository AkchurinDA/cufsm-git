function []=compareout(filenumber)
%BWS
%August 28,2000
%Z. Li, July 2010 (last modified to accomodate general boudanry condition solution)
%Sheng Jin, Jan 2024 (adding some uicontrols for the 3D plotter) 
%Post processor for comparing several different analyses
%
%general
global fig screen prop node elem lengths curve shapes clas springs constraints GBTcon BC m_all neigs version screen zoombtn panbtn rotatebtn
%output from pre2
global subfig ed_prop ed_node ed_elem ed_lengths axestop screen flags modeflag ed_springs ed_constraints
%output from template
global prop node elem lengths springs constraints h_tex b1_tex d1_tex q1_tex b2_tex d2_tex q2_tex r1_tex r2_tex r3_tex r4_tex t_tex C Z kipin Nmm axestemp subfig
%output from propout and loading
global A xcg zcg Ixx Izz Ixz thetap I11 I22 Cw J outfy_tex unsymm restrained Bas_Adv scale_w Xs Ys w scale_tex_w outPedit outMxxedit outMzzedit outM11edit outM22edit outTedit outBedit outL_Tedit outx_Tedit Pcheck Mxxcheck Mzzcheck M11check M22check Tcheck screen axesprop axesstres scale_tex maxstress_tex minstress_tex
%output from boundary condition (Bound. Cond.)
global ed_m ed_neigs solutiontype togglesignature togglegensolution popup_BC toggleSolution Plengths Pm_all Hlengths Hm_all HBC PBC subfig lengthindex axeslongtshape longitermindex hcontainershape txt_longterm len_cur len_longterm longshape_cur jScrollPane_edm jViewPort_edm jEditbox_edm hjScrollPane_edm
%output from cFSM
global toggleglobal toggledist togglelocal toggleother ed_global ed_dist ed_local ed_other NatBasis ModalBasis toggleCouple popup_load axesoutofplane axesinplane axes3d lengthindex modeindex spaceindex longitermindex b_v_view modename spacename check_3D cutface_edit len_cur mode_cur space_cur longterm_cur modes SurfPos scale twod threed undef scale_tex
%output from compareout
global pathname filename pathnamecell filenamecell propcell nodecell elemcell lengthscell curvecell clascell shapescell springscell constraintscell GBTconcell solutiontypecell BCcell m_allcell filedisplay files fileindex modes modeindex mmodes mmodeindex lengthindex axescurve togglelfvsmode togglelfvslength curveoption ifcheck3d minopt logopt threed ctrlCompUndef axes2dshapelarge togglemin togglelog modestoplot_tex filetoplot_tex modestoplot_title filetoplot_title checkpatch len_plot lf_plot mode_plot SurfPos cutsurf_tex filename_plot len_cur scale_tex mode_cur mmode_cur file_cur xmin_tex xmax_tex ymin_tex ymax_tex filetoplot_tex screen popup_plot filename_title2 clasopt popup_classify times_classified toggleclassify classification_results plength_cur pfile_cur togglepfiles toggleplength mlengthindex mfileindex axespart_title axes2dshape axes3dshape axesparticipation axescurvemode  modedisplay modestoplot_tex
    %by Sheng Jin from compareout
    global toggle_3D popup_3dItem popup_3dData popup_3dStyle edit_3dScale

i=filenumber;
if i==1
    %first time in the routine
    pathnamecell{i}=[''];
    filenamecell{i}=['CUFSM results'];
    propcell{i}=prop;
    nodecell{i}=node;
    elemcell{i}=elem;
    lengthscell{i}=lengths;
    curvecell{i}=curve;
    shapescell{i}=shapes;
    clascell{i}=clas;
    springscell{i}=springs;
    constraintscell{i}=constraints;
    GBTconcell{i}=GBTcon;
    BCcell{i}=BC;
    m_allcell{i}=m_all;
    %whether the solution is a signature curve solution or general boundary
    %condition solution
    for j=1:max(size(m_all))
        if length(m_all{j})==1&m_all{j}==m_all{1}
            solutiontype=1;
        else
            solutiontype=2;
            break
        end
    end
    solutiontypecell{i}=solutiontype;
    i=i+1;
    times_classified=0;
elseif i==0
    %a save has occured which updated the first files name
    pathnamecell{1}=pathname;
    filenamecell{1}=filename;
    i=length(files)+1;
else
    %Need to add support for GBTcon and clas variables here%
    [pathname,filename,prop,node,elem,lengths,curve,shapes,springs,constraints,GBTcon,clas,BC,m_all]=loader; 
    pathnamecell{i}=pathname;
    filenamecell{i}=filename;
    propcell{i}=prop;
    nodecell{i}=node;
    elemcell{i}=elem;
    lengthscell{i}=lengths;
    %If the number of modes is less than the first file pad with zeros
    curvecell{i}=curve;
    shapescell{i}=shapes;
    springscell{i}=springs;
    constraintscell{i}=constraints;
    clascell{i}=clas;
    GBTconcell{i}=GBTcon;
    BCcell{i}=BC;
    m_allcell{i}=m_all;
    %whether the solution is a signature curve solution or general boundary
    %condition solution
    for j=1:max(size(m_all))
        if length(m_all{j})==1&m_all{j}==m_all{1}
            solutiontype=1;
        else
            solutiontype=2;
            break
        end
    end
    solutiontypecell{i}=solutiontype;
    i=i+1;
end
%
%set the first file as the starting file
fileindex=1;
pathname=pathnamecell{fileindex};
filename=filenamecell{fileindex};
prop=propcell{fileindex};
node=nodecell{fileindex};
elem=elemcell{fileindex};
lengths=lengthscell{fileindex};
curve=curvecell{fileindex};
shapes=shapescell{fileindex};
clas=clascell{fileindex};
springs=springscell{fileindex};
constraints=constraintscell{fileindex};
GBTcon=GBTconcell{fileindex};
BC=BCcell{fileindex};
m_all=m_allcell{fileindex};
solutiontype=solutiontypecell{fileindex};
%
files=(1:1:i-1);
%------------------------------------------------------------------------------------

%Set default initial values
lengthindex=ceil(length(lengths)/2);
modeindex=1;
clasopt=0;
logopt=1;
minopt=1;

modes=(1:1:length(curve{lengthindex}(:,2)));
modedisplay=1;
filedisplay=files;

threed=1; %Jan 2024, 3D plotter is fast now, start out with it on.
undefv=1;
scale=1;
SurfPos=1/2;
curveoption=1;
ifcheck3d=1;
m_a=m_all{lengthindex};

if exist('springs')
else
    springs=0;
end
%
if length(lengths)==1
    curveoption=2;
end

if curveoption==1
    xmin=min(lengths)*10/11;
    ymin=0;
    xmax=max(lengths)*11/10;
    for j=1:max(size(curve))
        curve_sign(j,1)=curve{j}(modeindex,1);
        curve_sign(j,2)=curve{j}(modeindex,2);
    end
    ymax=min([max(curve_sign(:,2)),3*median(curve_sign(curve_sign(:,2)>0,2))]);
elseif curveoption==2
    xmin=1;
    ymin=0;
    xmax=length(curve{lengthindex}(:,2));
    ymax=min([max(curve{lengthindex}(:,2)),3*median(curve{lengthindex}(:,2))]);
end

%------------------------------------------------------------------------------------
%Set up the figure title and menu
hold off
clf
name=['CUFSM v',version,' -- Finite Strip Post-Processor'];
set(fig,'Name',name);
%
%set up the command bar
screen=5;
commandbar;
%

%%GUI CONTROLS FOLLOW
%-------------------

%
%upper box around mode shape
box1=uicontrol(fig,...
    'Style','frame','units','normalized',...
    'Position',[0.0 0.62 0.261 0.37]);
    box1a=uicontrol(fig,...
        'Style','frame','units','normalized',...
        'Position',[0.0 0.855-0.08 0.261 0.08]);
    box1b=uicontrol(fig,...
        'Style','frame','units','normalized',...
        'Position',[0.0 0.855 0.261 0.08]);
%next box around loading files
box2=uicontrol(fig,...
    'Style','frame','units','normalized',...
    'Position',[0.0 0.46 0.261 0.15]);
%next box around plotting signature curve or modal participation
box3=uicontrol(fig,...
    'Style','frame','units','normalized',...
    'Position',[0.0 0.17 0.261 0.28]);
%final box for cfSM modal claissificaiton options
box4=uicontrol(fig,...
    'Style','frame','units','normalized',...
    'Position',[0.0 0.01 0.261 0.15]);

%%SET OF BUTTONS FOR CONTROLLING WHAT LENGTH YOU ARE AT, AND PLOTTING THE MODE
% general
plotmode=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.001 0.94 0.175 0.04],...
    'String','Plot Shape',...
    'Tooltip','Click to plot 2D/3D buckling shapes',...
    'Callback',[...
    'compareout_cb(1);']);
BC_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','center',...
    'Position',[0.176 0.94 0.043 0.03],...
    'String',['BC: ',BC]);
btn_plotmodehelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.94 0.04 0.04],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#9'');']);


%% 2D plotting settings------------------------------------------
%Suite of options for plotting..
Item2D_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.001 0.905 0.05 0.023],...
    'HorizontalAlignment','right',...
    'String','2D Item:');
popup_plot=uicontrol(fig,...
    'units','normalized',...
	'Style','popupmenu',...
    'Position',[0.053 0.905 0.123 0.025],...
    'String','in-plane mode|out-of-plane mode|strain energy|applied stress',...
    'Callback',[...
    'compareout_cb(23);']);
scale_title=uicontrol(fig,...
    'Style','text','units','normalized',...
     'Position',[0.178 0.905 0.04 0.023],...
    'HorizontalAlignment','right',...
    'String','Scale:');
scale_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.22 0.905 0.04 0.025],...
    'HorizontalAlignment','Center',...
    'String',num2str(scale),...
    'Callback','compareout_cb(1)');

cutsurf_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.001 0.86 0.159 0.025],...
    'HorizontalAlignment','right',...
    'String','Cross section position y/L (2D): ');
cutsurf_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.161 0.86 0.04 0.03],...
    'String',num2str(SurfPos),...
    'Callback','compareout_cb(1)');

ctrlCompUndef=uicontrol(fig,...
    'Style','checkbox','units','normalized',...
    'Position',[0.21 0.86 0.05 0.025],...
    'String','Undef.',...
    'Value',undefv,...
    'Callback',[...
    'compareout_cb(1);']);
%% length, mode, and file
umove=-0.078;
len_txt=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.001 0.80+umove 0.059 0.04],...
    'FontName','Arial','FontSize',10,...
    'HorizontalAlignment','Center',...
    'String','length =');
len_cur=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.1 0.81+umove 0.08 0.04],...
    'FontName','Arial','FontSize',10,...
    'HorizontalAlignment','Center',...
    'String',num2str(lengths(lengthindex)),...
    'Callback',[...
    'compareout_cb(13);']);
uplength=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.18 0.81+umove 0.04 0.04],...
    'fontname','symbol',...
    'String',setstr(hex2dec('ae')),...
    'Callback',[...
    'compareout_cb(5);']);
downlength=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.06 0.81+umove 0.04 0.04],...
    'fontname','symbol',...
    'String',setstr(hex2dec('ac')),...
    'Callback',[...
    'compareout_cb(6);']);
btn_wvlmodehelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.81+umove 0.04 0.04],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#10'');']);
%------------------------------------------
mode_txt=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.001 0.75+umove 0.059 0.04],...
    'FontName','Arial','FontSize',10,...
    'String','mode =');
mode_cur=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.10 0.76+umove 0.08 0.04],...
    'FontName','Arial','FontSize',10,...
    'String',num2str(modes(modeindex)),...
    'Callback',[...
    'compareout_cb(14);']);
upmode=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.18 0.76+umove 0.04 0.04],...
    'fontname','symbol',...
    'String',setstr(hex2dec('ae')),...
    'Callback',[...
    'compareout_cb(7);']);
downmode=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.06 0.76+umove 0.04 0.04],...
    'fontname','symbol',...
    'String',setstr(hex2dec('ac')),...
    'Callback',[...
    'compareout_cb(8);']);
btn_modehelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.76+umove 0.04 0.04],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#11'');']);
%------------------------------------------
file_title1=uicontrol(fig,...
    'Style','text','units','normalized',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.001 0.70+umove 0.059 0.04],...
    'String','file =');
file_cur=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.1 0.70+umove 0.08 0.04],...
    'String',filenamecell{fileindex});
%	'String',num2str(files(fileindex)));
upfile=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.18 0.71+umove 0.04 0.04],...
    'fontname','symbol',...
    'String',setstr(hex2dec('ae')),...
    'Callback',[...
    'compareout_cb(16);']);
downfile=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.06 0.71+umove 0.04 0.04],...
    'fontname','symbol',...
    'String',setstr(hex2dec('ac')),...
    'Callback',[...
    'compareout_cb(17);']);
btn_filehelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.71+umove 0.04 0.04],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#17'');']);
%% 3D plotting settings------------------------------------------
rmove=0.0;
umove=0.150;
% 3D toggle
toggle_3D=uicontrol(fig,...
    'Style','checkbox','units','normalized',...
    'Position',[0.001+rmove 0.677+umove 0.029 0.020],...
    'FontName','Arial','FontSize',10,...
    'String','3D',...
    'Value',1,...
    'CallBack',[...
    'compareout_cb(3);']);
title_3dItem=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.029+rmove 0.675+umove 0.030 0.023],...
    'HorizontalAlignment','right',...
    'String','Item:');
popup_3dItem=uicontrol(fig,...
    'Style','popup','units','normalized',...
    'Position',[0.062+rmove 0.675+umove 0.105 0.025],...
    'String','Deformed shape only|Undeformed shape only|Def. + undef. edge',...
    'Callback',[...
    'compareout_cb(1);']);

title_3dStyle=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.169+rmove 0.675+umove 0.030 0.023],...
    'HorizontalAlignment','right',...
    'String','Style:');
popup_3dStyle=uicontrol(fig,...
    'Style','popup','units','normalized',...
    'Position',[0.20+rmove 0.675+umove 0.060 0.025],...
    'String','Surface|Mesh|Curved lines',...
    'Callback',[...
    'compareout_cb(41);']);

%------------------------------------------
title_3dScale=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.001+rmove 0.635+umove 0.032 0.023],...
    'HorizontalAlignment','left',...
    'String','Scale:');
edit_3dScale=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.033+rmove 0.635+umove 0.02 0.023],...
    'HorizontalAlignment','Center',...
    'String',num2str(scale*3),...
    'Callback','compareout_cb(1)');

title_3dData=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.055+rmove 0.635+umove 0.030 0.023],...
    'HorizontalAlignment','Left',...
    'String','Data:');
popup_3dData=uicontrol(fig,...
    'Style','popup','units','normalized',...
    'Position',[0.079+rmove 0.635+umove 0.088 0.025],...
    'String','Displacement: Vector sum|Displacement: X-Component|Displacement: Y-Component|Displacement: Z-Component|normal Strain: Y-Component| shear Strain: In-strip-plane|No Color',...
    'Callback',[...
    'compareout_cb(42);']);
if threed==0
	set(popup_3dItem,'Enable','off');
	set(popup_3dData,'Enable','off');
	set(popup_3dStyle,'Enable','off');
else
	set(popup_3dItem,'Enable','on');
	set(popup_3dData,'Enable','on');
	set(popup_3dStyle,'Enable','on');
end
plot_mode2=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.169+rmove 0.635+umove 0.091 0.025],...
    'String','Separate window',...
    'Tooltip','Use separate windows to see 2D/3D buckled mode shapes',...
    'Callback',[...
    'compareout_cb(19);']);
%------------------------------------------





% 3D toggle
% twod=uicontrol(fig,...
%    'Style','radio','units','normalized',...
%    'Position',[0.001 0.8 0.039 0.05],...
%    'String','2D',...
%    'Value',1,...
%    'CallBack',[...
% 		'compareout_cb(2);']);

% checkpatch=uicontrol(fig,...
%     'Style','checkbox','units','normalized',...
%     'Position',[0.04 0.60 0.08 0.03],...
%     'FontName','Arial','FontSize',10,...
%     'String','solid 3D',...
%     'Value',0);
% set(checkpatch,'Enable','off');
%------------------------------------------------------------------
%updated titles over by the actual mode shape
len_title2=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Right',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.35 0.56 0.14 0.03],...
    'String','length = ');
len_plot=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.49 0.56 0.09 0.03],...
    'String',num2str(lengths(lengthindex)));
lf_title2=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Right',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.55 0.56 0.10 0.03],...
    'String','load factor = ');
lf_plot=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.65 0.56 0.1 0.03],...
    'String',num2str(curve{lengthindex}(modeindex,2)));
mode_title2=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Right',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.75 0.56 0.06 0.03],...
    'String','mode = ');
mode_plot=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.81 0.56 0.14 0.03],...
    'String',num2str(modes(modeindex)));
filename_title2=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Right',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.35 0.59 0.3 0.03],...
    'String','Buckled shape for ');
filename_plot=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.65 0.59 0.3 0.03],...
    'String',filename);
classification_results=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Center',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.35 0.53 0.6 0.03],...
    'String','cFSM classification results: off');
%------------------------------------------

%----------------------------------------------
%Load additional files into the comparison post-processor
loadfile=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.08 0.575 0.12 0.03],...
    'String','Load another file',...
    'Callback',[...
    'compareout_cb(18);']);
%----------------------------------------------
%----------------------------------------------
%static titles of the loaded filenames
for j=1:1:i-1
    names{j}=[num2str(j),' = ',char(filenamecell{j})];
end
keytofiles_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'Position',[0.001 0.575 0.079 0.03],...
    'String','loaded files:');
keytofiles_title2=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'Position',[0.001 0.465 0.229 0.11],...
    'String',names,'Max',9);
%----------------------------------------------
%
%
%PLOTTING THE HALF-WAVELENGTH VS. LOAD FACTOR CURVE OR MODE NUMBER VS LOAD
%FACTOR FOR GENERAL FSM SOLUTION
plotcurve=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.001 0.405 0.219 0.04],...
    'String','Plot Curve',...
    'Tooltip','Click to plot the buckling curve (load factor vs length/mode number)',...
    'Callback',[...
    'compareout_cb(10);']);

togglelfvslength=uicontrol(fig,...
    'Style','radio','units','normalized',...
    'Position',[0.001 0.29 0.12 0.03],...
    'String','load factor vs length',...
    'Value',1,...
    'Callback',[...
    'compareout_cb(24);']);
togglelfvsmode=uicontrol(fig,...
    'Style','radio','units','normalized',...
    'Position',[0.001 0.18 0.18 0.03],...
    'String','load factor vs mode number',...
    'Value',0,...
    'Callback',[...
    'compareout_cb(25);']);


% upanel=uipanel(fig,'units','normalized',...
%     'Position',[0.001 0.21 0.249 0.12],...
%     'BorderType','line',...
%     'ForegroundColor','k');

togglemin=uicontrol(fig,...
    'Style','checkbox','units','normalized',...
    'Position',[0.011 0.255 0.069 0.04],...
    'String','minima',...
    'Value',1,...
    'Callback',[...
    'compareout_cb(11);']);
togglelog=uicontrol(fig,...
    'Style','checkbox','units','normalized',...
    'Position',[0.011 0.22 0.069 0.04],...
    'String','log scale',...
    'Value',1,...
    'Callback',[...
    'compareout_cb(12);']);

toggleclassify=uicontrol(fig,...
    'Style','checkbox','units','normalized',...
    'Position',[0.18 0.365 0.069 0.04],...
    'String','classify',...
    'Value',0,...
    'Callback',[...
    'compareout_cb(32);']);

dumptext=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.001 0.375 0.089 0.03],...
    'String','dump to text',...
    'Tooltip','save a curve data to text file',...
    'Callback',[...
    'compareout_cb(20);']);
%------------------------------------------
%mode is setting for modes to be plotted in load factor vs length curve
modestoplot_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.07 0.255 0.10 0.03],...    
    'HorizontalAlignment','Right',...
    'String','Modes to be plotted');
modestoplot_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.17 0.255 0.05 0.03],...
    'String',sprintf('%i ',modedisplay'),...
    'Callback','compareout_cb(10)');
%------------------------------------------
filetoplot_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.08 0.22 0.09 0.03],...
    'HorizontalAlignment','Right',...
    'String','files to be plotted ');
filetoplot_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.17 0.22 0.05 0.03],...
    'String',sprintf('%i ',files'));
%
xmin_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.001 0.33 0.029 0.03],...
    'String','xmin');
xmin_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.03 0.33 0.03 0.03],...
    'String',num2str(xmin),...
    'Callback','compareout_cb(10)');
xmax_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.06 0.33 0.03 0.03],...
    'String','xmax');
xmax_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.09 0.33 0.035 0.03],...
    'String',num2str(xmax),...
    'Callback','compareout_cb(10)');
ymin_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.125 0.33 0.03 0.03],...
    'String','ymin');
ymin_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.155 0.33 0.03 0.03],...
    'String',num2str(ymin),...
    'Callback','compareout_cb(10)');
ymax_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'Position',[0.185 0.33 0.03 0.03],...
    'String','ymax');
ymax_tex=uicontrol(fig,...
    'Style','edit','units','normalized',...
    'Position',[0.215 0.33 0.034 0.03],...
    'String',num2str(ymax),...
    'Callback','compareout_cb(10)');
%if load factor vs mode number
if curveoption==2
    set(togglelfvsmode,'value',1);
    set(togglelfvslength,'value',0);
    set(togglemin,'Enable','off');
    set(togglelog,'Enable','off');
    set(modestoplot_tex,'Enable','off');
    set(filetoplot_tex,'Enable','off');
    set(modestoplot_title,'Enable','off');
    set(filetoplot_title,'Enable','off');
end
%--------------------------------------------------------------------------
%Classification
cFSM_title=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Left',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.001 0.12 0.219 0.03],...
    'String','cFSM Modal Classification');
if sum(GBTcon.glob)+sum(GBTcon.dist)+sum(GBTcon.local)+sum(GBTcon.other)>0 %cFSM analysis is on
    if GBTcon.orth==1
        basis_string=['Natural basis (ST)'];
    elseif GBTcon.orth==2&GBTcon.couple==1
        basis_string=['Uncoupled axial mode basis (ST)'];
    elseif GBTcon.orth==2&GBTcon.couple==2
        basis_string=['Coupled axial mode basis (ST)'];
    elseif GBTcon.orth==3&GBTcon.couple==1
        basis_string=['Uncoupled applied-load mode basis (ST)'];
    elseif GBTcon.orth==3&GBTcon.couple==2
        basis_string=['Coupled applied-load mode basis (ST)'];
    end
else
    basis_string=['cFSM analysis is off'];
end
cFSM_basis=uicontrol(fig,...
    'Style','text','units','normalized',...
    'HorizontalAlignment','Center',...
    'FontName','Arial','FontSize',10,...
    'Position',[0.001 0.055 0.258 0.03],...
    'String',basis_string);
push_clas=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.001 0.09 0.119 0.03],...
    'String','Classify',...
    'Tooltip','Perform modal identification/classification',...
    'Callback',[...
    'compareout_cb(30);']);
popup_classify=uicontrol(fig,...
    'Style','popup','units','normalized',...
    'Position',[0.12 0.09 0.1 0.03],...
    'String','vector norm|strain energy norm|work norm',...
    'Value',1,...
    'Callback',[...
    'compareout_cb(31);']);
extra_classify_plots=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.001 0.02 0.219 0.04],...
    'String','supplemental participation plot',...
    'Tooltip','Use separate windows to see supplemental plot of participation results',...
    'Callback',[...
    'compareout_cb(40);']);
%%help buttons
%------------------------------------------
btn_curvehelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.405 0.04 0.04],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#13'');']);
btn_modeshelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.255 0.04 0.03],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#14'');']);
btn_file2help=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.22 0.04 0.03],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#18'');']);

btn_cfsmhelp=uicontrol(fig,...
    'Style','push','units','normalized',...
    'Position',[0.22 0.09 0.04 0.03],...
    'String','?',...
    'Callback',[...
    'web(''cufsmhelp.html#22'');']);

%-----------------------------------------
%DEFINE THE AXIS THAT WILL BE USED FOR THE TWO PLOTS
axes2dshape=axes('Units','normalized','Position',[0.30 0.63 0.3 0.32],'visible','on');
axes2dshapelarge=axes('Units','normalized','Position',[0.30 0.63 0.6 0.32],'visible','off');
axes3dshape=axes('Units','normalized','Position',[0.65 0.63 0.3 0.32],'visible','on');
axescurve=axes('Units','normalized','Position',[0.34 0.07 0.63 0.43],'Box','on','XTickLabel','','YTickLabel','','visible','on');
%for load factor vs mode number and participation of lonitudinal terms
axesparticipation=axes('Units','normalized','Position',[0.34 0.37 0.62 0.14],'Box','on','XTickLabel','','YTickLabel','','visible','off');
axescurvemode=axes('Units','normalized','Position',[0.34 0.07 0.62 0.23],'Box','on','XTickLabel','','YTickLabel','','visible','off');
%

%%Plot initial shapes and render into axes
%-----------------------------------------
%Plot the mode shape as a start
mode=shapes{lengthindex}(:,modeindex);
undefv=get(ctrlCompUndef,'Value');
if threed==1
	dispshap(undefv,node,elem,mode,axes2dshape,scale,springs,m_a,BC,SurfPos);
	
	Item3D=get(popup_3dItem,'Value');
	Data3D=get(popup_3dData,'Value');
	ifSurface=get(popup_3dStyle,'Value');
	scale_3D=str2double(get(edit_3dScale,'String'));
	ifColorBar=1;%draw color bar
	dispshp2(lengths(lengthindex),node,elem,mode,axes3dshape,scale_3D,m_all{lengthindex},BC,0,Item3D,Data3D,ifSurface,ifColorBar,SurfPos);
else
    dispshap(undefv,node,elem,mode,axes2dshapelarge,scale,springs,m_a,BC,SurfPos);
end
%Plot the buckling curve as a start
if curveoption==1
    picpoint=[curve{lengthindex}(modeindex,1) curve{lengthindex}(modeindex,2)];
    thecurve3(curvecell,filenamecell,clascell,filedisplay,minopt,logopt,clasopt,axescurve,xmin,xmax,ymin,ymax,modedisplay,fileindex,modeindex,picpoint)
else
    axes(axescurve);
    cla reset, axis off
    %
    set(axescurvemode,'visible','on');
    set(axesparticipation,'visible','on');
    
    %plot the load factor vs mode number curve
    picpoint=[modes(modeindex) curve{lengthindex}(modeindex,2)];
    thecurve3mode(curvecell,filenamecell,clascell,fileindex,minopt,logopt,clasopt,axescurvemode,xmin,xmax,ymin,ymax,fileindex,lengthindex,picpoint);
    
    %plot the participation vs longitudinal terms
    mode=shapes{lengthindex}(:,modeindex);
    nnodes=length(node(:,1));
    m_a=m_all{lengthindex};
    [d_part]=longtermpart(nnodes,mode,m_a);
    axes(axesparticipation)
    cla
    bar(m_a,d_part);hold on
    xlabel('m, longitudinal term');hold on;
    ylabel('Participation');hold on;
    legendstring=[filenamecell{fileindex},', length = ',num2str(lengths(lengthindex)), ', mode = ', num2str(modeindex)];
    hlegend=legend(legendstring);hold on
    set(hlegend,'Location','best');
    hold off    
end

end
