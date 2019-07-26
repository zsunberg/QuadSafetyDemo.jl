function uOpt = optCtrl(obj, ~, ~, deriv, uMode)
% uOpt = optCtrl(obj, t, y, deriv, uMode)
%     Dynamics of the Plane4D
%         \dot{x}_1 = x_4 * cos(x_3) + d_1
%         \dot{x}_2 = x_4 * sin(x_3) + d_2
%         \dot{x}_3 = u_1 = u_1
%         \dot{x}_4 = u_2 = u_2

%% Input processing
if nargin < 5
  uMode = 'min';
end

if ~iscell(deriv)
  deriv = num2cell(deriv);
end

uOpt = cell(obj.nu, 1);

%% multiplier
if any(obj.dims == 2) && any(obj.dims == 4)
F = obj.grav*(obj.m1+obj.m2);
multiplier = (F/obj.m1).*(deriv{obj.dims==2}+(deriv{obj.dims==4}/obj.l));
end

%% Optimal control
if strcmp(uMode, 'max')
  if any(obj.dims == 2)
      uOpt{1} = (multiplier>0)*obj.thetaMax +...
          (multiplier<0)*obj.thetaMin;
  end

elseif strcmp(uMode, 'min')
  if any(obj.dims == 2)
      uOpt{1} = (multiplier>0)*obj.thetaMin +...
          (multiplier<0)*obj.thetaMax;
  end
else
  error('Unknown uMode!')
end

end
