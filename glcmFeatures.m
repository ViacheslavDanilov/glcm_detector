function [out] = glcmFeatures(glcmin,pairs)

% If 'pairs' not entered: set pairs to 0 
if ((nargin > 2) || (nargin == 0))
   error('Too many or too few input arguments. Enter GLCM and pairs.');
elseif ( (nargin == 2) ) 
    if ((size(glcmin,1) <= 1) || (size(glcmin,2) <= 1))
       error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcmin,1) ~= size(glcmin,2) )
        error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end    
elseif (nargin == 1) % only GLCM is entered
    pairs = 0; % default is numbers and input 1 for percentage
    if ((size(glcmin,1) <= 1) || (size(glcmin,2) <= 1))
       error('The GLCM should be a 2-D or 3-D matrix.');
    elseif ( size(glcmin,1) ~= size(glcmin,2) )
       error('Each GLCM should be square with NumLevels rows and NumLevels cols');
    end    
end

format long e
if (pairs == 1)
    newn = 1;
    for nglcm = 1:2:size(glcmin,3)
        glcm(:,:,newn)  = glcmin(:,:,nglcm) + glcmin(:,:,nglcm+1);
        newn = newn + 1;
    end
elseif (pairs == 0)
    glcm = glcmin;
end

size_glcm_1 = size(glcm,1);
size_glcm_2 = size(glcm,2);
size_glcm_3 = size(glcm,3);

% checked
out.Autocorrelation = zeros(1,size_glcm_3); % Autocorrelation: [2] 
% out.Contrast = zeros(1,size_glcm_3); % Contrast: matlab/[1,2]
% out.Correlation = zeros(1,size_glcm_3); % Correlation: matlab
% out.Correlation_e = zeros(1,size_glcm_3); % Correlation: [1,2]
% out.Cluster_prominence = zeros(1,size_glcm_3); % Cluster Prominence: [2]
% out.Cluster_shade = zeros(1,size_glcm_3); % Cluster Shade: [2]
out.Dissimilarity = zeros(1,size_glcm_3); % Dissimilarity: [2]
% out.Energy = zeros(1,size_glcm_3); % Energy: matlab / [1,2]
out.Entropy = zeros(1,size_glcm_3); % Entropy: [2]
% out.Homogeneity = zeros(1,size_glcm_3); % Homogeneity: matlab
% out.Homogeneity_e = zeros(1,size_glcm_3); % Homogeneity: [2]
% out.Maximum_probability = zeros(1,size_glcm_3); % Maximum probability: [2]
% out.Sum_of_sqaures = zeros(1,size_glcm_3); % Sum of sqaures: Variance [1]
% out.Sum_average = zeros(1,size_glcm_3); % Sum average [1]
% out.Sum_variance = zeros(1,size_glcm_3); % Sum variance [1]
% out.Sum_entropy = zeros(1,size_glcm_3); % Sum entropy [1]
% out.Difference_variance = zeros(1,size_glcm_3); % Difference variance [4]
% out.Difference_entropy = zeros(1,size_glcm_3); % Difference entropy [1]
% out.Information_measure_of_correlation_1 = zeros(1,size_glcm_3); % Information measure of correlation1 [1]
% out.Information_measure_of_correlation_2 = zeros(1,size_glcm_3); % Informaiton measure of correlation2 [1]
% out.Inverse_difference_normalized = zeros(1,size_glcm_3); % Inverse difference normalized (INN) [3]
% out.Inverse_difference_moment_normalized = zeros(1,size_glcm_3); % Inverse difference moment normalized [3]

glcm_sum  = zeros(size_glcm_3,1);
% glcm_mean = zeros(size_glcm_3,1);
% glcm_var  = zeros(size_glcm_3,1);
% u_x = zeros(size_glcm_3,1);
% u_y = zeros(size_glcm_3,1);
% s_x = zeros(size_glcm_3,1);
% s_y = zeros(size_glcm_3,1);

