%clear all
clf
cmap = colormap;

%dirname = ['../output/20170215_13:05'];
%dirname = ['../output/20170215_13:10'];
if (dirname)
	printf("Use directory: %s\n", dirname);
else
	dirname = ['../output/LATEST'];
end

plot_gaussians=false;

fname = [dirname '/results.txt']
load(fname)

mu=mu';

K=size(mu,2)

if (plot_gaussians)
	for i = 1:K
		j=i*2;
		color = cmap(mod(5*j,63)+1,:); 

		R = sigma(:,:,i);
		mu_i = mu(:,i);

		% calculate the ellipse
		A     = chol ( R, "lower");
		theta = linspace (0, 2*pi, 1000);
		x     = mu_i + 2.5 .* A * [cos(theta); sin(theta)];

		% plot the ellipse
		hold on;
		plot(x(1,:), x(2,:), "r", "LineWidth", 2, 'color', color);

		% plot the data
		fname = [dirname '/results' num2str(i-1) '.txt'];
		data = load(fname)';
		plot(data(1,:), data(2,:), '.', 'MarkerSize', 20, 'color', color);
	end

else

	mmax=2;
	printf("Only display lines with more than %i points\n", mmax);

	for i = 1:K
		j=i*2;
		color = cmap(mod(5*j,63)+1,:); 

		R = sigma(i);
		mu_i = mu(:,i);

		% calculate the ellipse
		%A     = chol ( R, "lower");
		%theta = linspace (0, 2*pi, 1000);
		%x     = mu_i + 2.5 .* A * [cos(theta); sin(theta)];
			
		t = linspace(-10, 10, 10);
		hor = [ones(1,10); t];
		y = mu_i' * hor;

		% plot the data
		fname = [dirname '/results' num2str(i-1) '.txt'];
		%printf "Load data from %s\n", fname
		data = load(fname)';

		if length(data) > mmax
			plot(t, y, "r", "LineWidth", 2, 'color', color);
			% plot the ellipse
			hold on;
		end
			%plot(x(1,:), x(2,:), "r", "LineWidth", 2, 'color', color);
			plot(data(2,:), data(3,:), '.', 'MarkerSize', 10, 'color', color);
%		end
	end
end

hold off

