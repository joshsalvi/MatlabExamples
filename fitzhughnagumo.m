function fitzhughnagumo(v0,w0,a,i0,d,eps)
% This is a simplified version of the Hodgkin-Huxley model, commonly known
% as the FitzHugh-Nagumo model. This models the spike generation in squid
% giant axons. There are two variables: V is a voltage-like variable with
% cubic nonlinearity that allows self-excitation via positive feedback. W
% is a recovery variable with linear behavior providing a slower negative
% feedback. The model follows the equation:
%
% dv/dt = -v*(v-a)*(v-1)-w+i0
% dw/dt = eps*(v-d*w)
%
% fitzhughnagumo(v0,w0,a,i0,d,eps)
%
% v0 : initial voltage
% w0 : initial recovery
% a : nonlinear coefficient
% d : linear coefficient
% i0 : current injection
% eps : linear coefficient
%
% This function will generate the appropriate waveforms and also calculate
% the nullclines of the equation.
% http://en.wikipedia.org/wiki/FitzHugh%E2%80%93Nagumo_model
%
% Example:
% fitzhughnagumo(0,0,0.1,0.1,1,0.01)
% -> This will output three plots. The first is a plot of V and W over
% time. The second is the v-w phase plane. Finally, the third plot shows
% the nullclines for v and w. 
%
% jsalvi@rockefeller.edu
%


Y0 = [v0,w0];   % initial conditions
t = 0:0.1:400;  % define a time vector
options = odeset('RelTol',1e-5);    % set ODE options

[T,Y] = ode45(@dydt_FHN,t,Y0,options,a,eps,d,i0);   % solve the ODE (see function below)

% Plot the time courses of the voltage and recovery variables
figure;
plot(T,Y(:,1),T,Y(:,2)); legend('v(t)','w(t)');
xlabel('Time');ylabel('v(t), w(t)');

vpts = (-1.5:0.05:1.5);

% Plot v-w phase plane
figure;
plot(Y(:,1),Y(:,2)); 
xlabel('v');ylabel('w');
title('Phase Plane');

% Find the nullclines and plot
options=optimset; % sets options in fzero to default values
for k=1:61
vnullpts(k)=fzero(@vrhs_FHN,[-10 10],options,vpts(k),a,i0);  
end
%vnullpts=-vpts.*(vpts-a).*(vpts-1)+i0;
wnullpts=vpts/d;
figure;
plot(vpts,vnullpts,'black',vpts,wnullpts,'black');
title('Fizhugh-Nagumo Nullclines');
xlabel('v'); ylabel('w');
axis([-1 1.5 -.5 1]);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%


function dY=dydt_FHN(t,Y,a,eps,d,i0)
v=Y(1);
w=Y(2);
dY=zeros(2,1);
dY(1)=-v*(v-a)*(v-1)-w+i0*1/(1+exp(20-t)/.2);
dY(2)=eps*(v-d*w);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%% 

function val=vrhs_FHN(w,v,a,i0)
	val=-v*(v-a)*(v-1)-w+i0;
end