% p_x = zeros(size_glcm_1,size_glcm_3); % Ng x #glcms[1]  
% p_y = zeros(size_glcm_2,size_glcm_3); % Ng x #glcms[1]
% p_xplusy = zeros((size_glcm_1*2 - 1),size_glcm_3); %[1]
% p_xminusy = zeros((size_glcm_1),size_glcm_3); %[1]
% hxy  = zeros(size_glcm_3,1);
% hxy1 = zeros(size_glcm_3,1);
% hx   = zeros(size_glcm_3,1);
% hy   = zeros(size_glcm_3,1);
% hxy2 = zeros(size_glcm_3,1);

for k = 1:size_glcm_3 % number glcms
    glcm_sum(k) = sum(sum(glcm(:,:,k)));
    glcm(:,:,k) = glcm(:,:,k)./glcm_sum(k); % Normalize each glcm
%     glcm_mean(k) = mean2(glcm(:,:,k)); % compute mean after norm
%     glcm_var(k)  = (std2(glcm(:,:,k)))^2;
%     
    for i = 1:size_glcm_1
        for j = 1:size_glcm_2
%             out.Contrast(k) = out.Contrast(k) + (abs(i - j))^2.*glcm(i,j,k);
            out.Dissimilarity(k) = out.Dissimilarity(k) + (abs(i - j)*glcm(i,j,k));
%             out.Energy(k) = out.Energy(k) + (glcm(i,j,k).^2);
            out.Entropy(k) = out.Entropy(k) - (glcm(i,j,k)*log(glcm(i,j,k) + eps));
%             out.Homogeneity(k) = out.Homogeneity(k) + (glcm(i,j,k)/( 1 + abs(i-j) ));
%             out.Homogeneity_e(k) = out.Homogeneity_e(k) + (glcm(i,j,k)/( 1 + (i - j)^2));
%             out.Sum_of_sqaures(k) = out.Sum_of_sqaures(k) + glcm(i,j,k)*((i - glcm_mean(k))^2);          
%             out.Inverse_difference_normalized(k) = out.Inverse_difference_normalized(k) + (glcm(i,j,k)/( 1 + (abs(i-j)/size_glcm_1) ));
%             out.Inverse_difference_moment_normalized(k) = out.Inverse_difference_moment_normalized(k) + (glcm(i,j,k)/( 1 + ((i - j)/size_glcm_1)^2));
%             u_x(k)          = u_x(k) + (i)*glcm(i,j,k); % changed 10/26/08
%             u_y(k)          = u_y(k) + (j)*glcm(i,j,k); % changed 10/26/08
        end
%         
    end
%     out.Maximum_probability(k) = max(max(glcm(:,:,k)));
end

% for k = 1:size_glcm_3  
%     for i = 1:size_glcm_1       
%         for j = 1:size_glcm_2
%             p_x(i,k) = p_x(i,k) + glcm(i,j,k); 
%             p_y(i,k) = p_y(i,k) + glcm(j,i,k); % taking i for j and j for i
%             if (ismember((i + j),[2:2*size_glcm_1])) 
%                 p_xplusy((i+j)-1,k) = p_xplusy((i+j)-1,k) + glcm(i,j,k);
%             end
%             if (ismember(abs(i-j),[0:(size_glcm_1-1)])) 
%                 p_xminusy((abs(i-j))+1,k) = p_xminusy((abs(i-j))+1,k) +...
%                     glcm(i,j,k);
%             end
%         end
%     end
% end

% computing sum average, sum variance and sum entropy:
% for k = 1:(size_glcm_3)   
%     for i = 1:(2*(size_glcm_1)-1)
%         out.Sum_entropy(k) = out.Sum_entropy(k) - (p_xplusy(i,k)*log(p_xplusy(i,k) + eps));
%     end
% end

