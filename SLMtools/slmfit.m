function slm = slmfit(x,y,varargin)
% slmfit: GUI tool to estimate a spline function (Shape Langauge Model) from data
% usage 1: slm = slmfit(x,y);
% usage 3: slm = slmengine(x,y,prop1,val1,prop2,val2,...);
%
% Note: slmfit is a GUI tool for fitting a shape language model
%   to data. The user supplies information about the expected curve
%   shape. slmengine is used for the modeling.
%
% Note: The optimization toolbox (lsqlin) is required for most fits.
% Simple fits may allow the use of a lower 
%
% arguments: (input)
%  x,y     - vectors of data used to fit the model
%
%  prescription - structure generated by slmset to control the
%            initial fit parameters to start the GUI.
%
%            Alternatively, one can simply supply property/value
%            pairs directly to slmfit.
%
%            Note that these properties are only used to define
%            the INITIAL state of the GUI. Any further changes
%            made under user control in the GUI will be built
%            into the final fit.
%
% Arguments: (output)
%  slm     - a shape prescriptive model structure, stored in a
%            Hermite form.
%
%            slmeval can be used to evaluate the resulting model
%            at any set of points, or any derivative of the model.
%            
%            Alternatively, the result may be returned in pp form,
%            evaluable by ppval. You may also use slm2pp to convert
%            an slm form into a pp form.



% which form does the shape prescription take? (if any)
if nargin<2
  error('SLMFIT:improperarguments','Must supply a pair of vectors to fit a curve in the form: y = f(x)')
elseif (nargin > 2) && (mod(nargin,2) == 1)
  error('SLMFIT:improperarguments','Additional arguments must be in pairs, as properties/values')
elseif nargin==2
  % use a default for the shape prescription.
  prescription = slmset('plot','off');
elseif (nargin>=3)
  % prescription supplied directly or as property/value pairs,
  % or as a prescription, modified by a few set of pairs.
  % slmset will resolve all of these cases.
  prescription = slmset(varargin{:});
end

% plot is inappropriate for the gui in case it was specified
if strcmp(prescription.Plot,'on')
  % override the Plot option
  prescription.Plot = 'off';
end

% check the data for size, turning it into column vectors
x=x(:);
y=y(:);
n = length(x);
if n~=length(y)
  error 'x and y must be the same size'
end

% set up the gui
params.BackColor = [.6 .7 .7]; % GUI background color
params.ButtonColor = [.9 .9 .9];
params.MaxStack = 50; % maximum stack size allowed
params.SLMStack = cell(params.MaxStack,2);

InitializeSLMGUI

% Aggregate any parameters for the gui, plot, etc., in one
% place for reference by all nested functions
params.X = x;
params.Y = y;
params.n = n;

% Plot may be 'function', 'residuals', 'dy', 'dy2', 'dy3'
params.Plot = 'function';
if n <= 100
  params.Marker = 'o';
else
  params.Marker = '.';
end
params.MarkerColor = 'r';
params.MarkerSize = 6;

params.LineStyle = '-';
params.LineColor = 'b';
params.LineWidth = 0.5;

params.KnotStyle = '--';
params.KnotColor = 'g';
params.KnotWidth = 0.5;

% the grid lines may be 'off' or 'on'
params.Grid = 'off';

% number of points to evaluate the spline at along the curve
params.Nev = 501;
% some handles to help selectdata to work properly, and for
% some callbacks
params.Handles.Data = [];
params.Handles.Curve = [];
params.Handles.Knots = [];

% maintain the result in Hermite form, for ease of plotting
% the derivatives later if necessary. We will convert it to
% pp form at the very end if requested.
if strcmpi(prescription.Result,'pp')
  params.Result = 'pp';
  prescription.Result = 'slm';
else
  params.Result = 'slm';
end

% fit the initial model
slm = slmengine(x,y,prescription);

% set up the stack for prescriptions and models to allow undos
% Note that the slm form returned also contains the prescription
% that was used to build it. The character string is used to
% refer to these particular settings in a listbox.
params.SLMStack(1,:) = {slm, 'Initial model'};

% update the gui to reflect the fit statistics, and plot the model
ReportSLMStats(slm)
PlotModel(slm)

% Initial fit is done and fully reported. Wait for further
% actions so that we can return the final model.
uiwait

% ...

% ... and resume.

% get the final model from the stack
slm = params.SLMStack{1,1};

% Do we need to convert to pp form?
if strcmpi(params.Result,'pp')
  slm = slm2pp(slm);
end

% close down the figure window
delete(params.Handles.Figure)

% all done now.

