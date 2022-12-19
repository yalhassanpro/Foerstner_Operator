            % Developed by YAKUBU ALHASSAN
            %HFT STUTTGART
            %MSC. PHOTOGRAMMETRY AND GEOINFORMATICS

            orig_img = imread('');    
            Gray_img = im2gray(orig_img);  

            %figure(2);
                %imshow(Gray_img);
         
            prompt = 'Enter the windows size.(e.g. 5,7 or 21) : ';
            win_size = input(prompt);
            
            prompt = 'Enter roundness threshold value.(Between 0 and 1) : ';
            threshold_int = input(prompt); %size or roundess threshold
            
            prompt = 'Enter weight threshold value.(Greater than 0) : '
            weight_int = input(prompt);
            
            %Get row, column heights
            row_height = size(Gray_img, 1);
            col_width = size(Gray_img, 2);
            win_border = floor(win_size/2);
            
            %Compute gradients using sobel operator (2 convolutions)
            gx = edge(Gray_img,'sobel','vertical');
            gy = edge(Gray_img,'sobel','horizontal');
            
            
            %Creating zero matrices to hold roundness and weight values
            round_mat = zeros(row_height, col_width);
            weight_mat = zeros(row_height, col_width);

            %Compute the gradient square and the multiple of the gradients
            gx2 = gx.*gx;
            gy2 = gy.*gy;
            gxgy_ = gx.*gy;
            
            %figure;
                  %imshow(gx2)
            %figure;
                 %imshow(gy2)
            %figure;
                 %imshow(gxgy_)
            
            figure;
            imshow(orig_img),title('Selected Points')

            
            for i = 1:row_height
                for j = 1:col_width
                        %Initialize threshold with 0
                        errell_round(i,j) = 0;                     
                        errell_weight(i,j) = 0;
                    
                        %Create box filter 
                    if (((i >= win_border + 1) && (i <= (row_height-win_border))) && (j >= (win_border + 1) && (j <= (col_width-win_border))))
                        
                        %Sum all pixel elements within the box filter for the gx2 gradient image and multiply by the gradient image gx
                        conv_x_values = gx2(i - win_border: i + win_border, j- win_border: j + win_border);  
                        conv_x_sum = sum(sum(conv_x_values));
                        
                        %Sum all pixel elements within the box filter for the gy2 gradient image and multiply by the gradient image gy square
                        conv_y_values = gy2(i - win_border: i + win_border, j- win_border: j + win_border);  
                        conv_y_sum = sum(sum(conv_y_values));
                        
                        %Sum all pixel elements within the box filter for the gxgy gradient image and multiply by the gradient image gxgy
                        conv_xy_values = gxgy_(i - win_border: i + win_border, j- win_border: j + win_border);  
                        conv_xy_sum = sum(sum(conv_xy_values));
                        
                        % Normal Matrix with elements sum of gx2, sum of gy2 and sum of gxgy
                        N_matrix = [conv_x_sum, conv_xy_sum; conv_xy_sum, conv_y_sum];

                        %determine eigen values of normal matrix and use them to compute the roundness and weight
                        eigenvalues = eig(N_matrix);
                        lambda1 = eigenvalues(1);
                        lambda2 = eigenvalues(2);

                        errell_round(i,j) = (lambda1*lambda2)/(lambda1+lambda2);
                        errell_weight(i,j) = 1-((lambda1-lambda2)/(lambda1+lambda2))^2;
                        
                        
                        % compare threshold to specified values
                        if (errell_weight(i,j) > weight_int && errell_round(i,j) > threshold_int)
                            
                        hold on;
                        plot(j,i,'r+','MarkerSize',0.3)  
                        end
                    end
                end
            end