% compute sum variance with the help of sum entropy
% for k = 1:(size_glcm_3) 
%     for i = 1:(2*(size_glcm_1)-1)
%         out.Sum_variance(k) = out.Sum_variance(k) + (((i+1) - out.Sum_entropy(k))^2)*p_xplusy(i,k);
%     end
% 
% end

% compute difference variance, difference entropy, 
% for k = 1:size_glcm_3
%     for i = 0:(size_glcm_1-1)
%         out.Difference_entropy(k) = out.Difference_entropy(k) - (p_xminusy(i+1,k)*log(p_xminusy(i+1,k) + eps));
%         out.Difference_variance(k) = out.Difference_variance(k) + (i^2)*p_xminusy(i+1,k);
%     end
% end


% for k = 1:size_glcm_3
%     hxy(k) = out.Entropy(k);
%     for i = 1:size_glcm_1
%         
%         for j = 1:size_glcm_2
%             hxy1(k) = hxy1(k) - (glcm(i,j,k)*log(p_x(i,k)*p_y(j,k) + eps));
%             hxy2(k) = hxy2(k) - (p_x(i,k)*p_y(j,k)*log(p_x(i,k)*p_y(j,k) + eps));
%         end
%         hx(k) = hx(k) - (p_x(i,k)*log(p_x(i,k) + eps));
%         hy(k) = hy(k) - (p_y(i,k)*log(p_y(i,k) + eps));
%     end
%     out.Information_measure_of_correlation_1(k) = ( hxy(k) - hxy1(k) ) / ( max([hx(k),hy(k)]) );
%     out.Information_measure_of_correlation_2(k) = ( 1 - exp( -2*( hxy2(k) - hxy(k) ) ) )^0.5;
% 
% end

% corm = zeros(size_glcm_3,1);
corp = zeros(size_glcm_3,1);
for k = 1:size_glcm_3
    for i = 1:size_glcm_1
        for j = 1:size_glcm_2
%             s_x(k)  = s_x(k)  + (((i) - u_x(k))^2)*glcm(i,j,k);
%             s_y(k)  = s_y(k)  + (((j) - u_y(k))^2)*glcm(i,j,k);
            corp(k) = corp(k) + ((i)*(j)*glcm(i,j,k));
%              corm(k) = corm(k) + (((i) - u_x(k))*((j) - u_y(k))*glcm(i,j,k));
%             out.Cluster_prominence(k) = out.Cluster_prominence(k) + (((i + j - u_x(k) - u_y(k))^4)*glcm(i,j,k));
%             out.Cluster_shade(k) = out.Cluster_shade(k) + (((i + j - u_x(k) - u_y(k))^3)*glcm(i,j,k));
        end
    end
%     s_x(k) = s_x(k) ^ 0.5;
%     s_y(k) = s_y(k) ^ 0.5;
    out.Autocorrelation(k) = corp(k);
%     out.Correlation_e(k) = (corp(k) - u_x(k)*u_y(k))/(s_x(k)*s_y(k));
%     out.Correlation(k) = corm(k) / (s_x(k)*s_y(k));

end


%       GLCM Features (Soh, 1999; Haralick, 1973; Clausi 2002)
%           f1. Uniformity / Energy / Angular Second Moment (done)
%           f2. Entropy (done)
%           f3. Dissimilarity (done)
%           f4. Contrast / Inertia (done)
%           f5. Inverse difference    
%           f6. correlation
%           f7. Homogeneity / Inverse difference moment
%           f8. Autocorrelation
%           f9. Cluster Shade
%          f10. Cluster Prominence
%          f11. Maximum probability
%          f12. Sum of Squares
%          f13. Sum Average
%          f14. Sum Variance
%          f15. Sum Entropy
%          f16. Difference variance
%          f17. Difference entropy
%          f18. Information measures of correlation (1)
%          f19. Information measures of correlation (2)
%          f20. Maximal correlation coefficient
%          f21. Inverse difference normalized (INN)
%          f22. Inverse difference moment normalized (IDN)