% ===================================================
%    nested functions (internal processing)
% ===================================================
function InitializeSLMGUI
  % Build the GUI window & set up the callbacks
  
  % open up a new figure window
  params.Handles.Figure = figure('Color',params.BackColor, ...
    'Units','normalized', ...
    'Position',[.1 .1 .8 .8], ...
    'Name','Shape Language Modeling Tool', ...
    'CloseRequestFcn',@(s,e) CloseSLM(s,e,'X'));
  
  % set the axes
  params.Handles.Axes = axes('Parent',params.Handles.Figure, ...
    'Units','normalized', ...
    'CameraUpVector',[0 1 0], ...
    'Color',[1 1 1], ...
    'Position',[.05 .16 .70 .8], ...
    'Tag','Axes1', ...
    'XColor',[0 0 0], ...
    'YColor',[0 0 0], ...
    'ZColor',[0 0 0]);
  h2 = text('Parent',params.Handles.Axes, ...
    'Color',[0 0 0], ...
    'Units','normalized', ...
    'FontName','helvetica', ...
    'HandleVisibility','off', ...
    'HorizontalAlignment','center', ...
    'Position',[0.496 -0.053 0], ...
    'Tag','Axes1Text4', ...
    'VerticalAlignment','cap');
  set(get(h2,'Parent'),'XLabel',h2);
  h2 = text('Parent',params.Handles.Axes, ...
    'Color',[0 0 0], ...
    'Units','normalized', ...
    'FontName','helvetica', ...
    'HandleVisibility','off', ...
    'HorizontalAlignment','center', ...
    'Position',[-0.06 0.495], ...
    'Rotation',90, ...
    'Tag','Axes1Text3', ...
    'VerticalAlignment','baseline');
  set(get(h2,'Parent'),'YLabel',h2);
  h2 = text('Parent',params.Handles.Axes, ...
    'Color',[0 0 0], ...
    'Units','normalized', ...
    'FontName','helvetica', ...
    'HandleVisibility','off', ...
    'HorizontalAlignment','center', ...
    'Position',[0.497 1.013], ...
    'Tag','Axes1Text1', ...
    'VerticalAlignment','bottom');
  set(get(h2,'Parent'),'Title',h2);
  
  % done button
  params.Handles.Done = uicontrol('Parent',params.Handles.Figure, ...
    'Units','normalized', ...
    'BackgroundColor',params.ButtonColor, ...
    'Position',[0.55 .05 .10 .05], ...
    'String','Done', ...
    'HorizontalAlignment','left', ...
    'Style','PushButton', ...
    'CallBack',@(s,e) CloseSLM(s,e,'button'), ...
    'TooltipString','Terminate and return the fitted spline');
  
  % box to report statistics 
  params.Handles.Stats = uicontrol('Parent',params.Handles.Figure, ...
    'Units','normalized', ...
    'BackgroundColor',[1 1 1], ...
    'Position',[0.76 0.01 .23 .13], ...
    'String','', ...
    'HorizontalAlignment','left', ...
    'Style','listbox', ...
    'Fontname','Monaco', ...
    'fontsize',8, ...
    'TooltipString','Statistics on the spline fit and information about the spline itself');
  
  % undo/revert/redo button
  
  
  
  
  % undo listbox
  
  
  
  
  % menus: knots/breaks
  
  
  
  
  % menus: value
  
  
  
  
  % menus: slope
  
  
  
  
  % menus: shape
  
  
  
  
  % menus: Fit
  
  
  
  
  % menus: plot
  
  
  
  
  
  
  
  
  
end % (nested) InitializeGUI

% ===================================================
%    nested functions (internal processing)
% ===================================================
function ReportSLMStats(slm)
  % computes statistics on the model, the fit, the shape
  % of the function as fit, and stuff that info into the
  % stats box.
  
  % some of the parameters can be obtained from slmpar
  funrange = [slmpar(slm,'minfun'),slmpar(slm,'maxfun')];
  fprange = [slmpar(slm,'minslope'),slmpar(slm,'maxslope')];
  funint = slmpar(slm,'integral');
  
  if slm.degree == 3
    dy2dx2 = slmeval(slm.knots,slm,2);
    fpprange = [min(dy2dx2),max(dy2dx2)];
    dy3dx3 = slmeval(slm.knots,slm,3);
    fppprange = [min(dy3dx3),max(dy3dx3)];
  else
    fpprange = [0,0];
  end
  
  % residual errors: yhat - y
  resids = slmeval(params.X,slm,0) - params.Y;
  errorrange = [max(resids),min(resids)];
  
  % Standard deviation of the residuals
  stdresids = std(resids);
  
  % R^2, adjusted R^2 are computed by slmengine
  outinfo = cell(11,1);
  outinfo{1} = ['Function min & max:       ',num2str(funrange)];
  outinfo{2} = ['Slope min & max:          ',num2str(fprange)];
  outinfo{3} = ['2nd derivative min & max: ',num2str(fpprange)];
  outinfo{4} = ['3rd derivative min & max: ',num2str(fppprange)];
  outinfo{5} = ['Integral:                 ',num2str(funint)];
  
  outinfo{6} = ['Errors min & max:         ',num2str(slm.stats.ErrorRange)];
  outinfo{7} = ['25 & 75% error quartiles: ',num2str(slm.stats.Quartiles)];
  outinfo{8} = ['RMSE:                     ',num2str(slm.stats.RMSE)];
  outinfo{9} = ['std of residuals:         ',num2str(stdresids)];
  outinfo{10} = ['R-squared:                ',num2str(slm.stats.R2)];
  outinfo{11} = ['Adjusted R-squared:       ',num2str(slm.stats.R2Adj)];
  
  % Stuff the statistics box with this information.
  set(params.Handles.Stats,'String',outinfo)
  
end % (nested) ReportSLMStats

% ===================================================
%    nested functions (internal processing)
% ===================================================
function PlotModel(slm)
  % plots the curve and data in the figure window, or derivatives of the curve
  
  switch params.Plot
    case 'function'
      % plot the data points
      if ~isempty(params.Marker) && ~strcmpi(params.Marker,'none')
        params.Handles.Data = plot(params.X,params.Y);
        set(params.Handles.Data,'LineStyle','none', ...
          'Marker',params.Marker, ...
          'Color',params.MarkerColor, ...
          'MarkerSize',params.MarkerSize)
        hold on
      end
      
      % and now the function itself
      Xlim = [min(min(params.X),slm.knots(1)),max(max(params.X),slm.knots(end))];
      Xev = linspace(Xlim(1),Xlim(2),params.Nev);
      Yev = slmeval(Xev,slm,0);
      
      h = plot(Xev,Yev);
      set(h,'Marker','none', ...
        'Color',params.LineColor, ...
        'LineStyle',params.LineStyle, ...
        'LineWidth',params.LineWidth)
      hold on
      
      % y axis label
      ylabel 'f(x)'
      
    case 'residuals'
      % predictions
      yhat = slmeval(params.X,slm,0);
      
      % residuals, as (yhat - y)
      resids = yhat - params.Y;
      
      params.Handles.Data = plot(params.X,resids,'Marker',params.DataMarker, ...
        'Color',params.MarkerColor,'LineStyle','none');
      
      hold on
      
      % there is no curve handle here
      params.Handles.Curve = [];
      
      % reference line at zero
      Xlim = [min(params.X),max(params.X)];
      plot(xlim,0,'k-')
      
      % y axis label
      ylabel 'Residuals: yhat - y'
      
    case {'dy', 'dy2', 'dy3'}
      % some order derivative
      Xlim = [min(min(params.X),slm.knots(1)),max(max(params.X),slm.knots(end))];
      Xev = linspace(Xlim(1),Xlim(2),params.Nev);
      
      switch params.Plot
        case 'dy'
          dev = slmeval(Xev,slm,1);
          ylab = 'First derivative: df/dx';
        case 'dy2'
          dev = slmeval(Xev,slm,2);
          ylab = 'Second derivative';
        case 'dy3'
          dev = slmeval(Xev,slm,3);
          ylab = 'Third derivative';
      end
      
      % No data handles
      params.Handles.Data = [];
      
      params.Handles.Curve = plot(Xev,Yev);
      set(h,'Marker','none','Color',params.LineColor, ...
        'LineStyle',params.LineStyle,'LineWidth',params.LineWidth)
      hold on

      % y axis label
      ylabel ylab
      
  end
  
  % x label is the same for all plot variations
  xlabel 'X'
  
  % vertical lines for the knots
  axlim = axis;
  yrange = axlim(3:4);
  
  % loop over the knots plot, so that individual buttondownfcns
  % can be set.
  nk = numel(slm.knots);
  params.Handles.Knots = gobjects(1,nk);
  for i = 1:nk
    params.Handles.Knots(i) = plot(repmat(slm.knots(i)',2,1),yrange(:));
    set(params.Handles.Knots(i),'Marker','none','Color',params.KnotColor, ...
      'LineStyle',params.KnotStyle,'LineWidth',params.KnotWidth, ...
      'buttondownfcn',[])
  end
  
  % was the grid supposed to be on?
  if strcmpi(params.Grid,'on')
    grid on
  else
    grid off
  end
  
  % un-hold the plot
  hold off
  
end % (nested) PlotModel

% ===================================================
%    nested functions (callback processing)
% ===================================================
function CloseSLM(src,evnt,howcalled) %#ok
  % close request has been issued.
  if strcmp(howcalled,'button')
    % don't quibble here
    uiresume
  end
  
  % do we ask if they mean it?
  if (nargin < 3) || isempty(howcalled) || strcmp(howcalled,'X')
    terminate = questdlg('Do you wish to terminate the spline fit process?','Finish?','Yes','No','Yes');
  else
    terminate = 'Yes';
  end
  if strcmp(terminate,'Yes')
    % allow the resume to happen, returning the final spline
    uiresume
  end
end % (nested) qwerty

% ===================================================
%    nested functions (callback processing)
% ===================================================
function qwerty(src,evnt) %#ok
  
  
  
  
  
  
  
  
  
  
end % (nested) qwerty

end % Mainline end 

